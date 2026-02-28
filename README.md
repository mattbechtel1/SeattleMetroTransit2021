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

## Running the App

From the project root, start both the frontend PHP server (port 8001) and the backend Rails server (port 3000) with:

```bash
./start.sh
```

Press `Ctrl+C` to stop both servers.