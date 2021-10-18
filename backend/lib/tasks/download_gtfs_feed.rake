require 'open-uri'
require 'zip'
require 'csv'

GTFS_FEED_URL = "https://metro.kingcounty.gov/GTFS/google_transit.zip"
ZIP_LOCATION = 'public/google_transit.zip'
EXTRACTED_LOCATION = 'public/google_transit/'

namespace :download_gtfs_feed do
    desc "This task downloads the gtfs data"
    task :download_file do
        open(ZIP_LOCATION, 'wb') do |file|
            file << open(GTFS_FEED_URL).read
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

    task :parse_files => [:environment] do 
        agency_copy
        fare_attributues_copy
    end

    task :cleanup do
        FileUtils.rm_rf(EXTRACTED_LOCATION) if File.directory?(EXTRACTED_LOCATION)
        File.delete(ZIP_LOCATION) if File.exist?(ZIP_LOCATION)
    end
end

def agency_copy
    Agency.delete_all
    Agency.copy_from "#{EXTRACTED_LOCATION}/agency.txt", :map => {
        'agency_id' => 'id',
        'agency_name' => 'name',
        'agency_url' => 'url',
        'agency_timezone' => 'timezone',
        'agency_lang' => 'language',
        'agency_phone' => 'phone',
        'agency_fare_url' => 'fare_url',
        :null => '',
    }
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
    }
end