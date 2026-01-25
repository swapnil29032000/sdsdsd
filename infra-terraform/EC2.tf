resource "aws_key_pair" "my-key" {
    key_name = "priya-key"
    public_key = file("priya-key.pub")

  
}
resource "aws_default_vpc" "default" {//aws ka vpc configurable nhi hota to by default he rakte hai
  
}

resource "aws_security_group" "my_sg" {
  name = "my security group"
  description = "this  is a security group don by terraform"
  vpc_id = aws_default_vpc.default.id//interpolation : wo . jo hai usko interpolation bolte hai kisi bhi resource ke andar jo value hai wo aap utha sakte ho attributes ki values bhi utha sakte hai
 
  ingress { //inbound rules
     description = "allow access to ssh port 22"
     from_port =  22
     to_port  = 22
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"] // avaible to everyone
  }
  ingress {
   description = "allow access to http port 80"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress{
    
    description = "this is allow accces to https port 443"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { //outbound rules
      description= "allow all out going traffic"
      to_port = 0 // to_port& from_port is always zero
      from_port = 0
      protocol = "-1"//outgoing traffic for every type
      cidr_blocks = ["0.0.0.0/0"]

  }
  tags={
    name = "my security group"
  }
}
resource "aws_instance" "my_instance" {
    
    ami= "ami-087a0156cb826e921"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.my_sg.name] //interpolation
    key_name = aws_key_pair.my-key.key_name // interpolation

  root_block_device { //ebs or volume
  volume_size = "10"
  volume_type = "gp3"

    
  }
  tags = {
    Name = "devops-instance" // ec2 name
  }
}