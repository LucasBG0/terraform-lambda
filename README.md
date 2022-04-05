# Instruções para executar o desafio
 
Meu objetivo nesse desafio foi subir uma infra totalmente gerenciada pelo terraform, exigindo apenas definir as variáveis no arquivo terraform.tfvars.
 
## Tecnologias utilizadas:
 
* Terraform 1.1.7
* AWS provider 4.8.0
* Localstack 0.14.2 via container docker
 * Docker version 20.10.6
 * docker-compose version 1.28.6
* SO: Linux
 
---
 
## Descrição da arquitetura:
 
1. 1 módulo para API Gateway: responsável por provisionar um endpoint e oferecer um reaproveitamento de código na criacão de novos endpoints;
1. 1 módulo para Lambda Function: responsável por provisionar uma funcão lambda e oferecer um reaproveitamento de código na criacão de novas funcões lambda.
 
---

## Como subir a infra:

1. Basta executar o script que irá provisionar o container do localstack e os scripts do terraform:

```
./init sh
```



