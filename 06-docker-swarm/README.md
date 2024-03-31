# 06-docker-swarm

In this section we use https://multipass.run/ as vm for demo docker swarm cluster.

refs. https://dev.to/mattdark/docker-swarm-with-virtual-machines-using-multipass-39b0 and update script to present.

```sh
#file structure
.
├── README.md
├── docker-compose.yaml
├── init-instance.sh
└── install-docker.sh
```

### MULTIPASS VM PREPARE

init-instance.sh
```sh
NM=$1

multipass launch --name ${NM} jammy --memory 512M --disk 5G --cpus 1

multipass transfer install-docker.sh ${NM}:/home/ubuntu/install-docker.sh
multipass exec ${NM} -- sh -x /home/ubuntu/install-docker.sh
```

install-docker.sh
```sh
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu/  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install latest version
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose

# Manage Docker as a non-root user
## Create the docker group
sudo groupadd docker

## Add your user to the docker group
sudo usermod -aG docker $USER

## Enable the docker daemon to run on system boot
sudo systemctl enable docker
```

start create multipass vm x 4 instance with
```sh
sh -x init-instance.sh manager-1 && sh -x init-instance.sh manager-2 && sh -x init-instance.sh worker-1 && sh -x init-instance.sh worker-2
```

### DOCKER SWARM INIT
create swarm cluster with 2 options via multipass or shell into vm instance
```sh
multipass exec manager-1 -- docker swarm init
#or
multipass shell manager-1
docker swarm init

...
Swarm initialized: current node (orlqfgi5jwyyrxy9jsnp65qiy) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-39ct0xgkwy72orusf19ymukfef9phxju3csrpxl1nab1fdt903-a7heoarrbv521ke7ucug2g85v 192.168.64.21:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
...

#list nodes in cluster
multipass exec manager-1 -- docker node ls
...
ID                            HOSTNAME    STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
mb45nxdkq79bcg89w3vi3rzst *   manager-1   Ready     Active         Leader           26.0.0
...
```

get token for join manager
```sh
#get join-token manager
multipass exec manager-1 -- docker swarm join-token manager

...
To add a manager to this swarm, run the following command:

   docker swarm join --token SWMTKN-1-39ct0xgkwy72orusf19ymukfef9phxju3csrpxl1nab1fdt903-8o07w5304k47uwhwevwfvqq22 192.168.64.21:2377
...
```

add manager node to the cluster
```sh
#add manager-2 node in cluster
multipass exec manager-2 -- docker swarm join --token SWMTKN-1-39ct0xgkwy72orusf19ymukfef9phxju3csrpxl1nab1fdt903-8o07w5304k47uwhwevwfvqq22 192.168.64.21:2377

...
5mowa6jimdo8icowabshls 192.168.64.21:2377
This node joined a swarm as a manager.
...

#list nodes in cluster
multipass exec manager-1 -- docker node ls
...
ID                            HOSTNAME    STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
mb45nxdkq79bcg89w3vi3rzst *   manager-1   Ready     Active         Leader           26.0.0
20ebn21gyb1yxulzloyykaay2     manager-2   Ready     Active         Reachable        26.0.0
...
```

add worker node to the cluster
```sh
#add worker-1 node in cluster
multipass exec worker-1 -- docker swarm join --token SWMTKN-1-39ct0xgkwy72orusf19ymukfef9phxju3csrpxl1nab1fdt903-a7heoarrbv521ke7ucug2g85v 192.168.64.21:2377

...
This node joined a swarm as a worker.
...

#add worker-2 node in cluster
multipass exec worker-2 -- docker swarm join --token SWMTKN-1-39ct0xgkwy72orusf19ymukfef9phxju3csrpxl1nab1fdt903-a7heoarrbv521ke7ucug2g85v 192.168.64.21:2377

...
This node joined a swarm as a worker.
...

#list nodes in cluster
multipass exec manager-1 -- docker node ls

...
ID                            HOSTNAME    STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
mb45nxdkq79bcg89w3vi3rzst *   manager-1   Ready     Active         Leader           26.0.0
20ebn21gyb1yxulzloyykaay2     manager-2   Ready     Active         Reachable        26.0.0
p36lrav9egddau4bv5fr6s0t1     worker-1    Ready     Active                          26.0.0
r5893mrr0ny06i5fzembm85z1     worker-2    Ready     Active                          26.0.0
...
```

## DOCKER SWARM RUN

```sh
#copy docker-compose file to manager-1
multipass transfer docker-compose.yaml manager-1:/home/ubuntu/docker-compose.yaml

#run app service on docker swarm using docker stack deploy
multipass exec manager-1 -- docker stack deploy -c docker-compose.yaml mystack
...
Creating network mystack_default
Creating service mystack_app
...

#list docker swarm stack
multipass exec manager-1 -- docker stack ls
...
NAME      SERVICES
mystack   1
...

#list service in swarm stack
multipass exec manager-1 -- docker service ls
...
ID             NAME          MODE         REPLICAS   IMAGE          PORTS
sy5tgl2ddpm6   mystack_app   replicated   4/4        nginx:latest   
...

#list process in swarm stack service
multipass exec manager-1 -- docker service ps mystack_app
...
ID             NAME            IMAGE          NODE       DESIRED STATE   CURRENT STATE                ERROR     PORTS
7iqumcsn8dp8   mystack_app.1   nginx:latest   worker-1   Running         Running about a minute ago             
0o19seprz8t6   mystack_app.2   nginx:latest   worker-2   Running         Running about a minute ago             
ajwg063vg8hs   mystack_app.3   nginx:latest   worker-1   Running         Running about a minute ago             
7ibqr0l2hwrc   mystack_app.4   nginx:latest   worker-2   Running         Running about a minute ago             
...

#scale service in swarm stack
multipass exec manager-1 -- docker service scale mystack_app=6
multipass exec manager-1 -- docker service ps mystack_app
...
ID             NAME            IMAGE          NODE       DESIRED STATE   CURRENT STATE            ERROR     PORTS
7iqumcsn8dp8   mystack_app.1   nginx:latest   worker-1   Running         Running 4 minutes ago              
0o19seprz8t6   mystack_app.2   nginx:latest   worker-2   Running         Running 4 minutes ago              
ajwg063vg8hs   mystack_app.3   nginx:latest   worker-1   Running         Running 4 minutes ago              
7ibqr0l2hwrc   mystack_app.4   nginx:latest   worker-2   Running         Running 4 minutes ago              
jdlmfu0ejbwb   mystack_app.5   nginx:latest   worker-2   Running         Running 27 seconds ago             
ty8mq4orhzce   mystack_app.6   nginx:latest   worker-1   Running         Running 27 seconds ago           
...

#test service recovery
multipass exec worker-1 -- docker ps
...
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS     NAMES
e50795491ae2   nginx:latest   "/docker-entrypoint.…"   3 minutes ago   Up 3 minutes   80/tcp    mystack_app.6.ty8mq4orhzceyylpwvp5ualm4
acfd95b7ed21   nginx:latest   "/docker-entrypoint.…"   7 minutes ago   Up 7 minutes   80/tcp    mystack_app.3.ajwg063vg8hswz5k3i5ywcj6s
e478ff65e62c   nginx:latest   "/docker-entrypoint.…"   7 minutes ago   Up 7 minutes   80/tcp    mystack_app.1.7iqumcsn8dp8uwdqze46ayad8
...

# stop service container on worker node "worker-1"
multipass exec worker-1 -- docker stop mystack_app.1.7iqumcsn8dp8uwdqze46ayad8
multipass exec manager-1 -- docker service ps mystack_app
...
ID             NAME                IMAGE          NODE       DESIRED STATE   CURRENT STATE             ERROR     PORTS
cabzygyeriul   mystack_app.1       nginx:latest   worker-1   Running         Running 35 seconds ago              
7iqumcsn8dp8    \_ mystack_app.1   nginx:latest   worker-1   Shutdown        Complete 40 seconds ago             
0o19seprz8t6   mystack_app.2       nginx:latest   worker-2   Running         Running 10 minutes ago              
ajwg063vg8hs   mystack_app.3       nginx:latest   worker-1   Running         Running 10 minutes ago              
7ibqr0l2hwrc   mystack_app.4       nginx:latest   worker-2   Running         Running 10 minutes ago              
jdlmfu0ejbwb   mystack_app.5       nginx:latest   worker-2   Running         Running 6 minutes ago               
ty8mq4orhzce   mystack_app.6       nginx:latest   worker-1   Running         Running 6 minutes ago  
...

##remove app service on docker swarm using docker stack rm
multipass exec manager-1 -- docker stack rm mystack
...
Removing service mystack_app
Removing network mystack_default
...
```

clean up multipass vm instance
```sh
multipass delete -p  manager-1  manager-2 worker-1 worker-2 
```