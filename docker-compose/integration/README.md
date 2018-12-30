# Generate ssl cert using letsencrypt
sudo certbot certonly --manual -d *.mcs.cb4.info

# Query container IP
sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' integration_ups_1
