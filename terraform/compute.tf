# Máquina 1: Kubernetes Control Plane (Master)
resource "aws_instance" "k8s_master" {
  ami                         = "ami-0c101f26f147fa7fd" # Ubuntu 22.04 LTS
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.sg_k8s.id]
  key_name                    = aws_key_pair.chave_sre.key_name
  associate_public_ip_address = true

  tags = {
    Name = "k8s-master"
  }
}

# Máquina 2: Kubernetes Worker Node (Onde os apps vão rodar de verdade)
resource "aws_instance" "k8s_worker" {
  ami                         = "ami-0c101f26f147fa7fd" # Ubuntu 22.04 LTS
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnets[1]
  vpc_security_group_ids      = [aws_security_group.sg_k8s.id]
  key_name                    = aws_key_pair.chave_sre.key_name
  associate_public_ip_address = true

  tags = {
    Name = "k8s-worker-1"
  }
}

# Output para exibir o IP das máquinas na tela ao final do deploy
output "ip_publico_master" {
  value = aws_instance.k8s_master.public_ip
}

output "ip_publico_worker" {
  value = aws_instance.k8s_worker.public_ip
}