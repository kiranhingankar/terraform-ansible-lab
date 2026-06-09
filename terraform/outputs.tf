output "ec2_public_ip" {
  value = [
    for instance in aws_instance.my_instance : {
      name      = instance.tags.Name
      public_ip = instance.public_ip
    }
  ]
}