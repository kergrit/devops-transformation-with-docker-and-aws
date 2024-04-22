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

### EC2 launce template (lt-whoami)
```sh
#!/bin/bash 
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker $(whoami)
docker run -d -p 80:80 --name whoami traefik/whoami
```

### RDS for mariadb
```sh
# After EC2 connected install mariadb server utils
sudo yum install mariadb105-server-utils -y

# Test connection
mysql -h {$DB_HOST} -u {$DB_USER} -p{$DB_PASSWORD}
show databases;
quit;
```

#### ElatiCash for redis
```sh
# After EC2 connected install redis6-cli
sudo yum install redis6 -y

# Test connection
redis6-cli -c -h {$REDIS_HOST} -p 6379
set key1 123
get key1
"123"
```

### CodeCommit
```sh
# aws configure with IAM account
aws configure

# clone repository
git clone https://git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/hello-world

```

### CodeBuild
```yaml
version: 0.2

phases:
  pre_build:
    commands:
      - echo log in to Amazon ECR...
      - aws --version
      - echo $AWS_DEFAULT_REGION
      - aws configure list      
      - aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 229671038351.dkr.ecr.ap-southeast-1.amazonaws.com/ecs-devops-hello-world
      - REPOSITORY_URI=229671038351.dkr.ecr.ap-southeast-1.amazonaws.com/ecs-devops-hello-world
      - COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      - IMAGE_TAG=${COMMIT_HASH:=latest}      
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image.
      - docker build -t $REPOSITORY_URI:latest .
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG
  post_build:
    commands:
      - echo Build completed on `date`
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - echo write definitions file...
      - printf '[{"name":"ecs-devops-hello-world","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions.json
artifacts:
  files: imagedefinitions.json
```