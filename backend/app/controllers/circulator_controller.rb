require 'net/http'

class CirculatorController < ApplicationController
    AGENCY = 'dc-circulator'
    
    PREDICTION_URL = 'http://webservices.nextbus.com/service/publicXMLFeed'
    def bus_stop
        unless Redis.current.exists?("circ-stop-#{params[:stopId]}")
            response = fetch_data(PREDICTION_URL, {
                command: 'predictions',
                a: AGENCY,
                stopId: params[:stopId]
            })
        end
        render xml: response
    end
    
    private

    def fetch_data url, params
        uri = URI(url)
        uri.query = URI.encode_www_form(params)

        response = Net::HTTP.get_response(uri)
        return response.body if response.is_a?(Net::HTTPSuccess)
    end

end
