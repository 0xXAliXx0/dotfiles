#!/bin/bash
LOG_FILE="$(dirname "$0")/start-tor.log"
{
    echo "$(date): Starting Tor with bypass rules..."
    sudo iptables -t nat -I OUTPUT -m owner --uid-owner tor -j RETURN
    sudo iptables -I OUTPUT -m owner --uid-owner tor -j ACCEPT
    sudo systemctl start tor
    echo "$(date): Tor startup completed"
sleep 2   
    echo "$(date): Restarting NetworkManager..."
    sudo systemctl restart NetworkManager
    echo "$(date): NetworkManager restart completed"
    sleep 2
    echo "$(date): Restarting Tor..."
    sudo systemctl restart tor
    echo "$(date): Tor restart completed"
} 2>&1 | tee -a "$LOG_FILE"
