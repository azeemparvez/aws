# Creating EC2 instances in public subnet for testing
data "aws_ami" "rhel" {
  owners = ["309956199498"]
  most_recent = true
}

resource "aws_instance" "web" {
  ami = data.aws_ami.rhel.id
  instance_type = "t2.micro"
  key_name = "azeem"
  subnet_id = aws_subnet.lb[0].id
  #count = length(local.azs)
  vpc_security_group_ids = [aws_security_group.web-app.id]
  tags = {
    Name = "Web Server "
  }
  
  provisioner "local-exec" {
    command = "echo ${aws_instance.web.public_ip} >> publicip.txt"
  }
  
}