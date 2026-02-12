resource "aws_instance" "ec2_instance" {
  ami           = "ami-02b8269d5e85954ef"
  instance_type =  var.instance_type
  key_name      = "shan-key"

  tags = {
    Name = "shan-ubuntu"
  }
}



resource "aws_key_pair" "shan" {
  key_name   = "shan-key"
  public_key = file("~/.ssh/shanthosh-key.pub")
}
  

resource "aws_s3_bucket" "demo_bucket" {
  bucket = var.bucket_name

  tags = {
    Name = "TerraformDemo"
    Env  = var.environment
  }
}