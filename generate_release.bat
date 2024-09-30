@echo off
setlocal enabledelayedexpansion

git fetch --all --tags

:: Função para encontrar a branch principal automaticamente (main ou master)
set "main_branch="
call :get_main_branch
if "%main_branch%"=="" (
    echo Erro: Nao foi possivel detectar a branch principal. Certifique-se de que voce esta no diretorio correto do repositorio Git.
    exit /b 1
)

echo Branch principal detectada: %main_branch%

:: Função para obter a última tag e sugerir a próxima versão
set "last_tag="
call :get_last_tag
if "%last_tag%"=="" (
    echo Nenhuma tag encontrada. Sugerindo v1.0.0 como primeira tag.
    set "next_version=v1.0.0"
) else (
    for /f "tokens=1-3 delims=." %%a in ("%last_tag:v=%") do (
        set /a patch=%%c + 1
        set "next_version=v%%a.%%b.!patch!"
    )
)

echo Ultima versao: %last_tag%

:: Solicita ao usuário a versão ou usa a sugestão
set /p "tag_version=Digite a versao da tag (%next_version%): "
if "%tag_version%"=="" set "tag_version=%next_version%"

echo Criando tag %tag_version% na branch '%main_branch%' e enviando para o GitHub...

:: Cria a tag
git tag "%tag_version%" "%main_branch%"
if errorlevel 1 (
    echo Erro: Falha ao criar a tag %tag_version%. Verifique se a tag ja existe ou se voce tem permissoes adequadas.
    exit /b 1
)

:: Envia a tag para o repositório
git push origin "%tag_version%"
if errorlevel 1 (
    echo Erro: Falha ao enviar a tag %tag_version% para o GitHub. Verifique sua conexao e permissoes.
    exit /b 1
)

echo Tag %tag_version% criada e enviada com sucesso a partir da branch '%main_branch%'!
goto :eof

:get_main_branch
:: Obtém a branch principal (main ou master)
for /f "delims=" %%i in ('git symbolic-ref refs/remotes/origin/HEAD ^| findstr /r /v "^$" 2^>nul') do (
    set "main_branch=%%i"
)
set "main_branch=%main_branch:refs/remotes/origin/=%"
exit /b

:get_last_tag
:: Obtém a última tag criada no repositório
for /f "delims=" %%i in ('git describe --tags --abbrev=0 2^>nul') do (
    set "last_tag=%%i"
)

:: Verificação alternativa caso a última tag não seja encontrada
if "%last_tag%"=="" (
    for /f "delims=" %%j in ('git tag --sort=-v:refname ^| findstr /r /v "^$" 2^>nul') do (
        set "last_tag=%%j"
        goto :eof
    )
)
exit /b
