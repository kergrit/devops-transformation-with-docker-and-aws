# 07-aws

This section contains command on AWS resources

### EC2 
`User data` for install nginx and replace index.html
```sh
#!/bin/bash 
sudo yum update -y
sudo yum install nginx -y
sudo nginx -v
sudo systemctl start nginx
sudo systemctl enable nginx

sudo chmod 2775 /usr/share/nginx/html 
sudo find /usr/share/nginx/html -type d -exec chmod 2775 {} \;
sudo find /usr/share/nginx/html -type f -exec chmod 0664 {} \;
sudo sed -i "s/<\/body>/<hr><h4>Welcome to my NGINX web server! User data installation was a SUCCESS!<\/h4><p>DevOps Transformation with Docker and AWS.<\/p><\/body>/g" /usr/share/nginx/html/index.html
```

### EFS
Mounting EFS file systems
```sh
#installing the Amazon EFS client
sudo yum install -y amazon-efs-utils

#create directory as file system mount point
sudo mkdir -p /mnt/efs/fs1

#mount efs via DNS
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-072f55c80ccadb5ec.efs.ap-southeast-1.amazonaws.com:/ /mnt/efs/fs1

#make auto mount at boot time
echo "fs-072f55c80ccadb5ec.efs.ap-southeast-1.amazonaws.com:/ /mnt/efs/fs1 nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" | sudo tee -a  /etc/fstab

#verify
df -h
...
Filesystem                                               Size  Used Avail Use% Mounted on
fs-072f55c80ccadb5ec.efs.ap-southeast-1.amazonaws.com:/  8.0E     0  8.0E   0% /mnt/efs/fs1
...

#change owner/group to ec2-user for read/write (ec2-user is default user on amazon linux)
sudo chown ec2-user /mnt/efs/fs1 && sudo chgrp ec2-user /mnt/efs/fs1

#try to write file
echo "Hello" > hello.txt
```

### S3
Bucket Policy (Public Access)
```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "S3 Public Access",
			"Principal": "*",
			"Effect": "Allow",
			"Action": [
				"s3:*"
			],
			"Resource": ["arn:aws:s3:::devops-s3/*"]
		}
	]
}
```