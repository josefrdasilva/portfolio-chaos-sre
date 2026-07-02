resource "aws_key_pair" "chave_sre" {
  key_name   = "chave-projeto-sre"
  public_key = file("~/.ssh/chave-projeto-sre.pub")
}