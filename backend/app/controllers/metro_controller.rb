require 'net/http'
require 'protobuf'
require 'google/transit/gtfs-realtime.pb'
require 'json'

class MetroController < ApplicationController
  def bus_stops
    
    unless Redis.current.exists("busstops-#{params[:RouteID]}")
      response = fetch_data_with_params('https://api.wmata.com/Bus.svc/json/jRouteSchedule', params, nil)
      Redis.current.set("busstops-#{params["RouteID"]}", response, {ex: 604800})
    end

    render json: {:alerts => Redis.current.lrange("alert-#{params[:RouteID]}", 0, -1), :bus => JSON.parse(Redis.current.get("busstops-#{params[:RouteID]}")) }.to_json
  end

  def bus_stop
    unless Redis.current.exists("stop-#{params[:stopId]}")
      response = fetch_data("https://api.wmata.com/NextBusService.svc/json/jPredictions/?StopID=#{params[:stopId]}", nil)
      Redis.current.set("stop-#{params[:stopId]}", response, {ex: 15})
    end
  
    render json: { :alerts => Redis.current.lrange("alert-#{params[:routeId]}", 0, -1), :stop => JSON.parse(Redis.current.get("stop-#{params[:stopId]}")) }.to_json

    # , 
  end

  def bus_route_list
    unless Redis.current.exists('allBuses')
      response = fetch_data('https://api.wmata.com/Bus.svc/json/jRoutes', nil)
      Redis.current.set('allBuses', response, {ex: 604800})
    end
    
    render json: Redis.current.get('allBuses')
  end

  def stations
    unless Redis.current.exists('allStations')
      response = fetch_data_with_params('https://api.wmata.com/Rail.svc/json/jStations', params, nil)
      Redis.current.set('allStations', response, {ex: 604800})
    end

    render json: Redis.current.get('allStations')
  end

  def station
    unless Redis.current.exists("station-#{params[:station_code]}")
      response = fetch_data("https://api.wmata.com/StationPrediction.svc/json/GetPrediction/#{params[:station_code]}", nil)
      Redis.current.set("station-#{params[:station_code]}", response, {ex: 20})
    end

    render json: Redis.current.get("station-#{params[:station_code]}")
  end

  def lines
    unless Redis.current.exists("lines")
      response = fetch_data('https://api.wmata.com/Rail.svc/json/jLines', nil)
      Redis.current.set('lines', response)
    end

    render json: Redis.current.get('lines')
  end


  # alerts does not return data to the frontend
  def alerts
    response = fetch_data('https://api.wmata.com/gtfs/bus-gtfsrt-alerts.pb', "{body}")
    feed = Transit_realtime::FeedMessage.decode(response)
    
    feed.entity.filter {|entity| entity.id[0] == "1"}.each {|entity|
      entity.alert.informed_entity.each {|bus|
        Redis.current.del("alert-#{bus.route_id}")
        Redis.current.rpush("alert-#{bus.route_id}", entity.alert.header_text.translation[0].text)
        Redis.current.expire("alert-#{bus.route_id}", 30.minutes)
      }
    }

    # render json: feed.entity.filter {|entity| entity.id[0] == "1"}
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