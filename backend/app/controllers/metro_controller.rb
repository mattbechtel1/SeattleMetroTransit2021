require 'net/http'
require 'protobuf'
require 'google/transit/gtfs-realtime.pb'
require 'json'

class MetroController < ApplicationController
  before_action :check_redis

  def bus_stops
    if params[:RouteID].strip.empty?
      render json: {:bus => {:Message => "Could not parse Route ID"}}, status: 400
      return
    end
    unless $redis.exists?("busstops-#{params[:RouteID]}")
      response_direction0 = Trip.by_route_and_direction(params[:RouteID], 0)
      response_direction1 = Trip.by_route_and_direction(params[:RouteID], 1)
      if response_direction0.empty? && response_direction1.empty?
        render json: {:bus => {:Message => "Unable to identify route"}}, status: 404 
        return
      end
      $redis.setex(
        "busstops-#{params[:RouteID]}", 
        QUARTER_MINUTE,
        DirectionSerializer.new(response_direction0, response_direction1).to_serialized_json 
      )
    end

    render json: {
      :alerts => $redis.lrange("alert-#{params[:RouteID]}", 0, -1), 
      :bus => JSON.parse($redis.get("busstops-#{params[:RouteID]}")) 
    }.to_json
  end

  def bus_stop
    unless $redis.exists?("stop-#{params[:StopId]}")
      begin
        response = Stop.find(params[:StopId])
      rescue ActiveRecord::RecordNotFound
        error_message = "Stop not found"
        $redis.setex("stoperror-#{params[:StopId]}", QUARTER_MINUTE, error_message)
      else
        stop = StopSerializer.new(response)
        $redis.setex("stop-#{params[:StopId]}", QUARTER_MINUTE, stop.to_serialized_json)
      end
    end

    semi_stop = $redis.get("stop-#{params[:StopId]}")
    if semi_stop
      return_stop = JSON.parse(semi_stop)
    else
      return_stop = nil
    end
    render json: {:Message => $redis.get("stoperror-#{params[:StopId]}"), :alerts => [], :stop => return_stop}.to_json
  end

  def bus_route_list
    unless $redis.exists?('allBuses')
      response = Route.ordered_routes
      serialized_routes = response.map { |r| RouteSerializer.new(r).to_serialized_json }
      $redis.setex('allBuses', ONE_WEEK, serialized_routes.to_json)
    end
    render json: {:Routes => JSON.parse($redis.get('allBuses'))}.to_json
  end

  def stations
    if params[:Linecode]
      render json: {error: True, message: "stations API not implemented for Seattle line codes", status: 501}
    else
      unless $redis.exists?('sea-allStations')
        response = Station.ordered_stations
        serialized_stations = response.map { |s| StationListSerializer.new(s).to_serialized_json }
        $redis.setex('sea-allStations', ONE_WEEK, serialized_stations.to_json)
      end
        render json: JSON.parse($redis.get('sea-allStations'))
    end
  end

  def station
    if $redis.exists?("sea-station-#{params[:station_code]}")
      render json: $redis.get("sea-station-#{params[:station_code]}")
    else
      render json: {error: true, message: "station API not implemented for Seattle", status: 501}
      # $redis.setex("station-#{params[:station_code]}", THIRD_MINUTE, response)
    end
  end

  def lines
    if $redis.exists?("sea-lines")
      render json: $redis.get('sea-lines')
    else
      render json: {error: true, message: "lines API not implemented for Seattle", status: 501}
      # response = fetch_data(RAIL_LINES_URL, nil)
      # $redis.set('lines', response)
    end
  end


  # alerts does not return data to the frontend
  def alerts
      render json: {error: true, message: "alerts API not implemented", status: 501}
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

  def check_redis
    begin
      random_key = 'bfb74640-ed64-4eff-bfde-848daecfae5f'
      $redis.get(random_key)
    rescue RedisClient::CannotConnectError => error
      render json: {error: True, message: 'Redis cache is misconfigured' + error, status: 500}
    end
  end

end