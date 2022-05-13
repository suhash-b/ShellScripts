#!/bin/bash
# Based on a template iptables config file, create a new
# iptables file that includes whitelist rules for CloudFlare's
# servers to connect to our HTTP and HTTPS ports. This is useful
# if you want to really lock down your web server so that it only
# communicates with cloudflare's servers, not with the general public.
# It works like this:
# * Get an up-to-date list of CloudFlare's server IPs
# * Read in config template from /etc/sysconfig/iptables.template
# * Output an iptables configuration file /etc/sysconfig/iptables
#    ( $CFRULES from the template file becomes the CloudFlare whitelist rules in the output.)
# * Restart iptables to load the new firewall rules -- only does this if the rules got updated.
##
# Make sure you have:
# * An /etc/sysconfig/iptables.template file containing all your iptables rules.
#   It should look very similar to /etc/sysconfig/iptables, so I suggest
#   "cp /etc/sysconfig/iptables /etc/sysconfig/iptables.template" as a first step.
# * A line containing only $CFRULES somewhere in your iptables.template file
# * Either ":INPUT DROP [0:0]" at the top of your iptables.template,
#   or some rule below $CFRULES that blocks all input traffic to your ports 80/443.
# Note this REPLACES your /etc/sysconfig/iptables file.
# Again, before running the script, you should probably just
# "cp /etc/sysconfig/iptables /etc/sysconfig/iptables.template", then drop a $CFRULES line in there.
 
IPT_TEMP=/tmp/iptables.new
CFRULES=""
IPS=$(curl --max-time 10 --silent -S https://api.cloudflare.com/client/v4/ips | tr ']' '\n' |grep ipv4_cidrs |tr '[' '\n' |grep '\/' |tr ',' '\n' |sed 's/"//g' |sed 's/\\//g')
if [ "$?" = "0" ]; then
        for line in $IPS; do
                line=$(echo "$line" | tr -c --delete "[:digit:]./")
                CFRULES+="-A INPUT -p tcp -m multiport --dports 80,443 -s $line -j ACCEPT
"
        done
        eval "cat <<< \"$(</root/cloudflare/iptables.template)\"" > $IPT_TEMP
        diff -q $IPT_TEMP /etc/sysconfig/iptables
        if [ -s $IPT_TEMP -a "$?" = "1" ]; then
                mv -f $IPT_TEMP /etc/sysconfig/iptables
                service iptables restart
        else
                rm -f $IPT_TEMP
        fi
fi
