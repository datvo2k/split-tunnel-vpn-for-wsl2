#!/bin/bash

echo "**** Patching Wireguard ****"

# Path to the wg-quick script
WG_QUICK_PATH="/usr/bin/wg-quick"

# Check if the wg-quick script exists
if [[ ! -f "$WG_QUICK_PATH" ]]; then
    echo "Error: $WG_QUICK_PATH not found."
    exit 1
fi

# Use sed to remove "| cmd $iptables-restore -n"
# Note: Because the pattern includes special characters, use a delimiter (e.g., '|') that does not appear in the pattern
sed -i 's|\| cmd \$iptables-restore -n||g' "$WG_QUICK_PATH"

# Check if the sed command was successful
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to modify $WG_QUICK_PATH."
    exit 1
fi

echo "Modification complete. Removed '| cmd \$iptables-restore -n' from $WG_QUICK_PATH. Wireguard should now work."

# Start WireGuard
wg-quick up /etc/wireguard/wg0.conf

# Wait for WireGuard interface to be up
sleep 1

exec /usr/local/bin/3proxy /etc/3proxy/3proxy.cfg