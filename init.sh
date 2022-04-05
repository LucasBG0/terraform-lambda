#!/bin/bash

divider() {
  printf "\r\033[0;1m========================================================================\033[0m\n"
}

info() {
  printf "\r\033[00;35m$1\033[0m\n"
}

success() {
  printf "\r\033[00;32m$1\033[0m\n"
}

fail() {
  printf "\r\033[0;31m$1\033[0m\n"
}

pause_for_confirmation() {
  read -rsp $'Pressione qualquer tecla para continuar (ctrl-c para sair):\n' -n1 key
}

# Set up an interrupt handler so we can exit gracefully
interrupt_count=0
interrupt_handler() {
  ((interrupt_count += 1))

  echo ""
  if [[ $interrupt_count -eq 1 ]]; then
    fail "Realmente desistir? Pressione ctrl-c novamente para confirmar."
  else
    echo "Adeus!"
    exit
  fi
}
trap interrupt_handler SIGINT SIGTERM

# Check for required tools
declare -a req_tools=("terraform" "docker" "docker-compose" "jq")
for tool in "${req_tools[@]}"; do
  if ! command -v "$tool" > /dev/null; then
    fail "Parece que '${tool}' não está instalado; instale-o e execute este script de configuração novamente."
    exit 1
  fi
done


echo
printf "\r\033[00;35;1m
--------------------------------------------------------------------------
Getting Started with Terraform and LocalStack
-------------------------------------------------------------------------\033[0m"
echo  
echo "Iniciando o contêiner localstack..."
sleep 2
echo

docker-compose up -d
echo
echo "..."
sleep 2
echo
divider
echo

echo
terraform init
echo
echo "..."
sleep 2
echo
divider
echo
info "Agora é hora do 'terraform plan', para ver quais mudanças o Terraform irá realizar:"
echo
echo "$ terraform plan"
echo
pause_for_confirmation

echo
terraform plan
echo
echo "..."
sleep 3
echo
divider
echo
success "O plan está completo!"
echo
info "Para realmente fazer alterações, executaremos 'terraform apply'. Também aprovaremos automaticamente o resultado, pois este é um exemplo:"
echo
echo "$ terraform apply -auto-approve"
echo
pause_for_confirmation

echo
terraform apply -auto-approve

echo
echo "..."
sleep 3
echo
divider
echo
success "Você acabou de provisionar a infraestrutura com o Terraform usando localstack como provider para testar localmente!"

echo
echo "..."
sleep 3
echo
divider
echo

API_GATEWAY_URL_LOCALSTACK=$(terraform output -json | jq -r '.api_gateway_url_localstack.value')
echo
info "Agora é a hora de testar a API que foi provisionada, executaremos um cURL na URL do output do localstack:"
echo
echo "$ curl -d 'teste' ${API_GATEWAY_URL_LOCALSTACK}"
echo
pause_for_confirmation

echo
echo "Segue abaixo o resultado do comando cURL:"
sleep 3
curl -d 'teste' ${API_GATEWAY_URL_LOCALSTACK}

echo
echo
echo "..."
sleep 3
echo
divider