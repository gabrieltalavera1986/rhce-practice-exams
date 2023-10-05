#!/bin/bash

host="web01"

# Check if httpd package is installed
httpd_installed=$(ssh "$host" "rpm -q httpd")
if [[ $? -ne 0 ]]; then
    echo "httpd package is not installed on $host."
    exit 1
else
    echo "httpd is installed on $host."
fi

# Check if httpd service is running
httpd_active=$(ssh "$host" "systemctl is-active httpd")
if [[ $httpd_active != "active" ]]; then
    echo "httpd service is not running on $host."
    exit 1
else
    echo "httpd service is active on $host."
fi

# Check if httpd service is enabled
httpd_enabled=$(ssh "$host" "systemctl is-enabled httpd")
if [[ $httpd_enabled != "enabled" ]]; then
    echo "httpd service is not enabled on $host."
    exit 1
else
    echo "httpd service is enabled on $host."
fi

# Check firewall rule for HTTP traffic
firewall_http=$(ssh "$host" "sudo firewall-cmd --list-services | grep -q http && echo 'enabled'")
if [[ $firewall_http != "enabled" ]]; then
    echo "Firewall rule for HTTP traffic is not set on $host."
    exit 1
else
    echo "Firewall rule for HTTP traffic is enabled on $host."
fi

# Use curl to fetch content from the web server
web_content=$(ssh "$host" "curl -s http://localhost")
if [[ ! $web_content =~ "Servername:" ]] || [[ ! $web_content =~ "IP Address:" ]] || \
   [[ ! $web_content =~ "Free Memory:" ]] || [[ ! $web_content =~ "OS:" ]] || \
   [[ ! $web_content =~ "Kernel Version:" ]]; then
    echo "System information is not correctly set in the web server response on $host."
    exit 1
fi

echo "All settings are correctly configured on $host!"
exit 0
