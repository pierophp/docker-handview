eval "$(docker-machine env)"
docker run -d \
     -p 2222:22 \
     -p 80:80 \
     -p 3306:3306 \
     -v /mnt/hgfs/www/handview:/var/www/handview \
     -v /mnt/hgfs/www/videos_handview/biblia:/var/www/handview/biblia \
     -v /mnt/hgfs/www/videos_handview/canticos:/var/www/handview/canticos \
     --name handview \
     --hostname handview \
     pierophp/handview
