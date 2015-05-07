<h1>Docker do Hand View</h1>

<h2>Introdução</h2>

Esse docker vem com o nginx + mysql e todas as outras ferramentas pré-instaladas pra rodar o Hand View.

<h2>VMware Fusion</h2>

Para ter o boot2docker pré-instalado com o VMware Tools, use essa ISO:

https://github.com/cloudnativeapps/boot2docker/releases/

Baixe ela e coloque em seu localhost.

docker-machine create --driver vmwarefusion --vmwarefusion-boot2docker-url http://localhost/boot2docker-1.6.0-vmw.iso dev

Para compartilhar usando link simbólico, adicionar isso no arquivo .vmx:

<b>sharedFolder0.followSymlinks = "TRUE"</b>
