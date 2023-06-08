resource "aws_launch_configuration" "wk21launch" {
  image_id                    = var.ami
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.wk21sg.id]
  user_data                   = base64encode("${var.apachebstp}")
  associate_public_ip_address = true

}
resource "aws_security_group" "wk21sg" {
  name        = "wk21sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.wk21vpc.id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}


resource "aws_autoscaling_group" "wk21asg" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 2
  vpc_zone_identifier  = [aws_subnet.wk21sn1.id, aws_subnet.wk21sn2.id]
  launch_configuration = aws_launch_configuration.wk21launch.id
  tag {
    key                 = "Name"
    value               = "wk21asg"
    propagate_at_launch = true

  }
}

resource "aws_vpc" "wk21vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "wk21vpc"
  }
}

resource "aws_subnet" "wk21sn1" {
  vpc_id     = aws_vpc.wk21vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet-1"
  }
}

resource "aws_subnet" "wk21sn2" {
  vpc_id     = aws_vpc.wk21vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "subnet-2"
  }
}

resource "aws_internet_gateway" "wk21igw" {
  vpc_id = aws_vpc.wk21vpc.id

  tags = {
    Name = "wk21igw"
  }
}


resource "aws_route_table" "wk21rt" {
  vpc_id = aws_vpc.wk21vpc.id
  route {
    gateway_id = aws_internet_gateway.wk21igw.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "wk21rta" {
  subnet_id      = aws_subnet.wk21sn1.id
  route_table_id = aws_route_table.wk21rt.id
}

resource "aws_route_table_association" "wk21rtb" {
  subnet_id      = aws_subnet.wk21sn2.id
  route_table_id = aws_route_table.wk21rt.id
}

resource "aws_s3_bucket" "wk21bucket" {
  bucket = var.wk21s3

  tags = {
    Name = "wk21bucket"

  }
}

resource "aws_s3_bucket_versioning" "wk21bucket" {
  bucket = aws_s3_bucket.wk21bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "apache_wk21_ownership" {
  depends_on = [aws_s3_bucket.wk21bucket]
  bucket     = aws_s3_bucket.wk21bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "pwk21bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.apache_wk21_ownership]

  bucket = aws_s3_bucket.wk21bucket.id
  acl    = "private"
}
