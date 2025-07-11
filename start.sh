#!/bin/bash

while true; do
    echo "Starting paper.jar..."
    java -jar paper.jar nogui
    echo "Server crashed or stopped. Relaunching in 15 seconds..."
    echo "If you want to stop the server, press Ctrl+C."
    sleep 15
done