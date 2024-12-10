@echo off
setlocal enabledelayedexpansion

git fetch --all --tags

:: Detectar branch principal (main ou master)
set "main_branch="
for /f "delims=" %%i in ('git symbolic-ref refs/remotes/origin/HEAD 2^>nul') do (
    set "main_branch=%%i"
)
set "main_branch=%main_branch:refs/remotes/origin/=%"

if "%main_branch%"=="" (
    echo [Erro] Nao foi possivel detectar a branch principal. Certifique-se de que voce esta no diretorio correto do repositorio Git.
    exit /b 1
)

echo Branch principal detectada: %main_branch%

:: Obter a ultima tag valida
set "last_tag="
for /f "delims=" %%i in ('git tag --sort=-v:refname 2^>nul') do (
    set "last_tag=%%i"
    goto :found_tag
)

:found_tag
if "%last_tag%"=="" (
    echo Nenhuma tag encontrada. Sugerindo v1.0.0 como primeira tag.
    set "next_version=v1.0.0"
) else (
    for /f "tokens=1-3 delims=." %%a in ("%last_tag:v=%") do (
        set /a patch=%%c + 1
        set "next_version=v%%a.%%b.!patch!"
    )
)

echo Ultima versao encontrada: %last_tag%
echo Proxima versao sugerida: %next_version%

:: Solicitar ao usuario a versao ou usar sugestao
set /p "tag_version=Digite a versao da tag (%next_version%): "
if "%tag_version%"=="" set "tag_version=%next_version%"

:: Confirmar ou cancelar operacao
choice /c SN /n /m "Continuar com a criacao da tag '%tag_version%'? (S = Sim, N = Nao): "
if %errorlevel%==2 (
    echo Operacao cancelada pelo usuario.
    exit /b 1
)

:: Criar e enviar tag
echo Criando tag '%tag_version%' na branch '%main_branch%'...
git tag "%tag_version%" "%main_branch%"
if errorlevel 1 (
    echo [Erro] Falha ao criar a tag '%tag_version%'. Verifique se a tag ja existe ou se voce tem permissoes adequadas.
    exit /b 1
)

git push origin "%tag_version%"
if errorlevel 1 (
    echo [Erro] Falha ao enviar a tag '%tag_version%' para o GitHub. Verifique sua conexao ou permissoes.
    exit /b 1
)

echo Tag '%tag_version%' criada e enviada com sucesso a partir da branch '%main_branch%'!
exit /b
