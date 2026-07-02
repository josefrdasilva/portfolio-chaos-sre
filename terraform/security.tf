resource "aws_security_group" "sg_k8s" {
  name        = "sg_projeto_chaos"
  description = "Firewall para o cluster Kubernetes do projeto de Caos"
  vpc_id      = module.vpc.vpc_id

  # Liberar SSH para você acessar as máquinas de qualquer lugar (ou coloque seu IP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Liberar a porta da API do Kubernetes (essencial para o kubectl funcionar)
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Comunicação interna total entre as máquinas do cluster dentro da VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite o acesso de qualquer IP da internet
    description = "Permitir acesso ao App Web do Kubernetes"
  }

  # Saída liberada para as máquinas baixarem pacotes da internet (Docker, K3s, etc)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-projeto-chaos"
  }
}