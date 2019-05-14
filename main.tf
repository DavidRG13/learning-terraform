provider "aws" {
  # credentials taken from ~/.aws/credentials
  region     = "eu-west-1"
}

resource "aws_instance" "my-ec2-instance" {
  ami           = "ami-07683a44e80cd32c5"
  instance_type = "t2.micro"
}