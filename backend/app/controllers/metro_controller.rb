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
  BUS_ROUTES_URL = 'https://api.wmata.com/Bus.svc/json/jRoutes'
  BUS_ALERTS_URL = 'https://api.wmata.com/gtfs/bus-gtfsrt-alerts.pb'
  BUS_PREDICTIONS_URL = 'https://api.wmata.com/NextBusService.svc/json/jPredictions/'

  STATIONS_URL = 'https://api.wmata.com/Rail.svc/json/jStations'
  RAIL_LINES_URL = 'https://api.wmata.com/Rail.svc/json/jLines'
  RAIL_ALERTS_URL = 'https://api.wmata.com/gtfs/rail-gtfsrt-alerts.pb'

  def bus_stops    
    unless Redis.current.exists?("busstops-#{params[:RouteID]}")
      response = fetch_data_with_params(BUS_ROUTE_SCHEDULE_URL, params, nil)
      Redis.current.set("busstops-#{params["RouteID"]}", response, {ex: ONE_WEEK})
    end

    render json: {:alerts => Redis.current.lrange("alert-#{params[:RouteID]}", 0, -1), :bus => JSON.parse(Redis.current.get("busstops-#{params[:RouteID]}")) }.to_json
  end

  def bus_stop
    unless Redis.current.exists?("stop-#{params[:stopId]}")
      response = fetch_data("?StopID=#{params[:stopId]}", nil)
      Redis.current.set("stop-#{params[:stopId]}", response, {ex: QUARTER_MINUTE})
    end

    render json: { 
      :alerts => Redis.current.lrange("alert-#{params[:routeId]}", 0, -1),
      :stop => JSON.parse(Redis.current.get("stop-#{params[:stopId]}")) }.to_json
  end

  def bus_route_list
    unless Redis.current.exists?('allBuses')
      response = fetch_data(BUS_ROUTES_URL, nil)
      Redis.current.set('allBuses', response, {ex: ONE_WEEK})
    end
    
    render json: Redis.current.get('allBuses')
  end

  def stations
    if params[:Linecode]
      unless Redis.current.exists?("#{params[:Linecode]}-stations")
        response = fetch_data_with_params(STATIONS_URL, params, nil)
        Redis.current.set("#{params[:Linecode]}-stations", response, {ex: ONE_WEEK})
      end

      render json: { :alerts => Redis.current.lrange("alert-#{COLOR_DICT[params[:Linecode]]}", 0, -1), :stations => JSON.parse(Redis.current.get("#{params[:Linecode]}-stations"))}.to_json
    
    else
      unless Redis.current.exists?('allStations')
        response = fetch_data(STATIONS_URL, nil)
        Redis.current.set('allStations', response, {ex: ONE_WEEK})
      end

      render json: Redis.current.get('allStations')
    end
  end

  def station
    unless Redis.current.exists?("station-#{params[:station_code]}")
      response = fetch_data("https://api.wmata.com/StationPrediction.svc/json/GetPrediction/#{params[:station_code]}", nil)
      Redis.current.set("station-#{params[:station_code]}", response, {ex: THIRD_MINUTE})
    end

    render json: Redis.current.get("station-#{params[:station_code]}")
  end

  def lines
    unless Redis.current.exists?("lines")
      response = fetch_data(RAIL_LINES_URL, nil)
      Redis.current.set('lines', response)
    end

    render json: Redis.current.get('lines')
  end


  # alerts does not return data to the frontend
  def alerts
    unless Redis.current.get('alert-times')
      bus_response = fetch_data(BUS_ALERTS_URL, "{body}")
      bus_feed = Transit_realtime::FeedMessage.decode(bus_response)
      
      bus_feed.entity.filter { |entity| entity.id[0] == "1" }.each do |entity|
        entity.alert.informed_entity.each do |bus|
          Redis.current.rpush("alert-#{bus.route_id}", entity.alert.header_text.translation[0].text)
          Redis.current.expire("alert-#{bus.route_id}", TEN_MINUTES)
        end
      end

      train_response = fetch_data(RAIL_ALERTS_URL, "{body}")
      train_feed = Transit_realtime::FeedMessage.decode(train_response)
      train_feed.entity.each do |entity|
        entity.alert.informed_entity.each do |alert|
          Redis.current.rpush("alert-#{alert.route_id}", entity.alert.description_text.translation[0].text)
          Redis.current.expire("alert-#{alert.route_id}", TEN_MINUTES)
        end
      end

      Redis.current.set('alert-times', true, ex: TEN_MINUTES)
      render json: bus_feed
    end
  end

  private

  def fetch_data(url, body)
    uri = URI(url)
    request = Net::HTTP::Get.new(uri.request_uri)
    request['api_key'] = Figaro.env.wmata_primary_key
    request.body = body
    
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
    end

    response.body
  end

  def fetch_data_with_params(url, params, body)
    uri = URI(url)
    query = URI.encode_www_form(params.to_unsafe_h)

    if uri.query && uri.query.length > 0
      uri.query += '&' + query
    else
      uri.query = query
    end

    request = Net::HTTP::Get.new(uri.request_uri)
    request['api_key'] = Figaro.env.wmata_primary_key
    request.body = body
    
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
    end

    response.body
  end

end