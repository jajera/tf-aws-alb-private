variable "use_case" {
  default = "tf-aws-alb-private"
}

# create rg, list created resources
resource "aws_resourcegroups_group" "example" {
  name        = "tf-rg-example"
  description = "Resource group for example resources"

  resource_query {
    query = <<JSON
    {
      "ResourceTypeFilters": [
        "AWS::AllSupported"
      ],
      "TagFilters": [
        {
          "Key": "Owner",
          "Values": ["John Ajera"]
        },
        {
          "Key": "UseCase",
          "Values": ["${var.use_case}"]
        }
      ]
    }
    JSON
  }

  tags = {
    Name    = "tf-rg-example"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}

output "config" {
  value = {
    lb_url = aws_lb.example.dns_name
    public1_pip = aws_instance.public1.public_ip
    public2_pip = aws_instance.public2.public_ip
    private1_ip = aws_instance.private1.private_ip
    private2_ip = aws_instance.private2.private_ip
  }
}
