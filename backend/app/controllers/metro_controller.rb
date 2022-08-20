require 'net/http'
require 'protobuf'
require 'google/transit/gtfs-realtime.pb'
require 'json'

class MetroController < ApplicationController
  COLOR_DICT = {
    "BL" => "BLUE",
    "OR" => "ORANGE",
    "SV" => "SILVER",
    "GR" => "GREEN",
    "RD" => "RED",
    "YL" => "YELLOW"
  }

  BUS_ROUTE_SCHEDULE_URL = 'https://api.wmata.com/Bus.svc/json/jRouteSchedule'
  BUS_ALERTS_URL = 'https://api.wmata.com/gtfs/bus-gtfsrt-alerts.pb'

  STATIONS_URL = 'https://api.wmata.com/Rail.svc/json/jStations'
  RAIL_LINES_URL = 'https://api.wmata.com/Rail.svc/json/jLines'
  RAIL_ALERTS_URL = 'https://api.wmata.com/gtfs/rail-gtfsrt-alerts.pb'
  STATION_PREDICTIONS_URL = 'https://api.wmata.com/StationPrediction.svc/json/GetPrediction'

  def bus_stops
    unless $redis.exists?("busstops-#{params[:RouteID]}")
      response = fetch_data(BUS_ROUTE_SCHEDULE_URL, nil)
      $redis.set("busstops-#{params["RouteID"]}", response, {ex: ONE_WEEK})
    end

    render json: {:alerts => $redis.lrange("alert-#{params[:RouteID]}", 0, -1), :bus => JSON.parse($redis.get("busstops-#{params[:RouteID]}")) }.to_json
  end

  def bus_stop
    unless $redis.exists?("stop-#{params[:StopId]}")
      response = Stop.find(params[:StopId])
      stop = StopSerializer.new(response)
      $redis.set("stop-#{params[:StopId]}", stop.to_serialized_json, {ex: QUARTER_MINUTE})
    end

    render json: {:alerts => [], :stop => JSON.parse($redis.get("stop-#{params[:StopId]}"))}.to_json
  end

  def bus_route_list
    unless $redis.exists?('allBuses')
      response = Route.all.map { |r| RouteSerializer.new(r).to_serialized_json }
      $redis.set('allBuses', response.to_json, {ex: QUARTER_MINUTE})
    end
    render json: {:Routes => JSON.parse($redis.get('allBuses'))}.to_json
  end

  def stations
    def sorted_json_response_from_wmata
      # Fetches station list from wamta and sorts accordingly
      response = fetch_data(STATIONS_URL, nil)
      response = JSON.parse(response)
      if params[:Linecode]
        response["Stations"].sort_by { |station| station["Lon"] }.to_json
      else
        response["Stations"].sort_by { |station| station["Name"] }.to_json
      end
    end


    if params[:Linecode]
      unless $redis.exists?("#{params[:Linecode]}-stations")
        $redis.set("#{params[:Linecode]}-stations", sorted_json_response_from_wmata, {ex: ONE_WEEK})
      end

      render json: { 
        :alerts => $redis.lrange("alert-#{COLOR_DICT[params[:Linecode]]}", 0, -1), 
        :stations => JSON.parse($redis.get("#{params[:Linecode]}-stations"))
      }.to_json
    
    else
      unless $redis.exists?('allStations')
        $redis.set('allStations', sorted_json_response_from_wmata, {ex: ONE_WEEK})
      end

      render json: $redis.get('allStations')
    end
  end

  def station
    unless $redis.exists?("station-#{params[:station_code]}")
      response = fetch_data("#{STATION_PREDICTIONS_URL}/#{params[:station_code]}", nil)
      $redis.set("station-#{params[:station_code]}", response, {ex: THIRD_MINUTE})
    end

    render json: $redis.get("station-#{params[:station_code]}")
  end

  def lines
    unless $redis.exists?("lines")
      response = fetch_data(RAIL_LINES_URL, nil)
      $redis.set('lines', response)
    end

    render json: $redis.get('lines')
  end


  # alerts does not return data to the frontend
  def alerts
    unless $redis.get('alert-times')
      bus_response = fetch_data(BUS_ALERTS_URL, "{body}")
      bus_feed = Transit_realtime::FeedMessage.decode(bus_response)
      
      bus_feed.entity.filter { |entity| entity.id[0] == "1" }.each do |entity|
        entity.alert.informed_entity.each do |bus|
          $redis.rpush("alert-#{bus.route_id}", entity.alert.header_text.translation[0].text)
          $redis.expire("alert-#{bus.route_id}", TEN_MINUTES)
        end
      end

      train_response = fetch_data(RAIL_ALERTS_URL, "{body}")
      train_feed = Transit_realtime::FeedMessage.decode(train_response)
      train_feed.entity.each do |entity|
        entity.alert.informed_entity.each do |alert|
          $redis.rpush("alert-#{alert.route_id}", entity.alert.description_text.translation[0].text)
          $redis.expire("alert-#{alert.route_id}", TEN_MINUTES)
        end
      end

      $redis.set('alert-times', true, ex: TEN_MINUTES)
      render json: bus_feed
    end
  end

  private

  def fetch_data(url, body)
    uri = URI(url)
    uri.query = URI.encode_www_form(strong_params.to_h)
    request = Net::HTTP::Get.new(uri.request_uri)
    request['api_key'] = Figaro.env.wmata_primary_key
    request.body = body
    
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
    end

    response.body
  end

  def strong_params
    params.permit(:RouteID, :IncludingVariations, :StopId, :Linecode)
  end

end