#!/bin/bash
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to-destination 10.244.0.34
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.244.0.34
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 2222 -j DNAT --to-destination 10.244.0.34
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 4443 -j DNAT --to-destination 10.244.0.34
