#!/bin/bash

# Network Quick Fix Script
# Run this script whenever you need to fix network connectivity

echo "=== Network Quick Fix ==="
echo "Applying network configuration..."

# Set default route
echo "Setting default route..."
sudo ip route add default via 192.168.1.1 dev enp5s0 2>/dev/null || echo "Route already exists"

# Set DNS servers
echo "Setting DNS servers..."
sudo resolvectl dns enp5s0 1.1.1.1 8.8.8.8

# Flush DNS cache
echo "Flushing DNS cache..."
sudo resolvectl flush-caches

# Renew DHCP lease
echo "Renewing DHCP lease..."
sudo dhclient enp5s0

# Test connectivity
echo ""
echo "=== Testing connectivity ==="
echo "Testing router connectivity..."
if ping -c2 -W2 192.168.1.1 &>/dev/null; then
    echo "✓ Router reachable"
else
    echo "✗ Router not reachable"
fi

echo "Testing DNS resolution..."
if ping -c2 -W2 8.8.8.8 &>/dev/null; then
    echo "✓ DNS servers reachable"
else
    echo "✗ DNS servers not reachable"
fi

echo "Testing internet connectivity..."
if ping -c2 -W2 google.com &>/dev/null; then
    echo "✓ Internet working"
else
    echo "✗ Internet not working"
fi

echo ""
echo "=== Network fix complete ==="
echo "Current network status:"
echo "IP: $(ip addr show enp5s0 | grep 'inet ' | awk '{print $2}' | head -1)"
echo "Gateway: $(ip route show default | awk '{print $3}' | head -1)"
echo "DNS: 1.1.1.1, 8.8.8.8"
