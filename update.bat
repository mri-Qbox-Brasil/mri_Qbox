@echo off
setlocal

:: Verifica se a pasta é um repositório Git
if exist .git (
    echo O repositório já existe. Atualizando e copiando arquivos...
    goto UpdateAndCopy
) else (
    echo Iniciando novo repositório Git...
    git init
    git remote add origin https://github.com/mri-Qbox-Brasil/mri_Qbox.git
    echo.
    echo Puxando a branch main do repositório remoto...
    git pull origin main
    echo.
    echo Copiando arquivos para a pasta de destino...
    xcopy /s /y .\*.* ..\destino\ /exclude:update.bat
    echo.
    echo Arquivos copiados com sucesso!
    pause
    goto End
)

:UpdateAndCopy
echo Atualizando o repositório local...
git pull origin main
echo.
echo Copiando arquivos para a pasta de destino...
xcopy /s /y .\*.* ..\destino\ /exclude:update.bat
echo.
echo Arquivos copiados com sucesso!
pause

:End
endlocal