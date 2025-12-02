require 'open-uri'
require 'zip'
require 'csv'

GTFS_FEED_URL = "https://metro.kingcounty.gov/GTFS/google_transit.zip"
ZIP_LOCATION = 'public/google_transit.zip'
EXTRACTED_LOCATION = 'public/google_transit/'

ST_GTFS_FEED_URL = "https://www.soundtransit.org/GTFS-rail/40_gtfs.zip"
ST_ZIP_LOCATION = 'public/40_gtfs.zip'
ST_EXTRACTED_LOCATION = 'public/sound_transit/'



def handle_headsign obj
    obj[:headsign] = obj[:headsign] || nil
    obj
end

def handle_unwanted_shape obj
    obj.delete(:shape_distance_traveled)
    obj
end


def log_large_file_error_detail chunk, error
    Rails.logger.error("Keys in first object:")
    first_object = chunk[0]
    keys = first_object.keys
    Rails.logger.error("Standard keys: " + keys.to_s)
    failed = false
    chunk.each { |item| 
        if item.keys != keys
            Rails.logger.error "Differing keys found in item: " + item.to_s
            failed = true
            break
        end
    }
    if !failed
        Rails.logger.error "Unable to identify source of ArgumentError"
    end

    raise error
end

def reattempt_chunk chunk, model, counter
    begin
        model.insert_all(chunk)
        Rails.logger.warn "Reattempt succeeded for chunk ##{counter.to_s}"
    rescue ArgumentError => new_error
        log_large_file_error_detail chunk, new_error
    end
end

def clean_large_file file_name, column_hash, model
    counter = 1
    total_chunks = SmarterCSV.process(file_name, {chunk_size: 50000, silence_missing_keys: true, key_mapping: column_hash}) do |chunk|
        begin
            Rails.logger.debug "Processing chunk ##{counter.to_s}"
            model.insert_all(chunk)
            counter += 1
        rescue ArgumentError => error
            Rails.logger.error("Caught argument error while processing chunk # #{counter.to_s} for #{model.name}")
            Rails.logger.error(error.message)
            if model == Stoptime
                Rails.logger.error("Attempting custom reattempt for #{model.name}")
                new_chunk = chunk.map do |item|
                    handle_headsign(item)
                end
                reattempt_chunk new_chunk, model, counter
                counter += 1
            elsif model == RailStoptime
                Rails.logger.error("Attempting custom reattempt for #{model.name}")
                new_chunk = chunk.map do |item|
                    handle_unwanted_shape(item)
                end
                reattempt_chunk new_chunk, model, counter
                counter += 1
            else
                log_large_file_error_detail chunk, error
            end
        end
    end
end

def clean_file file_name, column_hash
    Rails.logger.debug "Cleaning " + file_name
    csv_table = CSV.read(file_name, headers: true)
    Rails.logger.debug "Deleting extra columns"
    csv_table.by_col!.delete_if do |column_name, column_values|
        !column_hash.has_key?(column_name)
    end
    Rails.logger.debug "Arranging by row"
    csv_table.by_row!
    Rails.logger.debug "Opening " + file_name
    CSV.open("#{file_name}.out", "w+") do |csv|
        csv << csv_table.headers
        csv_table.each { |row| 
            csv << row
        }
    end
    Rails.logger.debug 'Generated ' + file_name + '.out'
end

namespace :download_gtfs_feed do
    desc "This task downloads the gtfs data"
    task :download_file do
        open(ZIP_LOCATION, 'wb') do |file|
            file << URI.open(GTFS_FEED_URL).read
        end
    end

    task :download_st_file do
        open(ST_ZIP_LOCATION, 'wb') do |file|
            file << URI.open(ST_GTFS_FEED_URL).read
        end
    end
    
    task :unzip_feed do
        FileUtils.mkdir_p(EXTRACTED_LOCATION)

        Zip::File.open(ZIP_LOCATION) do |zip_file|
            zip_file.each do |f|
                fpath = File.join(EXTRACTED_LOCATION, f.name)
                FileUtils.mkdir_p(File.dirname(fpath))
                zip_file.extract(f, fpath)
            end
        end
    end

    task :unzip_st_feed do 
        FileUtils.mkdir_p(ST_EXTRACTED_LOCATION)

        Zip::File.open(ST_ZIP_LOCATION) do |zip_file|
            zip_file.each do |f|
                fpath = File.join(ST_EXTRACTED_LOCATION, f.name)
                FileUtils.mkdir_p(File.dirname(fpath))
                zip_file.extract(f, fpath)
            end
        end
    end

    task :parse_files => [:environment] do 
        Rails.logger.debug 'Parsing files'
        agency_copy
        fare_attributues_copy
        routes_copy
        rail_routes_copy
        fare_rules_copy
        calendar_copy
        rail_calendar_copy
        trips_copy
        rail_trips_copy
        stops_copy
        stations_copy
        stoptimes_copy
        rail_stoptimes_copy
        Rails.logger.debug 'Finished parsing files'
    end

    task :cleanup do
        Rails.logger.debug "Removing files"
        FileUtils.rm_rf(EXTRACTED_LOCATION) if File.directory?(EXTRACTED_LOCATION)
        FileUtils.rm_rf(ST_EXTRACTED_LOCATION) if File.directory?(ST_EXTRACTED_LOCATION)
        File.delete(ZIP_LOCATION) if File.exist?(ZIP_LOCATION)
        File.delete(ST_ZIP_LOCATION) if File.exist?(ST_ZIP_LOCATION)
    end
end

namespace :update_gtfs_data do
    desc "This rebuilds the base data from GTFS and cleans up the files"
    task :update_all => [:environment] do
        Rake::Task["download_gtfs_feed:cleanup"].execute
        Rake::Task["download_gtfs_feed:download_file"].execute
        Rake::Task["download_gtfs_feed:unzip_feed"].execute
        Rake::Task["download_gtfs_feed:download_st_file"].execute
        Rake::Task["download_gtfs_feed:unzip_st_feed"].execute
        Rake::Task["download_gtfs_feed:parse_files"].execute
        Rake::Task["download_gtfs_feed:cleanup"].execute
    end
end


def process_file file, model, column_map, sound_transit = false
    Rails.logger.debug 'Processing ' + model.name
    model.delete_all
    if sound_transit
        location = ST_EXTRACTED_LOCATION
    else
        location = EXTRACTED_LOCATION
    end
    file_name = location + file
    file_size = File.size(file_name)
    Rails.logger.debug file_name + " size: " + file_size.to_s
    if file_size < 10000000
        clean_file(file_name, column_map)
        result = model.copy_from "#{file_name}.out" , :map => column_map, encoding: "bom|utf-8"
        Rails.logger.debug 'Finished processing ' + model.name
        result.clear
        Rails.logger.debug 'Cleared ' + model.name + ' from memory'
    else
        Rails.logger.error file_name + ' is too large to process. Need to split it up'
        clean_large_file(file_name, column_map, model)
        Rails.logger.debug 'Finished processing ' + model.name
    end
end

def agency_copy
    agency_map = {
        'agency_id' => 'agency_code',
        'agency_name' => 'name',
        'agency_url' => 'url',
        'agency_timezone' => 'timezone',
        'agency_lang' => 'language',
        'agency_phone' => 'phone',
        'agency_fare_url' => 'fare_url',
        :null => '',
    }
    process_file "agency.txt", Agency, agency_map
end

def fare_attributues_copy
    fare_map = {
        'fare_id' => 'id',
        'agency_id' => 'agency_id',
        'fare_period_id' => 'fare_period_id',
        'price' => 'price',
        'descriptions' => 'descriptions',
        'currency_type' => 'currency_type',
        'payment_method' => 'payment_method',
        'transfers' => 'transfers',
        'transfer_duration' => 'transfer_duration',
        :null => '',
    }
    process_file "fare_attributes.txt", FareAttribute, fare_map
end

def routes_copy
    route_map = {
        'route_id' => 'id',
        'agency_id' => 'agency_id',
        'route_short_name' => 'short_name',
        'route_long_name' => 'long_name',
        'route_desc' => 'description',
        'route_type' => 'route_type',
        'route_url' => 'url',
        'route_color' => 'color',
        'route_text_color' => 'text_color',
        :null => '',
    }
    process_file "routes.txt", Route, route_map
end

def rail_routes_copy
    rail_route_map = {
        'route_id' => 'id',
        'agency_id' => 'agency_id',
        'route_short_name' => 'short_name',
        'route_long_name' => 'long_name',
        'route_desc' => 'description',
        'route_type' => 'route_type',
        'route_url' => 'url',
        'route_color' => 'color',
        'route_text_color' => 'text_color',
        :null => '',
    }
    process_file "routes.txt", RailRoute, rail_route_map, true
end

def fare_rules_copy
    fare_rule_map = {
        'destination_id' => 'destination_id',
        'contains_id' => 'contains_id',
        'origin_id' => 'origin_id',
        'fare_id' => 'fare_attribute_id',
        'route_id' => 'route_id',
    }
    process_file "fare_rules.txt", RouteFare, fare_rule_map
end

def trips_copy
    trips_map = {
        'route_id' => 'route_id',
        'service_id' => 'calendar_id',
        'trip_id' => 'id',
        'trip_headsign' => 'headsign',
        'trip_short_name' => 'short_name',
        'direction_id' => 'direction_id',
        'block_id' => 'block_id',
        'shape_id' => 'shape_id',
        'peak_flag' => 'peak_flag',
        'fare_id' => 'fare_attribute_id',
        'wheelchair_accessible' => 'wheelchair_accessible',
        'wheelchair_boarding' => 'wheelchair_boarding',
    }
    process_file "trips.txt", Trip, trips_map
end

def rail_trips_copy
    trips_map = {
        'route_id' => 'rail_route_id',
        'trip_short_name' => 'short_name',
        'trip_id' => 'rail_trip_id',
        'trip_headsign' => 'headsign',
        'direction_id' => 'direction_id',
        'service_id' => 'rail_calendar_id',
    }
    process_file 'trips.txt', RailTrip, trips_map, true
end

def stops_copy
    stops_map = {
        'stop_id' => 'id',
        'stop_code' => 'code',
        'stop_name' => 'name',
        'stop_desc' => 'description',
        'stop_lat' => 'latitude',
        'stop_lon' => 'longitude',
        'zone_id' => 'zone_id',
        'stop_url' => 'url',
        'location_type' => 'location_type',
        'parent_station' => 'stop_id',
        'stop_timezone' => 'timezone'
    }
    process_file "stops.txt", Stop, stops_map
end

def stations_copy
    stations_map = {
        'stop_id' => 'id',
        'stop_code' => 'code',
        'stop_name' => 'name',
        'stop_desc' => 'description',
        'stop_lat' => 'latitude',
        'stop_lon' => 'longitude',
        'zone_id' => 'zone_id',
        'stop_url' => 'url',
        'location_type' => 'location_type',
        'parent_station' => 'stop_id',
        'stop_timezone' => 'timezone',
        'wheelchair_boarding' => 'wheelchair_boarding',
        'tts_stop_name' => 'full_stop_name',
        'platform_code' => 'platform_code'
    }
    process_file "stops.txt", Station, stations_map, true
end

def stoptimes_copy
    stoptimes_map = {
        :trip_id => :trip_id,
        :arrival_time => :arrival_time,
        :departure_time => :departure_time,
        :stop_id => :stop_id,
        :stop_sequence => :sequence,
        :stop_headsign => :headsign,
        :pickup_type => :pickup_type,
        :drop_off_type => :dropoff_type,
        :shape_dist_traveled => :shape_distance_traveled,
        :timepoint => :timepoint
    }
    process_file "stop_times.txt", Stoptime, stoptimes_map
end

def rail_stoptimes_copy
    stoptimes_map = {
        :trip_id => :rail_trip_id,
        :stop_id => :station_id,
        :departure_time => :departure_time,
        :arrival_time => :arrival_time,
        :stop_sequence => :sequence,
        :shape_dist_traveled => :shape_distance_traveled
    }
    process_file "stop_times.txt", RailStoptime, stoptimes_map, true
end

def calendar_copy
    calendar_map = {
        'service_id' => 'id',
        'monday' => 'monday',
        'tuesday' => 'tuesday',
        'wednesday' => 'wednesday',
        'thursday' => 'thursday',
        'friday' => 'friday',
        'saturday' => 'saturday',
        'sunday' => 'sunday',
        'start_date' => 'start_date',
        'end_date' => 'end_date'
    }
    process_file "calendar.txt", Calendar, calendar_map
end

def rail_calendar_copy
    calendar_map = {
        'service_id' => 'id',
        'monday' => 'monday',
        'tuesday' => 'tuesday',
        'wednesday' => 'wednesday',
        'thursday' => 'thursday',
        'friday' => 'friday',
        'saturday' => 'saturday',
        'sunday' => 'sunday',
        'start_date' => 'start_date',
        'end_date' => 'end_date'
    }
    process_file "calendar.txt", RailCalendar, calendar_map, true
end