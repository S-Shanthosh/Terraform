resource "aws_instance" "ec2_instance" {
  ami           = "ami-02b8269d5e85954ef"
  instance_type = var.instance_type
  key_name      = "shan-key"

  tags = {
    Name = "shan-ubuntu"
  }
}



resource "aws_key_pair" "shan" {
  key_name   = "shan-key"
  public_key = file(pathexpand("~/.ssh/shanthosh-key.pub"))
}


