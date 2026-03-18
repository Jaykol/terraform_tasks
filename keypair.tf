resource "aws_key_pair" "terra-key" {
  key_name   = "terra-key"
  public_key = var.public_key
}
