sudo docker run --name Clash -d -v /home/pi/clash/conf/clash/config.yaml:/root/.config/clash/config.yaml --network="host" --privileged dreamacro/clash
sudo docker run -p 1234:80 -d haishanh/yacd
sudo sh ./script/iptable_forward.sh
