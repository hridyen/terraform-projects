resource "aws_db_instance" "mysql" {
  identifier        = "terraform-mysql-db"
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  username          = "admin"
  password          = "password123"
  db_subnet_group_name = aws_db_subnet_group.db_subnet.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}
