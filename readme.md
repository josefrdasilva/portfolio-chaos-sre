# Cluster K3s Multizona na AWS com Terraform e Testes de Resiliência (Self-Healing)

Este repositório contém a documentação e os arquivos de configuração para a implementação de um cluster Kubernetes leve (K3s) em ambiente multizona na AWS, utilizando Terraform para o provisionamento automatizado da infraestrutura. O objetivo principal do projeto é demonstrar práticas de Engenharia de Confiabilidade de Sistemas (SRE), validação de alta disponibilidade e mecanismos de autocura (self-healing) do Kubernetes.

## Arquitetura do Projeto

A infraestrutura provisionada via Terraform consiste em:
- Instâncias EC2 executando Amazon Linux 2023, distribuídas estrategicamente para garantir resiliência contra falhas de zona.
- Configuração de Security Groups específicos para permitir a comunicação segura do plano de controle (Control-Plane), agentes (Workers) e tráfego HTTP externo.
- Cluster K3s unificado, gerenciando deployments com réplicas distribuídas entre os nós disponíveis.

---

## Evidências de Implementação e Validação Prática

Abaixo estão detalhadas as etapas de validação do cluster, com as capturas de tela extraídas diretamente do ambiente de homologação. Os arquivos correspondentes estão armazenados no diretório `docs/images/`.

### 1. Acesso à Aplicação via Navegador
Para confirmar o correto funcionamento do roteamento de tráfego externo e do balanceamento de carga do K3s (através do Traefik integrado), a aplicação Nginx foi exposta na porta 8080. O acesso foi validado com sucesso através do IP público da instância correspondente.

![Acesso à Aplicação via Navegador](docs/images/Captura%20de%20tela%202026-07-02%20201434.png)
*Confirmação visual da página padrão do Nginx respondendo de forma estável no navegador.*

### 2. Status e Prontidão dos Nós do Cluster
Após a inicialização do plano de controle e o registro do nó worker via token seguro do K3s, executou-se a checagem de saúde dos nós para garantir que toda a capacidade computacional projetada estava disponível para agendamento de cargas de trabalho.

![Status dos Nós](docs/images/Captura%20de%20tela%202026-07-02%20201539.png)
*Saída do comando `kubectl get nodes` exibindo o nó master (`ip-10-0-101-86`) e o nó worker (`ip-10-0-102-198`) em estado Ready.*

### 3. Distribuição de Pods e Alta Disponibilidade
Para evitar pontos únicos de falha a nível de nó, o Deployment foi configurado para manter múltiplas réplicas da aplicação. A distribuição uniforme desses pods entre os nós do cluster foi inspecionada detalhadamente.

![Distribuição de Pods](docs/images/Captura%20de%20tela%202026-07-02%20201609.png)
*Execução do comando `kubectl get pods -o wide` comprovando o agendamento de pods distintos em instâncias EC2 fisicamente separadas no cluster.*

### 4. Teste de Engenharia de Caos: Simulação de Falha Crítica
O princípio fundamental do Self-Healing foi testado por meio da deleção manual e abrupta de um dos pods em execução (`meu-app-web-7bc846868-cjxbw`). Esta ação simula a queda repentina de um container ou falha de aplicação em produção.

![Teste de Self-Healing](docs/images/Captura%20de%20tela%202026-07-02%20202111.png)
*Histórico de comandos demonstrando a remoção do pod e a reação imediata do Kubernetes Controller Manager, que identificou a perda e iniciou a criação de um pod substituto (`meu-app-web-7bc846868-b4w6t`) em apenas 10 segundos.*

### 5. Estabilização e Restabelecimento do Estado Desejado
Após o acionamento das rotinas de autocura, monitorou-se o ciclo de vida do novo container até que ele atingisse o estado ideal de funcionamento, garantindo o retorno da tolerância a falhas configurada no escopo do projeto.

![Cluster Estabilizado](docs/images/Captura%20de%20tela%202026-07-02%20202231.png)
*Cluster estabilizado com o novo pod completamente operacional (Running) e integrado à malha de serviços, consolidando o sucesso do teste de resiliência automatizada.*

---

## Como Replicar este Laboratório

1. **Infraestrutura:** Execute os comandos do Terraform (`terraform init`, `terraform plan`, `terraform apply`) dentro do diretório correspondente para provisionar as instâncias EC2 na AWS.
2. **Configuração do Cluster:** Conecte-se via SSH à instância principal para instalar o K3s Server. Utilize o token gerado para configure o K3s Agent no nó worker secundário.
3. **Deploy da Carga de Trabalho:** Aplique o manifesto do deployment contido neste repositório utilizando o utilitário `kubectl`.
