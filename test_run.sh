#!/bin/bash

#1. Kill any existing processes on these ports to be safe
pkill -f "./bin/server"
pkill -f "./bin/lb"

echo "Killed existing processes."

#2. Build the binaries
go build -o bin/lb ./lb
go build -o bin/server ./server

echo "Built binaries."

#3. Start servers
./bin/server -port 8081 -name "Server-1" & PID1=$!
./bin/server -port 8082 -name "Server-2" & PID2=$!
./bin/server -port 8083 -name "Server-3" & PID3=$!

echo "Started servers with PIDs: $PID1, $PID2, $PID3"

#4. Start Load Balancer
./bin/lb -port 3030 -backends "http://localhost:8081,http://localhost:8082,http://localhost:8083" &
LB_PID=$!

echo "Started Load Balancer with PID: $LB_PID"

# Give them a moment to start
sleep 2

#5. Test cases

# "------------------------------------------------"
# "Test 1: Sequential Requests"
# "------------------------------------------------"
echo "Sending 8 sequential requests..."
for i in {1..8}; do
    curl -s "http://localhost:3030"
done

# "------------------------------------------------"
# "Test 2: Concurrent Requests (100 requests)"
# "------------------------------------------------"
echo "Sending 100 concurrent requests..."
(
  for i in {1..100}; do
    curl -s "http://localhost:3030" &
  done
  wait
)

echo "Requests completed."

#6. Clean up
kill $PID1 $PID2 $PID3 $LB_PID
echo "Cleaned up processes."
