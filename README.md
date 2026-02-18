## Sobre el proyecto

Este proyecto provisiona una infraestructura en AWS simulando un entorno productivo utilizando Terraform como herramienta de Infrastructure as Code.

La arquitectura incluye una VPC personalizada, subnet pública, una instancia EC2 con Nginx desplegado automáticamente mediante user_data, un sitio web estático en S3 y una distribución CloudFront protegida mediante Origin Access Control (OAC).

El estado remoto de Terraform se gestiona en S3 con bloqueo en DynamoDB para evitar conflictos concurrentes.

El despliegue está automatizado mediante GitHub Actions usando autenticación OIDC, eliminando la necesidad de credenciales AWS estáticas.

## Requisitos
Cuenta AWS (Compatible con Free Tier)

Terraform >= 1.14

Rol de IAM configurado por GitHub OIDC

Repositorio de GitHub con Actions activado

Un secret dentro del repositorio que contenga nuestra IP publica:

TF_VAR_my_ip → Tu IP publica en formato CIDR (e.j. 1.2.3.4/32)
## Despliegue

1. Ejecutar el workflow de bootstrap para crear:
   - S3 bucket para estado remoto
   - DynamoDB table para locking

2. Crear un secret en GitHub:
   TF_VAR_my_ip = <TU_IP_PUBLICA>/32

3. Ejecutar:
 ```hcl
   terraform init
   terraform apply
```
## Tecnologias utilizadas

* Terraform >= 1.14
* AWS Provider ~> 6.28
* VPC
* EC2
* IAM
* Amazon CloudFront
* S3
* DynamoDB
* GitHub Actions
* OIDC






