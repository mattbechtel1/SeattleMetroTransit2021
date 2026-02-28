#!/bin/bash

# Start PHP server for frontend on port 8001
(cd frontend && php -S localhost:8001) &
PHP_PID=$!

# Start Rails server for backend on port 3000
(cd backend && bin/rails server -p 3000) &
RAILS_PID=$!

echo "PHP server running on http://localhost:8001 (PID $PHP_PID)"
echo "Rails server running on http://localhost:3000 (PID $RAILS_PID)"
echo "Press Ctrl+C to stop both servers."

sleep 1
if command -v xdg-open &>/dev/null; then
    xdg-open http://localhost:8001
elif command -v open &>/dev/null; then
    open http://localhost:8001
fi

trap "kill $PHP_PID $RAILS_PID" EXIT
wait
