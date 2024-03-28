NM=$1

multipass launch --name ${NM} jammy --memory 512M --disk 5G --cpus 1

multipass transfer install-docker.sh ${NM}:/home/ubuntu/install-docker.sh
multipass exec ${NM} -- sh -x /home/ubuntu/install-docker.sh