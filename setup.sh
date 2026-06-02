#!/bin/bash

(cd backend && rake update_gtfs_data:update_all)

redis-cli flushall

pwd
