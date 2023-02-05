data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "my-machine" {
  for_each                    = var.subnet
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  availability_zone           = each.value["az"]
  security_groups             = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet[each.key].id
  #user_data                   = file("userdata.tpl")
  key_name = var.keypair


  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> ../Ansible/host-inventory"
  }

  provisioner "local-exec" {
    command = "echo ansible-playboook  -i ../Ansible/host-inventory ../Ansible/playbookk.yml --user=ubuntu --private-key=apache.pem  "
  }

  tags = {
    Name = "${each.key}"
  }
}


resource "aws_lb" "my_alb" {
  #count              = length(var.public_subnet_cidrs)
  name               = "linux-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for subnet in aws_subnet.subnet : subnet.id]

  enable_deletion_protection = false
  enable_http2               = false
  tags = {
    Name = "linux-alb"

  }

}

resource "aws_lb_target_group" "alb_tg" {
  name     = "dev-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    port                = "80"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    matcher             = "200,300,302"
  }
}

resource "aws_lb_target_group_attachment" "alb-attachment" {
  for_each         = var.subnet
  target_id        = aws_instance.my-machine[each.key].id
  target_group_arn = aws_lb_target_group.alb_tg.arn
  port             = 80
}

resource "aws_lb_listener" "alb_listener" {
  depends_on = [
    aws_lb.my_alb, aws_lb_target_group.alb_tg
  ]
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

data "aws_route53_zone" "route53" {
  name         = "claudineogu.me"
  private_zone = false
}

resource "aws_route53_record" "www" {
  depends_on = [aws_lb.my_alb]
  zone_id    = data.aws_route53_zone.route53.zone_id
  name       = "terraform-test.${data.aws_route53_zone.route53.name}"
  type       = "A"
  allow_overwrite = true

  alias {
    name                   = aws_lb.my_alb.dns_name
    zone_id                = aws_lb.my_alb.zone_id
    evaluate_target_health = true
  }
}

data "aws_acm_certificate" "amazon_issued" {
  domain      = "claudineogu.me"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

resource "aws_alb_listener" "linux-alb-listener-https" {
  depends_on = [data.aws_acm_certificate.amazon_issued]
  load_balancer_arn = aws_lb.my_alb.arn
 # certificate_arn = "arn:aws:acm:us-east-1:367431057715:certificate/14ac7296-48aa-417d-a8a1-eb9e699f2cf1"
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.amazon_issued.arn
  default_action {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    type = "forward"
  }
}