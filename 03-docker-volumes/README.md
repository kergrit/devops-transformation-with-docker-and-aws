# 03-docker-volumes

```sh
#folder structure
.
├── README.md
└── mariadb
```

**Docker volumes**
- Host volumes
- Anonymouse volumes
- Named volumes

```sh
#run mariadb container with host volumes
docker run --name mariadb-host-vol -e MARIADB_RANDOM_ROOT_PASSWORD=1 -v $(pwd)/mariadb:/var/lib/mysql/data -d mariadb:latest 

#inspect mariadb-host-vol container
docker inspect mariadb-host-vol
...
"Mounts": [
  {
    "Type": "bind",
    "Source": "/Users/kergritrobkop/Desktop/devops-transformation-with-docker-and-aws-course/03-docker-volumes/mariadb",
    "Destination": "/var/lib/mysql/data",
    "Mode": "",
    "RW": true,
    "Propagation": "rprivate"
  },
  {
    "Type": "volume",
    "Name": "b15008f4dd86266048847cd7ddeffc64edf1d53029881d831c0cca757b8cb14d",
    "Source": "/var/lib/docker/volumes/b15008f4dd86266048847cd7ddeffc64edf1d53029881d831c0cca757b8cb14d/_data",
    "Destination": "/var/lib/mysql",
    "Driver": "local",
    "Mode": "",
    "RW": true,
    "Propagation": ""
  }
]
...

#stop and remove mariadb-host-vol container
docker stop mariadb-host-vol && docker rm mariadb-host-vol
```

```sh
#run mariadb container with anonymouse volumes
docker run --name mariadb-anonymouse-vol -e MARIADB_RANDOM_ROOT_PASSWORD=1 -v /var/lib/mysql/data -d mariadb:latest

#inspect mariadb-anonymouse-vol container
docker inspect mariadb-anonymouse-vol
...
"Mounts": [
  {
    "Type": "volume",
    "Name": "6ab741c456c7b06724470d7db6c56348e6b98df8b4d1cc7df7d8b32af37cde95",
    "Source": "/var/lib/docker/volumes/6ab741c456c7b06724470d7db6c56348e6b98df8b4d1cc7df7d8b32af37cde95/_data",
    "Destination": "/var/lib/mysql/data",
    "Driver": "local",
    "Mode": "",
    "RW": true,
    "Propagation": ""
  },
  {
    "Type": "volume",
    "Name": "0a2bed92659ed3f05d872c1b4f267c79a265c93549c2b47340f6247d45c6bad6",
    "Source": "/var/lib/docker/volumes/0a2bed92659ed3f05d872c1b4f267c79a265c93549c2b47340f6247d45c6bad6/_data",
    "Destination": "/var/lib/mysql",
    "Driver": "local",
    "Mode": "",
    "RW": true,
    "Propagation": ""
  }
]
...

#list docker volume
docker volume ls | grep 6ab741c456c7b06724470d7db6c56348e6b98df8b4d1cc7df7d8b32af37cde95
...
local     6ab741c456c7b06724470d7db6c56348e6b98df8b4d1cc7df7d8b32af37cde95
...

#stop and remove mariadb-anonymouse-vol container
docker stop mariadb-anonymouse-vol && docker rm mariadb-anonymouse-vol
```

```sh
#run mariadb container with named volumes
docker run --name mariadb-named-vol -e MARIADB_RANDOM_ROOT_PASSWORD=1 -v mariadb:/var/lib/mysql/data -d mariadb:latest

#inspect mariadb-named-vol container
docker inspect mariadb-named-vol
...
"Mounts": [
  {
    "Type": "volume",
    "Name": "mariadb",
    "Source": "/var/lib/docker/volumes/mariadb/_data",
    "Destination": "/var/lib/mysql/data",
    "Driver": "local",
    "Mode": "z",
    "RW": true,
    "Propagation": ""
  },
  {
    "Type": "volume",
    "Name": "25212bda41546a8d98d35b88a40c2903124846d11b6d19f5b70f8a0ea8dbe27a",
    "Source": "/var/lib/docker/volumes/25212bda41546a8d98d35b88a40c2903124846d11b6d19f5b70f8a0ea8dbe27a/_data",
    "Destination": "/var/lib/mysql",
    "Driver": "local",
    "Mode": "",
    "RW": true,
    "Propagation": ""
  }
]
...

#list docker volume
docker volume ls | grep mariadb
...
local     mariadb
...

#stop and remove mariadb-named-vol container
docker stop mariadb-named-vol && docker rm mariadb-named-vol
```