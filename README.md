<h1>Docker do Hand View</h1>

<h2>Introdução</h2>

Esse docker vem com o nginx + mysql e todas as outras ferramentas pré-instaladas pra rodar o Hand View.

<h2>VirtualBox - Sem boot2docker</h2>

<h3>Instalação Docker</h3>

Instale o Ubuntu Server e o SSH.

Instale o Docker com um user docker:

http://docs.docker.com/installation/ubuntulinux/

<pre>

wget -qO- https://get.docker.com/ | sh

sudo usermod -aG docker docker

</pre>

Crie um novo adaptador de rede do tipo "Bridged Adapter".

O primeiro deve estar como "NAT".

Adicione isso no arquivo /etc/network/interfaces do  Ubuntu

allow-hotplug eth1

iface eth1 inet dhcp

Para descobrir o IP do VirtualBox;

VBoxManage guestproperty get "ubuntu-docker" "/VirtualBox/GuestInfo/Net/0/V4/IP"

<h3>Configurando Server - Ubuntu</h3>

https://docs.docker.com/articles/https/

Crie os certificados de segurança.

http://www.centurylinklabs.com/tutorials/docker-on-the-mac-without-boot2docker/

Adicione no arquivo /etc/rc.local:

service docker stop

docker -d --tlsverify --tlscacert=/home/docker/.docker/ca.pem --tlscert=/home/docker/.docker/server-cert.pem --tlskey=/home/docker/.docker/server-key.pem  -H=0.0.0.0:2376 &

<h3>Configurando Client - MAC</h3>

Copie os 3 arquivos de certificado  para ~/.docker/certs

ca.pem

cert.pem

key.pem

Adicione no arquivo ~/.profile

export DOCKER_HOST=tcp://127.0.0.1:2376

export DOCKER_CERT_PATH=~/.docker/certs

export DOCKER_TLS_VERIFY=1

<h3>Redirecionamento de Portas</h3>

Crie os redirecionamentos de portas no VirtualBox:

2222 -> 22 - SSH

2376 -> 2376 - DOCKER

<h2>VMware Fusion - MAC</h2>

Para ter o boot2docker pré-instalado com o VMware Tools (necessário para compartilhar pasta com a VM), use essa ISO:

https://github.com/cloudnativeapps/boot2docker/releases/

Baixe ela e coloque em seu localhost.

docker-machine create --driver vmwarefusion --vmwarefusion-boot2docker-url http://localhost/boot2docker-1.6.0-vmw.iso dev

Para compartilhar usando link simbólico, adicionar isso no arquivo .vmx:

<b>sharedFolder0.followSymlinks = "TRUE"</b>
