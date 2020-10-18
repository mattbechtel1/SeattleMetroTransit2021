require 'net/http'
require 'json'

class CirculatorController < ApplicationController
    AGENCY = 'dc-circulator'
    CACHE = Redis.current
    PREDICTION_URL = 'http://webservices.nextbus.com/service/publicXMLFeed'

    def bus_stops
        unless CACHE.exists("busstops-#{params[:routeId]}")
            response = fetch_data(PREDICTION_URL, {
                command: 'routeConfig',
                a: AGENCY,
                r: params[:routeId]
            })
            CACHE.set("busstops-#{params[:routeId]}", response, ex: 1.week)
        end
        render json: Hash.from_xml(CACHE.get("busstops-#{params[:routeId]}")).to_json
    end

    def bus_stop
        unless CACHE.exists?("circ-stop-#{params[:stopId]}")
            response = fetch_data(PREDICTION_URL, {
                command: 'predictions',
                a: AGENCY,
                stopId: params[:stopId]
            })
        end
        render xml: response
    end

    def bus_route_list
        unless CACHE.exists?("allCirculators")
            response = fetch_data(PREDICTION_URL, {
                command: 'routeList',
                a: AGENCY
            })
            CACHE.set("allCirculators", response, ex: 1.week)
        end
        # render xml: CACHE.get("allCirculators")
        render json: Hash.from_xml(CACHE.get("allCirculators")).to_json
    end
    
    private

    def fetch_data url, params
        uri = URI(url)
        uri.query = URI.encode_www_form(params)

        response = Net::HTTP.get_response(uri)
        return response.body if response.is_a?(Net::HTTPSuccess)
    end

end
