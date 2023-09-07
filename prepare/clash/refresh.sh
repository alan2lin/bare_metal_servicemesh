sudo docker stop `sudo docker ps -a|awk '{print $1}'`
sudo docker rm `sudo docker ps -a|awk '{print $1}'`
sudo docker run --name Clash -d -v /home/pi/clash/conf/clash/config.yaml:/root/.config/clash/config.yaml --network="host" --privileged dreamacro/clash
sudo docker run -p 1234:80 -d haishanh/yacd
