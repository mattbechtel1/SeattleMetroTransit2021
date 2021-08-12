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

    task :parse_file do 
        Dir.glob("#{EXTRACTED_LOCATION}/*.txt").each do |f|
            array = CSV.parse(File.read(f), headers: true)
            puts f
            puts array[1]
            puts '------'
        end
    end

    task :cleanup do
        FileUtils.rm_rf(EXTRACTED_LOCATION) if File.directory?(EXTRACTED_LOCATION)
        File.delete(ZIP_LOCATION) if File.exist?(ZIP_LOCATION)
    end
end
