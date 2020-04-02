require 'net/http'

class MetroController < ApplicationController
  def bus_stops
    
    unless Redis.current.exists("busstops-#{params[:RouteID]}")
      response = fetch_data_with_params('https://api.wmata.com/Bus.svc/json/jRouteSchedule', params, nil)
      Redis.current.set("busstops-#{params["RouteID"]}", response, {ex: 604800})
    end

    render json: Redis.current.get("busstops-#{params[:RouteID]}")
  end

  def bus_stop
    unless Redis.current.exists("stop-#{params[:stop_id]}")
      response = fetch_data("https://api.wmata.com/NextBusService.svc/json/jPredictions/?StopID=#{params[:stop_id]}", nil)
      Redis.current.set("stop-#{params[:stop_id]}", response, {ex: 15})
    end
  
    render json: Redis.current.get("stop-#{params[:stop_id]}")
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