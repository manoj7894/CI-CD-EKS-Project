module "vpc" {
  source = "./module/vpc"

  # Pass variables to VPC module
  vpc_id                  = "10.0.0.0/16"
  public_subnet_id_value  = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  private_subnet_id_value = "10.0.2.0/24"
  availability_zone1      = "us-east-1b"
}

# # Data source to get the latest Ubuntu 20.04 AMI ID
# data "aws_ami" "ubuntu_24_arm" {
#   most_recent = true
#   owners      = ["099720109477"]

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-24.04-arm64-gp3*"]  # Update this with the correct pattern if needed
#   }
# }


module "ec2" {
  source = "./module/ec2_instance"

  # Pass variables to EC2 module
  ami_value              = "ami-0866a3c8686eaeeba" # data.aws_ami.ubuntu_24_arm.id                            
  instance_type_value    = "t2.large"
  key_name               = "varma.pem"
  instance_count         = "1"
  public_subnet_id_value = module.vpc.public_subnet_id
  availability_zone      = "us-east-1a"
  vpc_id                 = module.vpc.vpc_id
  # # Correctly pass user_data to the module
  # user_data = filebase64("${path.module}/module/ec2_instance/jenkins.sh")
}


module "eks" {
  source = "./module/eks"

  # Pass variables to EKS module
  public_subnet_id_value  = module.vpc.public_subnet_id
  private_subnet_id_value = module.vpc.private_subnet_id
  instance_type_value     = "t2.large"
  cluster_name            = "eks-1"
  workernode_name         = "Node_01"
  key_name                = "varma.pem"
  vpc_id                  = module.vpc.vpc_id
}


module "efs" {
  source = "./module/efs"

  vpc_id                  = module.vpc.vpc_id
  public_subnet_id_value  = module.vpc.public_subnet_id
  private_subnet_id_value = module.vpc.private_subnet_id
  security_group_id       = module.eks.security_group_id
}

/*
module "ecr" {
  source = "./module/ecr"

  vpc_id                  = module.vpc.vpc_id
  public_subnet_id_value  = module.vpc.public_subnet_id
  private_subnet_id_value = module.vpc.private_subnet_id
  security_group_id       = module.ec2.security_group_id
} */

/*
module "ecs" {
  source = "./module/ecs"

  aws_ecs_cluster         = "ECS-01"
  health_check_path       = "/"
  family                  = "nginx-family"
  network_mode            = "awsvpc"
  fargate_cpu             = "256"
  fargate_memory          = "512"
  ami_value               = "ami-0866a3c8686eaeeba"
  instance_type_value     = "t2.micro"
  key_name                = "varma.pem"
  vpc_id                  = module.vpc.vpc_id
  public_subnet_id_value  = module.vpc.public_subnet_id
  private_subnet_id_value = module.vpc.private_subnet_id
  security_group_id       = module.ec2.security_group_id
  aws_ecs_service         = "nginx-service"
  launch_type             = "FARGATE"
} */

/*
module "app_runner_backend" {
  source = "./module/app_runner/backend"

  backend_service_name    = "Backend"
  image_identifier        = "941377114289.dkr.ecr.us-east-1.amazonaws.com/backendapp:latest"
  image_repository_type   = "ECR"
  port                    = 3001
  cpu                     = 1024
  memory                  = 2048
  vpc_id                  = module.vpc.vpc_id
  public_subnet_id_value  = module.vpc.public_subnet_id
  private_subnet_id_value = module.vpc.private_subnet_id
}


module "app_runner_frontend" {
  source = "./module/app_runner/frontend"

  frontend_service_name       = "Frontend"
  image_identifier            = "941377114289.dkr.ecr.us-east-1.amazonaws.com/frontendapp:latest"
  image_repository_type       = "ECR"
  port                        = 80
  cpu                         = 1024
  memory                      = 2048
  vpc_id                      = module.vpc.vpc_id
  public_subnet_id_value      = module.vpc.public_subnet_id
  private_subnet_id_value     = module.vpc.private_subnet_id
  security_group_id           = module.app_runner_backend.security_group_id
  apprunner_service_role_arn  = module.app_runner_backend.apprunner_service_role_arn
  apprunner_vpc_connector_arn = module.app_runner_backend.apprunner_vpc_connector_arn
} */

/*
resource "null_resource" "name" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    # private_key = "module.ec2.key_name"
    #private_key = file("${path.module}/varma.pem")  # Ensure this path is correct
    host = module.ec2.public_ip[0]
  }

  provisioner "file" {
    source      = "./module/ec2_instance/jenkins.sh"
    destination = "/home/ubuntu/jenkins.sh"
  }

  #   # provisioner "file" {
  #   #   source      = ".env"  # Path to your local .env file
  #   #   destination = "/home/ubuntu/terraform.tfvars"  # Path on the remote instance
  #   # }

  provisioner "remote-exec" {
    inline = [
      # "export $(grep -v '^#' /home/ubuntu/.env | xargs)",
      # "mkdir -p /home/ubuntu/.aws",
      # "echo '[default]' > /home/ubuntu/.aws/config",
      # "echo 'region = ${var.region}' >> /home/ubuntu/.aws/config",
      # "echo '[default]' > /home/ubuntu/.aws/credentials",
      # "echo 'aws_access_key_id = ${var.access_key}' >> /home/ubuntu/.aws/credentials",
      # "echo 'aws_secret_access_key = ${var.secret_key}' >> /home/ubuntu/.aws/credentials",

      # # Optional: Clean up the .env file if not needed
      # "rm /home/ubuntu/.env",

      # "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
      # "chmod +x kubectl",
      # "aws eks --region ${var.region} describe-cluster --name ${module.eks.cluster_name} --query cluster.status",
      # "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}",
      # "sudo mv kubectl /usr/local/bin/",
      "sudo chmod +x /home/ubuntu/jenkins.sh",
      "sh /home/ubuntu/jenkins.sh"
    ]
  }

  depends_on = [module.ec2]
} */