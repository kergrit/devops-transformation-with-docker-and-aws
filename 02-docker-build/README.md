# 02-docker-build

This simple way to build docker image

```sh
#folder structure
.
├── Dockerfile
├── README.md
└── www
    └── index.html
```


```yaml
#./Dockerfile

FROM nginx:latest

WORKDIR /usr/share/nginx/html

COPY ./www ./

```

```sh
#build custom-nginx docker container
docker build -t kergrit/custom-nginx ./Dockerfile

#run nginx-custom container
docker run --name nginx-custom -p 8088:80 -d kergrit/custom-nginx

#test 
curl  http://localhost:8088

#stop and remove nginx-custom conainer
docker stop nginx-custom && docker rm nginx-custom

#push docker image to DockerHub 
docker push kergrit/custom-nginx

#pull docker image from DockerHub
docker pull kergrit/custom-nginx
```