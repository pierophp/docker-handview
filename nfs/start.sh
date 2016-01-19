# eval "$(docker-machine env)"
docker run -d \
     -p 2049:2049 \
     -v /home/docker:/docker \
     --name nfs \
     --hostname nfs \
     pierophp/nfs
