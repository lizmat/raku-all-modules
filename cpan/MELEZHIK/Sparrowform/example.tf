provider "aws" {
  region     = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-02e98f78"
  instance_type = "t2.micro"
  key_name = "alexey-test"
  subnet_id = "subnet-c71d9ce8"
  associate_public_ip_address  = true
  tags = {  foo = "bar" }
  security_groups = [ "sg-0fb45e7b", "sg-9aa248ee" ]
}

resource "aws_instance" "example2" {
  ami           = "ami-02e98f78"
  instance_type = "t2.micro"
  key_name = "alexey-test"
  subnet_id = "subnet-c71d9ce8"
  associate_public_ip_address  = true
  tags = {  foo = "bar" }
  security_groups = [ "sg-0fb45e7b", "sg-9aa248ee" ]
}


