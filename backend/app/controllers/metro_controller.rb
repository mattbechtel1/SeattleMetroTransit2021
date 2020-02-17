require 'net/http'

class MetroController < ApplicationController
  def bus_stops
    response = fetch_data_with_params('https://api.wmata.com/Bus.svc/json/jRouteSchedule', params, nil)

    render json: response
  end

  def bus_stop
    response = fetch_data("https://api.wmata.com/NextBusService.svc/json/jPredictions/?StopID=#{params[:stop_id]}", nil)
  
    render json: response
  end

  def bus_route_list
    response = fetch_data('https://api.wmata.com/Bus.svc/json/jRoutes', nil)
    
    render json: response
  end

  def stations
    response = fetch_data_with_params('https://api.wmata.com/Rail.svc/json/jStations', params, nil)

    render json: response
  end

  def station
    response = fetch_data("https://api.wmata.com/StationPrediction.svc/json/GetPrediction/#{params[:station_code]}", nil)

    render json: response
  end

  def lines
    response = fetch_data('https://api.wmata.com/Rail.svc/json/jLines', nil)

    render json: response
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
