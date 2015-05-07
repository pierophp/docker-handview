docker-machine create --driver vmwarefusion --vmwarefusion-boot2docker-url http://localhost/boot2docker-1.6.0-vmw.iso dockervmware
echo "`docker-machine ip` handview" | sudo tee -a  /etc/hosts