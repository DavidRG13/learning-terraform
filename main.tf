provider "aws" {
  # credentials taken from ~/.aws/credentials
  region     = "eu-west-1"
}

locals {
  instance-userdata = <<EOF
#!/bin/bash
export PATH=$PATH:/usr/local/bin
which httpd >/dev/null
if [ $? -ne 0 ];
then
  echo 'HTTPD NOT PRESENT'
  if [ -n "$(which yum)" ];
  then
    yum install -y httpd
  else
    apt-get -y update && apt-get -y install httpd
  fi
else
  echo 'HTTPD ALREADY PRESENT'
fi

echo "<!DOCTYPE html><html><body><h1>Main page!</h1></body></html>" > /var/www/html/index.html
EOF
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa XXXXXXXX"
}

resource "aws_instance" "my-ec2-instance" {
  ami           = "ami-07683a44e80cd32c5"
  instance_type = "t2.micro"
  key_name = "deployer-key"
  user_data_base64 = "${base64encode(local.instance-userdata)}"
  security_groups = [
        "access-http",
        "access-https",
        "access-ssh"
    ]
}

resource "aws_security_group" "access-https" {
  name = "access-https"
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "access-http" {
  name = "access-http"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "access-ssh" {
  name = "access-ssh"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#resource "aws_security_group" "allow_http" {
#  name        = "allow_http"
#  description = "Allow HTTP inbound traffic"#

#  ingress {
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
#    cidr_blocks = ["0.0.0.0/0", "::/0"]
#  }

#  tags = {
#    Name = "allow_http_all"
#  }
#}