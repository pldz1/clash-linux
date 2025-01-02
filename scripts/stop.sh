#!/bin/bash

# Check if the Clash service is running by looking for the 'clash-linux-a' process
PID_NUM=$(ps -ef | grep [c]lash-linux-a | wc -l)
PID=$(ps -ef | grep [c]lash-linux-a | awk '{print $2}')

# If the Clash process is running (PID_NUM > 0), kill the process
if [ $PID_NUM -ne 0 ]; then
    # Terminate the process with SIGKILL (kill -9)
    kill -9 $PID
    # Alternatively, you can use the following line to directly kill the process
    # ps -ef | grep [c]lash-linux-a | awk '{print $2}' | xargs kill -9
fi

# Print a success message
echo -e "Service successfully stopped."
