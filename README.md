# Docker do Hand View

## Introdução

Esse docker vem com o nginx + mysql e todas as outras ferramentas pré-instaladas pra rodar o Hand View.

## VirtualBox - Sem boot2docker

###  Instalação Docker

Instale o Ubuntu Server e o SSH com um user docker.

Instale o Docker:

http://docs.docker.com/installation/ubuntulinux/

<pre>
wget -qO- https://get.docker.com/ | sh
sudo usermod -aG docker docker
</pre>

Mude o adaptador do VirtualBox pra "Bridged Adapter". Crie um novo do tipo "NAT".

Adicione isso no arquivo /etc/network/interfaces do  Ubuntu
<pre>
allow-hotplug eth1
iface eth1 inet dhcp
</pre>

Para descobrir o IP do VirtualBox;

<pre>
VBoxManage guestproperty get "ubuntu-docker" "/VirtualBox/GuestInfo/Net/0/V4/IP"
</pre>

<h3>Configurando Server - Ubuntu</h3>

https://docs.docker.com/articles/https/

http://www.centurylinklabs.com/tutorials/docker-on-the-mac-without-boot2docker/

Crie os certificados de segurança.
<pre>
mkdir /home/docker/.docker
cd /home/docker/.docker
#coloque uma senha
openssl genrsa -aes256 -out ca-key.pem 4096
#pedira a senha de cima, em Common Name coloque localhost
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
openssl genrsa -out server-key.pem 4096
openssl req -subj "/CN=localhost" -sha256 -new -key server-key.pem -out server.csr
echo subjectAltName = IP:10.10.10.20,IP:127.0.0.1 > extfile.cnf
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile.cnf
#Para o client
openssl genrsa -out key.pem 4096
openssl req -subj '/CN=client' -new -key key.pem -out client.csr
echo extendedKeyUsage = clientAuth > extfile.cnf
openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile.cnf
rm -v client.csr server.csr
chmod -v 0400 ca-key.pem key.pem server-key.pem
chmod -v 0444 ca.pem server-cert.pem cert.pem
</pre>

Adicione no arquivo /etc/rc.local:
<pre>
service docker stop
docker -d --tlsverify --tlscacert=/home/docker/.docker/ca.pem --tlscert=/home/docker/.docker/server-cert.pem --tlskey=/home/docker/.docker/server-key.pem  -H=0.0.0.0:2376 &
</pre>

### Configurando Client - MAC

Copie os arquivos <b>ca.pem</b>, <b>cert.pem</b> e <b>key.pem</b> do Ubuntu para ~/.docker/certs

Adicione no arquivo ~/.profile

<pre>
export DOCKER_HOST=tcp://127.0.0.1:2376
export DOCKER_CERT_PATH=~/.docker/certs
export DOCKER_TLS_VERIFY=1
</pre>
<h3>Redirecionamento de Portas</h3>

Crie os redirecionamentos de portas no VirtualBox:

2222 -> 22 - SSH

2376 -> 2376 - DOCKER

## VMware Fusion - MAC

Para ter o boot2docker pré-instalado com o VMware Tools (necessário para compartilhar pasta com a VM), use essa ISO:

https://github.com/cloudnativeapps/boot2docker/releases/

Baixe ela e coloque em seu localhost.
<pre>
docker-machine create --driver vmwarefusion --vmwarefusion-boot2docker-url http://localhost/boot2docker-1.6.0-vmw.iso dev
</pre>

Para compartilhar usando link simbólico, adicionar isso no arquivo .vmx:

<b>sharedFolder0.followSymlinks = "TRUE"</b>
