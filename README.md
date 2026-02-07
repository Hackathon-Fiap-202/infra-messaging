# Infraestrutura de Mensageria - AWS

Repositório contendo a infraestrutura como código (IaC) para serviços de mensageria na AWS, utilizando Terraform. Este projeto gerencia recursos de **SQS** (Simple Queue Service) e **SES** (Simple Email Service) de forma modular e reutilizável.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Pré-requisitos](#pré-requisitos)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Módulos](#módulos)
  - [Módulo SQS](#módulo-sqs)
  - [Módulo SES](#módulo-ses)
- [Configuração](#configuração)
- [Uso](#uso)
- [Outputs](#outputs)
- [Backend do Terraform](#backend-do-terraform)

## 🎯 Visão Geral

Este projeto fornece uma infraestrutura completa para gerenciamento de mensageria na AWS, permitindo:

- **Criação de múltiplas filas SQS** com configurações personalizadas
- **Configuração de identidades SES** para envio de emails
- **Políticas de acesso** configuráveis para segurança
- **Suporte a Dead Letter Queues (DLQ)** para tratamento de mensagens falhas
- **Criptografia com KMS** opcional
- **Tags padronizadas** para organização e custos

## 📦 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configurado com credenciais apropriadas
- Acesso a uma conta AWS com permissões para criar recursos SQS e SES
- Bucket S3 configurado para armazenar o state do Terraform (veja [Backend do Terraform](#backend-do-terraform))

## 📁 Estrutura do Projeto

```
infra-messaging/
├── infra/
│   ├── main.tf                 # Definição dos módulos principais
│   ├── variables.tf             # Variáveis do projeto
│   ├── outputs.tf              # Outputs do projeto
│   ├── providers.tf            # Configuração dos providers
│   ├── terraform.tfvars        # Valores das variáveis
│   └── modules/
│       ├── sqs/
│       │   ├── main.tf         # Recursos SQS
│       │   ├── variables.tf    # Variáveis do módulo SQS
│       │   └── outputs.tf       # Outputs do módulo SQS
│       └── ses/
│           ├── main.tf         # Recursos SES
│           ├── variables.tf    # Variáveis do módulo SES
│           └── outputs.tf      # Outputs do módulo SES
└── README.md
```

## 🧩 Módulos

### Módulo SQS

O módulo SQS permite criar filas de mensagens com as seguintes funcionalidades:

#### Recursos Criados

- **Fila SQS** com configurações personalizáveis
- **Política de acesso** opcional para controle de permissões
- **Suporte a Dead Letter Queue** para tratamento de mensagens falhas
- **Criptografia KMS** opcional

#### Variáveis Principais

| Variável | Tipo | Descrição | Padrão |
|----------|------|-----------|--------|
| `queue_name` | `string` | Nome da fila SQS | - |
| `delay_seconds` | `number` | Atraso antes das mensagens ficarem disponíveis | `0` |
| `max_message_size` | `number` | Tamanho máximo da mensagem em bytes | `262144` (256 KB) |
| `message_retention_seconds` | `number` | Tempo de retenção de mensagens não processadas | `345600` (4 dias) |
| `visibility_timeout_seconds` | `number` | Tempo de invisibilidade após recebimento | `30` |
| `dead_letter_queue_arn` | `string` | ARN da DLQ (opcional) | `null` |
| `max_receive_count` | `number` | Tentativas antes de enviar para DLQ | `3` |
| `kms_master_key_id` | `string` | ID da chave KMS (opcional) | `null` |
| `enable_queue_policy` | `bool` | Habilitar política customizada | `false` |

#### Exemplo de Uso

```hcl
sqs_queues = {
  "video-uploaded-queue" = {
    queue_name                 = "video-uploaded-queue"
    delay_seconds              = 0
    max_message_size           = 262144
    message_retention_seconds  = 345600
    receive_wait_time_seconds  = 0
    visibility_timeout_seconds = 30
    max_receive_count          = 3
    enable_queue_policy        = false
  }
}
```

### Módulo SES

O módulo SES configura identidades de email verificadas com políticas de acesso para envio de emails.

#### Recursos Criados

- **Identidade de Email SES** verificada
- **Política de Identidade** que permite envio via Lambda ou outros serviços AWS
- **Permissões configuráveis** para diferentes princípios AWS

#### Variáveis Principais

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `email_address` | `string` | Email remetente verificado no SES |
| `allowed_principals` | `list(string)` | ARNs que podem enviar email via SES (ex: role da Lambda) |

#### Exemplo de Uso

```hcl
ses_email        = "nextimeframe@gmail.com"
lambda_role_arn = "arn:aws:iam::123456789012:role/lambda-send-email"
```

A política de identidade permite que a Lambda especificada envie emails usando o endereço verificado para qualquer destinatário.

## ⚙️ Configuração

### 1. Configurar o Backend S3

O projeto utiliza um backend S3 para armazenar o state do Terraform. Configure o bucket no arquivo `infra/providers.tf`:

```hcl
backend "s3" {
  bucket  = "nextime-food-state-bucket"
  key     = "sqs/infra.tfstate"
  region  = "us-east-1"
  encrypt = true
}
```

### 2. Configurar Variáveis

Edite o arquivo `infra/terraform.tfvars` com seus valores:

```hcl
region = "us-east-1"

tags = {
  Owner = "nexTime-frame"
}

sqs_queues = {
  # Suas filas SQS aqui
}

ses_email        = "seu-email@exemplo.com"
lambda_role_arn = "arn:aws:iam::ACCOUNT_ID:role/sua-role-lambda"
```

### 3. Inicializar o Terraform

```bash
cd infra
terraform init
```

### 4. Revisar o Plano

```bash
terraform plan
```

### 5. Aplicar as Mudanças

```bash
terraform apply
```

## 🚀 Uso

### Criar Novas Filas SQS

Adicione novas entradas no mapa `sqs_queues` em `terraform.tfvars`:

```hcl
sqs_queues = {
  "minha-nova-fila" = {
    queue_name                 = "minha-nova-fila"
    delay_seconds              = 0
    max_message_size           = 262144
    message_retention_seconds  = 345600
    receive_wait_time_seconds  = 0
    visibility_timeout_seconds = 30
    max_receive_count          = 3
    enable_queue_policy        = false
  }
}
```

### Configurar Dead Letter Queue

Para usar uma DLQ, primeiro crie a fila DLQ e depois referencie seu ARN:

```hcl
sqs_queues = {
  "dlq" = {
    queue_name = "minha-dlq"
    # ... outras configurações
  },
  "fila-principal" = {
    queue_name            = "minha-fila"
    dead_letter_queue_arn = module.sqs["dlq"].sqs_queue_arn
    max_receive_count     = 3
    # ... outras configurações
  }
}
```

### Verificar Email no SES

Após aplicar a infraestrutura, você precisará verificar o email no console da AWS SES. O SES enviará um email de verificação para o endereço configurado.

## 📤 Outputs

O projeto fornece os seguintes outputs:

### Outputs SQS

- `sqs_queue_ids`: Mapa de IDs das filas
- `sqs_queue_arns`: Mapa de ARNs das filas
- `sqs_queue_urls`: Mapa de URLs das filas
- `sqs_queue_names`: Mapa de nomes das filas
- `sqs_queues`: Mapa completo com todas as informações

### Outputs SES

- `ses_email_identity_arns`: ARN da identidade de email do SES

### Exemplo de Uso dos Outputs

```bash
# Ver todos os outputs
terraform output

# Ver ARN de uma fila específica
terraform output sqs_queue_arns

# Usar em outro módulo Terraform
module "outro_modulo" {
  source = "./outro"
  queue_arn = module.sqs["video-uploaded-queue"].sqs_queue_arn
}
```

## 🔒 Backend do Terraform

O projeto utiliza um backend S3 remoto para armazenar o state do Terraform, garantindo:

- **Versionamento**: Histórico de mudanças no state
- **Criptografia**: State criptografado no S3
- **Colaboração**: Múltiplos desenvolvedores podem trabalhar no mesmo projeto
- **Backup**: State armazenado de forma segura

### Configuração do Backend

O backend está configurado em `infra/providers.tf`. Certifique-se de que:

1. O bucket S3 existe
2. Você tem permissões de leitura/escrita no bucket
3. A criptografia está habilitada (recomendado)

## 🔐 Segurança

### Recomendações

- **KMS**: Use criptografia KMS para filas SQS que contenham dados sensíveis
- **Políticas IAM**: Configure políticas de acesso restritivas nas filas
- **Verificação de Email**: Sempre verifique emails no SES antes de usar em produção
- **Tags**: Use tags para organização e controle de custos
- **State**: Mantenha o state do Terraform em um bucket S3 privado e criptografado

## 📝 Notas Importantes

### SES

- O email configurado precisa ser verificado no console da AWS SES
- Em ambiente sandbox, o SES só permite envio para emails verificados
- Para produção, solicite a remoção do sandbox no console AWS
- A política de identidade permite envio para qualquer destinatário quando a identidade está verificada

### SQS

- Filas padrão não garantem ordem de mensagens
- Use filas FIFO se precisar de ordem garantida
- Configure DLQ para evitar perda de mensagens
- Ajuste `visibility_timeout_seconds` baseado no tempo de processamento

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto é parte do projeto nexTime-frame.

## 👥 Autores

- **nexTime-frame** - *Desenvolvimento inicial*

---

Para mais informações sobre os serviços AWS utilizados:

- [AWS SQS Documentation](https://docs.aws.amazon.com/sqs/)
- [AWS SES Documentation](https://docs.aws.amazon.com/ses/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
