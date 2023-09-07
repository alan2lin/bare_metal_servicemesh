iptables -t nat -D PREROUTING -p tcp -j CLASH
iptables -t nat -D OUTPUT -p udp --dport 53 -j CLASH_DNS
iptables -t nat -D PREROUTING -p udp --dport 53 -j CLASH_DNS
iptables -t nat -F CLASH
iptables -t nat -X CLASH
iptables -t nat -F CLASH
iptables -t nat -X CLASH_DNS
