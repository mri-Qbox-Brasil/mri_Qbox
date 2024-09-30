#!/bin/bash

git fetch --all --tags

# Função para encontrar a branch principal automaticamente (main ou master)
get_main_branch() {
  main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

  # Verifica se a branch principal foi detectada
  if [[ -z "$main_branch" ]]; then
    echo "Erro: Nao foi possivel detectar a branch principal. Certifique-se de que voce esta no diretorio correto do repositorio Git."
    exit 1
  fi

  echo "$main_branch"
}

# Função para obter a última tag e sugerir a próxima versão
suggest_next_version() {
  if [[ -z "$last_tag" ]]; then
    next_version="v1.0.0"
  else
    # Extrai a versão e sugere a próxima, incrementando o último dígito
    IFS='.' read -r major minor patch <<< "${last_tag//v/}"
    next_version="v$major.$minor.$((patch + 1))"
  fi
  echo "$next_version"
}
# Obtém a branch principal
main_branch=$(get_main_branch)
echo "Branch principal detectada: $main_branch"

# Sugere a próxima versão com base na última tag
last_tag=$(git describe --tags $(git rev-list --tags --max-count=1) 2>/dev/null)
next_version=$(suggest_next_version)
echo "Ultima versao: ${last_tag:-Nenhuma}"

# Solicita ao usuário a versão ou usa a sugestão
read -p "Digite a versao da tag ($next_version): " tag_version
tag_version=${tag_version:-$next_version}

# Confirmação da criação da tag e envio
echo "Criando tag $tag_version na branch '$main_branch' e enviando para o GitHub..."

# Cria a tag
git tag "$tag_version" "$main_branch"
if [[ $? -ne 0 ]]; then
  echo "Erro: Falha ao criar a tag $tag_version. Verifique se a tag ja existe ou se você tem permissoes adequadas."
  exit 1
fi

# Envia a tag para o repositório
git push origin "$tag_version"
if [[ $? -ne 0 ]]; then
  echo "Erro: Falha ao enviar a tag $tag_version para o GitHub. Verifique sua conexão e permissoes."
  exit 1
fi

echo "Tag $tag_version criada e enviada com sucesso a partir da branch '$main_branch'!"
