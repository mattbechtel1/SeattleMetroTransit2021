# Metrobus2020
 Seattle Metrobus Tracker

## Backend Setup

From the `backend/` directory, run the setup rake task to migrate the database and load all GTFS data:

```bash
rake setup
```

To skip the final cleanup of downloaded GTFS files (e.g. for debugging):

```bash
rake setup -- --no-cleanup
```

## Refreshing GTFS Data

To re-download and reload all GTFS static data (routes, stops, schedules) into the database, run from the project root:

```bash
./setup.sh
```

This runs `rake update_gtfs_data:update_all`, which clears all transit tables, downloads fresh ZIP feeds from King County Metro and Sound Transit, parses and bulk-inserts the data, then cleans up the downloaded files.

## Running the App

From the project root, start both the frontend PHP server (port 8001) and the backend Rails server (port 3000) with:

```bash
./start.sh
```

Press `Ctrl+C` to stop both servers.