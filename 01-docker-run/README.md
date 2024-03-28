# 01-docker-run

This simple way to run docker container

```sh
#run nginx docker container
docker run --name nginx -p 8088:80 -d nginx:latest

#list docker process
docker ps

#display nginx container logs
docker logs -f nginx

#stop and remove nginx docker container
docker stop nginx && docker rm nginx

```