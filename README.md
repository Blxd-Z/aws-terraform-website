## Sobre el proyecto

Este proyecto provisiona una infraestructura en AWS simulando un entorno productivo utilizando Terraform como herramienta de Infrastructure as Code.

La arquitectura incluye una VPC personalizada, subnet pública, una instancia EC2 con Nginx desplegado automáticamente mediante user_data, un sitio web estático en S3 y una distribución CloudFront protegida mediante Origin Access Control (OAC).

El estado remoto de Terraform se gestiona en S3 con bloqueo en DynamoDB para evitar conflictos concurrentes.

El despliegue está automatizado mediante GitHub Actions usando autenticación OIDC, eliminando la necesidad de credenciales AWS estáticas

## Requisitos

## Despliegue

1. Ejecutar el workflow de bootstrap para crear:
   - S3 bucket para estado remoto
   - DynamoDB table para locking

2. Crear un secret en GitHub:
   TF_VAR_my_ip = <TU_IP_PUBLICA>/32

3. Ejecutar:
   terraform init
   terraform apply

## Tecnologias utilizadas

* Terraform >= 1.14
* AWS Provider ~> 6.28
* AWS (EC2, VPC, S3, CloudFront, IAM)
* GitHub Actions
* OIDC






