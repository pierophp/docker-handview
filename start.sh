eval "$(docker-machine env)"
docker run -d \
     -p 2222:22 \
     -p 80:80 \
     -p 3306:3306 \
     -v /mnt/hgfs/www/handview:/var/www/handview \
     --name handview \
     --hostname handview \
     pierophp/handview
