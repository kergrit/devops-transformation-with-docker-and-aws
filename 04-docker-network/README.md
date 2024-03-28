# 04-docker-network

```sh
#list docker network
docker network ls
...
NETWORK ID     NAME                 DRIVER    SCOPE
7a8184db49f9   bridge               bridge    local
48c980201322   host                 host      local
k4cl1z21g301   ingress              overlay   swarm
359adf786969   none                 null      local
...

#create docker network (devops)
docker network create devops --driver bridge
docker network ls | grep  devops
...
NETWORK ID     NAME                 DRIVER    SCOPE
bb41738a2184   devops               bridge    local
...

#run mariadb container inside devops network
docker run --name devops-mariadb --network devops -p 33069:3306 -e MARIADB_ROOT_PASSWORD=my-secret-pw -v $(pwd)/mariadb:/var/lib/mysql -d mariadb:latest

#run nginx container inside devops network
docker run --name devops-app --network devops -d nginx:latest

#run nginx container outside devops network
docker run --name bridge-app -d nginx:latest

#install mariadb-client bridge-app, devops-app
docker exec -it bridge-app apt update &&
docker exec -it bridge-app apt install mariadb-client -y &&
docker exec -it devops-app apt update &&
docker exec -it devops-app apt install mariadb-client -y

#test connection bridge-app and devops-mariadb
docker exec -it bridge-app mariadb -h devops-mariadb -u root -pmy-secret-pw
...
ERROR 2005 (HY000): Unknown server host 'devops-mariadb' (-2)
...

#test connection devops-app and devops-mariadb
docker exec -it devops-app mariadb -h devops-mariadb -u root -pmy-secret-pw
...
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 3
Server version: 11.3.2-MariaDB-1:11.3.2+maria~ubu2204 mariadb.org binary distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> 
...
```