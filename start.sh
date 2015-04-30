# docker-machine create --driver vmwarefusion --vmwarefusion-boot2docker-url http://localhost/boot2docker-1.6.0-vmw.iso dockervmware
echo "`boot2docker ip` handview" | sudo tee -a  /etc/hosts
docker run -d -p 2222:22 -p 80:80 -v /var/www/handview:/var/www/handview --name handview --hostname handview pierophp/handview