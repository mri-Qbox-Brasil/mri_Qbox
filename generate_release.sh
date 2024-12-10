#!/bin/bash

# Atualizar o repositório local
git fetch --all --tags

# Função para encontrar a branch principal automaticamente (main ou master)
get_main_branch() {
  local main_branch
  main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

  if [[ -z "$main_branch" ]]; then
    echo "Erro: Não foi possível detectar a branch principal. Certifique-se de que você está no diretório correto do repositório Git."
    exit 1
  fi
  echo "$main_branch"
}

# Função para obter a última tag e sugerir a próxima versão
suggest_next_version() {
  local last_tag="$1"
  if [[ -z "$last_tag" ]]; then
    echo "v1.0.0"
  else
    IFS='.' read -r major minor patch <<< "${last_tag//v/}"
    echo "v$major.$minor.$((patch + 1))"
  fi
}

# Detectar branch principal
main_branch=$(get_main_branch)
echo "Branch principal detectada: $main_branch"

# Obter a última tag e calcular a próxima versão
last_tag=$(git tag --sort=-v:refname | head -n 1)
if [[ -z "$last_tag" ]]; then
  echo "Nenhuma tag encontrada. Sugerindo v1.0.0 como primeira tag."
fi
next_version=$(suggest_next_version "$last_tag")

echo "Última versão: ${last_tag:-Nenhuma}"
echo "Próxima versão sugerida: $next_version"

# Solicitar ao usuário a versão ou usar a sugestão
read -p "Digite a versão da tag ($next_version): " tag_version
tag_version=${tag_version:-$next_version}

# Confirmação para continuar ou cancelar
read -p "Deseja continuar criando a tag $tag_version? (S/N): " confirmacao
case $confirmacao in
  [Ss]* ) echo "Continuando com a operação...";;
  [Nn]* ) echo "Operação cancelada pelo usuário."; exit 0;;
  * ) echo "Resposta inválida. Operação cancelada."; exit 1;;
esac

# Criar e enviar tag
echo "Criando tag $tag_version na branch '$main_branch'..."
git tag "$tag_version" "$main_branch"
if [[ $? -ne 0 ]]; then
  echo "Erro: Falha ao criar a tag $tag_version. Verifique se a tag já existe ou se você tem permissões adequadas."
  exit 1
fi

echo "Enviando a tag $tag_version para o GitHub..."
git push origin "$tag_version"
if [[ $? -ne 0 ]]; then
  echo "Erro: Falha ao enviar a tag $tag_version para o GitHub. Verifique sua conexão e permissões."
  exit 1
fi

echo "Tag $tag_version criada e enviada com sucesso a partir da branch '$main_branch'!"
