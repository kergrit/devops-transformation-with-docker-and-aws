# 05-multiple-containers


```sh
#folder structure
.
├── README.md
├── docker-compose.yaml
└── mariadb
```

```yaml
#docker-compose.yaml
version: "3"
services:
  devops-nginx:
    image: nginx
    ports:
      - 8088:80
    networks:
      - devops

  devops-mariadb:
    image: mariadb
    environment:
      - MARIADB_ROOT_PASSWORD=my-secret-pw
    ports:
      - 33069:3306
    volumes:
      - ./mariadb:/var/lib/mysql
    networks:
      - devops

networks:
  devops:
    driver: bridge
```

```sh
#start docker-compose
docker-compose -f docker-compose.yaml up -d
...
[+] Running 3/3
 ⠿ Network 05-multiple-containers_devops              Created                                                                                                        0.1s
 ⠿ Container 05-multiple-containers-devops-nginx-1    Started                                                                                                        0.9s
 ⠿ Container 05-multiple-containers-devops-mariadb-1  Started 
...

#list docker network
docker network ls | grep 05-multiple-containers_devops 
...
NETWORK ID     NAME                            DRIVER    SCOPE
160bf6d46e15   05-multiple-containers_devops   bridge    local
...

#list docker-compose
docker-compose ls
...
NAME                     STATUS              CONFIG FILES
05-multiple-containers   running(2)          /Users/kergritrobkop/Desktop/devops-transformation-with-docker-and-aws-course/05-multiple-containers/docker-compose.yaml
...

#show logs
docker-compose -f docker-compose.yaml logs -f

#stop docker-compose
docker-compose -f docker-compose.yaml down
```