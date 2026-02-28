desc "Run DB migration and update GTFS data. Pass -- --no-cleanup to skip the final cleanup step."
task :setup => [:environment] do
  no_cleanup = ARGV.include?('--no-cleanup')

  Rake::Task["db:migrate"].invoke

  Rake::Task["download_gtfs_feed:cleanup"].execute
  Rake::Task["download_gtfs_feed:download_file"].execute
  Rake::Task["download_gtfs_feed:unzip_feed"].execute
  Rake::Task["download_gtfs_feed:download_st_file"].execute
  Rake::Task["download_gtfs_feed:unzip_st_feed"].execute
  Rake::Task["download_gtfs_feed:parse_files"].execute

  Rake::Task["download_gtfs_feed:cleanup"].execute unless no_cleanup
end
