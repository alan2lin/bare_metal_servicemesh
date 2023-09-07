sudo docker stop my-webproxy 
sudo docker rm my-webproxy 
sudo docker run -d -p 80:80 --name my-webproxy  -v /k8s_install/node_proxy/my-proxy.conf:/etc/nginx/nginx.conf:ro nginx:1.25.2
