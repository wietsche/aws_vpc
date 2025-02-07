# A minimal VPC setup

This repository contains a Terraform configuration to create a minimal VPC setup with a public subnet and a private subnet.

An EC2 instance is created in each subnet, so that the behaviour can be tested. 

- Both instances serve a "Hello World" web page using a simple web server.
- You should be able to reach the public page over the internet, but not the private one.
- If you open ssh ports you should be able to connect to the public instance using pem key, but not to the private one.
- If should be able to ssh to the private instance from the public instance if port 22 is open
- You should be able to reach the internet from both instances.

The code is annotated with comments to explain the purpose of each resource and the configuration options used.

(The code is the result of an exercise to get practical experience setting up a minimal, secure AWS account using 
TerraformIs it is not intented for production, however you are welcome to use this for inspiration.)

## Prerequisites

- An AWS account 
- Access to a User and/or Role with the necessary permissions to create the resources defined in the Terraform configuration
- AWS CLI installed on your local machine https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html and configured with the necessary credentials
- Terraform installed on your local machine https://developer.hashicorp.com/terraform/install

## Usage

1. Clone the repository
2. Navigate to the root of the repository
3. Run `terraform init` to initialize the Terraform configuration
4. Run `terraform apply` to create the resources

Now you can test the behaviour as described above.

When you are done, you can run `terraform destroy` to delete the resources.
