terraform {

  required_providers { #Proveedor a utilizar, en este caso AWS, para que se pueda comunicar con la API de AWS.
    aws = {
      source  = "hashicorp/aws" #Hostname simplifado del registro de registry.terraform.io/hashicorp/aws
      version = "~> 6.28.0"
    }
  }
  required_version = ">= 1.14" #version a usar de terraform
}
provider "aws" {
  region = "us-east-1"
}