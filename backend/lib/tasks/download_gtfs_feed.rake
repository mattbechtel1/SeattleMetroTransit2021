require 'open-uri'
require 'zip'
require 'csv'

GTFS_FEED_URL = "https://metro.kingcounty.gov/GTFS/google_transit.zip"
ZIP_LOCATION = 'public/google_transit.zip'
EXTRACTED_LOCATION = 'public/google_transit/'

ST_GTFS_FEED_URL = "https://www.soundtransit.org/GTFS-rail/40_gtfs.zip"
ST_ZIP_LOCATION = 'public/40_gtfs.zip'
ST_EXTRACTED_LOCATION = 'public/sound_transit/'

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
        agency_copy
        fare_attributues_copy
        routes_copy
        rail_routes_copy
        fare_rules_copy
        calendar_copy
        trips_copy
        stops_copy
        stoptimes_copy
    end

    task :cleanup do
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

def agency_copy
    Agency.delete_all
    Agency.copy_from "#{EXTRACTED_LOCATION}/agency.txt", :map => {
        'agency_id' => 'agency_code',
        'agency_name' => 'name',
        'agency_url' => 'url',
        'agency_timezone' => 'timezone',
        'agency_lang' => 'language',
        'agency_phone' => 'phone',
        'agency_fare_url' => 'fare_url',
        :null => '',
    }, encoding: 'bom|utf-8'
end

def fare_attributues_copy
    FareAttribute.delete_all
    FareAttribute.copy_from "#{EXTRACTED_LOCATION}/fare_attributes.txt", :map => {
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
    }, encoding: 'bom|utf-8'
end

def routes_copy
    Route.delete_all
    Route.copy_from "#{EXTRACTED_LOCATION}/routes.txt", :map => {
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
    }, encoding: 'bom|utf-8'
end

def rail_routes_copy
    RailRoute.delete_all
    RailRoute.copy_from "#{ST_EXTRACTED_LOCATION}/routes.txt", :map => {
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
    }, encoding: 'bom|utf-8'
end

def fare_rules_copy
    RouteFare.delete_all
    RouteFare.copy_from "#{EXTRACTED_LOCATION}/fare_rules.txt", :map => {
        'destination_id' => 'destination_id',
        'contains_id' => 'contains_id',
        'origin_id' => 'origin_id',
        'fare_id' => 'fare_attribute_id',
        'route_id' => 'route_id',
    }, encoding: "bom|utf-8"
end

def trips_copy
    Trip.delete_all
    Trip.copy_from "#{EXTRACTED_LOCATION}/trips.txt", :map => {
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
    }, encoding: 'bom|utf-8'
end

def stops_copy
    Stop.delete_all
    Stop.copy_from "#{EXTRACTED_LOCATION}/stops.txt", :map => {
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
    }, encoding: 'bom|utf-8'
end

def stoptimes_copy
    Stoptime.delete_all
    Stoptime.copy_from  "#{EXTRACTED_LOCATION}/stop_times.txt", :map => {
        'trip_id' => 'trip_id',
        'arrival_time' => 'arrival_time',
        'departure_time' => 'departure_time',
        'stop_id' => 'stop_id',
        'stop_sequence' => 'sequence',
        'stop_headsign' => 'headsign',
        'pickup_type' => 'pickup_type',
        'drop_off_type' => 'dropoff_type',
        'shape_dist_traveled' => 'shape_distance_traveled',
        'timepoint' => 'timepoint'
    }, encoding: 'bom|utf-8'
end

def calendar_copy
    Calendar.delete_all
    Calendar.copy_from "#{EXTRACTED_LOCATION}/calendar.txt", :map => {
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
    }, encoding: 'bom|utf-8'
end