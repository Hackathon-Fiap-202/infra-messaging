# infra-messaging

Infraestrutura de mensageria e armazenamento do projeto **nexTime-frame**, provisionada com Terraform na AWS. Este repositório define as filas SQS, o bucket S3 de vídeos (com notificação automática para SQS) e a identidade SES para envio de e-mails.

## Sumário

- [Visão Geral](#visão-geral)
- [Arquitetura de Mensageria](#arquitetura-de-mensageria)
- [Recursos Provisionados](#recursos-provisionados)
- [Pré-requisitos](#pré-requisitos)
- [Variáveis](#variáveis)
- [Outputs](#outputs)
- [Como Usar](#como-usar)
- [Backend Remoto](#backend-remoto)
- [CI/CD](#cicd)
- [Ordem de Deploy](#ordem-de-deploy)
- [Contribuição](#contribuição)

---

## Visão Geral

O `infra-messaging` é o **segundo stack a ser aplicado** na ordem de deploy. Não possui dependências de estado remoto de outros stacks — apenas requer credenciais AWS válidas e o bucket de estado já criado.

---

## Arquitetura de Mensageria

```
ms-video
  │ publica
  ▼
SQS: video-process-command ◄── S3 Event (video-input-storage/start-process/*)
  │ consome
  ▼
process-video
  │ publica
  ▼
SQS: video-updated-event
  │ consome
  ▼
ms-video
  │ publica
  ▼
SQS: video-processed-event
  │ consome
  ▼
lambda-sender → SES → E-mail ao usuário
```

---

## Recursos Provisionados

### Filas SQS

| Nome da fila | Papel no sistema |
|---|---|
| `video-process-command` | Recebe comandos de processamento. Também recebe notificações do S3 quando um vídeo é enviado para `video-input-storage/start-process/*` |
| `video-updated-event` | Publicado pelo `process-video` após extração de frames concluída; consumido pelo `ms-video` |
| `video-processed-event` | Publicado pelo `ms-video` após atualização do status; consumido pelo `lambda-sender` |

Todas as filas são criadas pelo **módulo `sqs`** com as seguintes configurações padrão:

| Parâmetro | Valor padrão |
|---|---|
| Delay | 0 s |
| Tamanho máximo de mensagem | 256 KB |
| Retenção de mensagens | 4 dias (345 600 s) |
| Timeout de visibilidade | 30 s |
| Long polling | 0 s (configurável) |
| Dead Letter Queue | Suportada (configurável) |
| Criptografia KMS | Suportada (configurável) |

### Bucket S3

| Parâmetro | Valor |
|---|---|
| Nome | `nextime-frame-video-storage` |
| Versionamento | Habilitado |
| Criptografia | AES256 (SSE-S3) |
| Notificação S3 | `s3:ObjectCreated:*` no prefixo `video-input-storage/start-process/` → `video-process-command` |

**Paths utilizados no bucket:**

| Path | Uso |
|---|---|
| `video-input-storage/start-process/{uuid}.mp4` | Vídeo original enviado pelo cliente via URL pré-assinada |
| `video-processed-storage/end-process/{uuid}.zip` | ZIP com frames extraídos, gerado pelo `process-video` |

### SES (Simple Email Service)

| Parâmetro | Valor |
|---|---|
| Identidade | `framenextime@gmail.com` (e-mail verificado) |
| Política de identidade | Permite que a conta AWS root (e a Lambda) envie e-mails usando esta identidade |

> Após o primeiro `terraform apply`, é necessário clicar no link de verificação enviado ao e-mail configurado antes de usar o SES em produção.

---

## Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configurado com permissões para criar recursos SQS, S3 e SES
- Bucket S3 `nextime-frame-state-bucket-s3` criado na região `us-east-1`

---

## Variáveis

| Variável | Tipo | Descrição | Padrão |
|---|---|---|---|
| `region` | `string` | Região AWS | `us-east-1` |
| `bucket_name` | `string` | Nome do bucket S3 de vídeos | `nextime-frame-video-storage` |
| `ses_email` | `string` | E-mail remetente verificado no SES | `framenextime@gmail.com` |
| `role_arn` | `string` | ARN do principal autorizado a enviar e-mails via SES | — |
| `sqs_queues` | `map(object)` | Mapa de filas SQS a criar | — |
| `tags` | `map(string)` | Tags aplicadas a todos os recursos | `{ Owner = "nexTime-frame" }` |

---

## Outputs

| Output | Descrição |
|---|---|
| `sqs_queue_urls` | Mapa `{ nome_fila → URL }` das filas SQS |
| `sqs_queue_arns` | Mapa `{ nome_fila → ARN }` das filas SQS |
| `sqs_queue_names` | Mapa `{ nome_fila → nome }` das filas SQS |
| `sqs_queues` | Mapa completo com `id`, `arn`, `url` e `name` de cada fila |
| `ses_email_identity_arns` | ARN da identidade SES |
| `s3_bucket_name` | Nome do bucket S3 |
| `s3_bucket_arn` | ARN do bucket S3 |

---

## Como Usar

```bash
cd infra-messaging/infra

# Inicializar
terraform init

# Validar
terraform validate

# Plano
terraform plan

# Aplicar
terraform apply

# Verificar outputs (URLs das filas, ARN do bucket, etc.)
terraform output
```

---

## Backend Remoto

```hcl
backend "s3" {
  bucket  = "nextime-frame-state-bucket-s3"
  key     = "messaging/infra.tfstate"
  region  = "us-east-1"
  encrypt = true
}
```

---

## CI/CD

O pipeline `.github/workflows/cd-infra.yml` é acionado em push para `main`.

| Etapa | Comando |
|---|---|
| Configure AWS | OIDC via `AWS_ROLE_ARN` |
| Init | `terraform init` |
| Validate | `terraform validate` |
| Plan | `terraform plan` |
| Apply | `terraform apply -auto-approve` |

**Secrets do GitHub necessários:**

| Secret | Descrição |
|---|---|
| `AWS_ACCOUNT_ID` | ID da conta AWS |
| `AWS_ROLE_ARN` | ARN da role com permissões de deploy |

---

## Ordem de Deploy

```
1. infra-core
2. infra-messaging     ← este repositório
3. infra-gateway
4. Infra-ecs
5. lambda-sender
```

---

## Estrutura do Projeto

```
infra-messaging/
├── infra/
│   ├── main.tf              # Instancia os módulos sqs, ses e s3
│   ├── variables.tf         # Declaração de variáveis
│   ├── outputs.tf           # Outputs exportados
│   ├── providers.tf         # Provider AWS + backend S3
│   ├── terraform.tfvars     # Valores das variáveis
│   └── modules/
│       ├── sqs/             # Filas SQS (com suporte a DLQ e KMS)
│       ├── ses/             # Identidade SES + política de envio
│       └── s3/              # Bucket S3 com versionamento, criptografia e notificação SQS
└── README.md
```

---

## Contribuição

Este repositório faz parte do hackathon FIAP — nexTime-frame. Siga o padrão de commits convencional (`feat:`, `fix:`, `docs:`, `chore:`) e mantenha a estrutura modular do Terraform.
