@echo off
REM SysFinanceiro - Desinstalador Windows
REM Uninstaller for SysFinanceiro Financial System

setlocal EnableDelayedExpansion

REM Configurações
set "APP_NAME=SysFinanceiro"
set "INSTALL_DIR=%ProgramFiles%\SysFinanceiro"
set "CONFIG_DIR=%ProgramData%\SysFinanceiro"
set "LOG_DIR=%ProgramData%\SysFinanceiro\Logs"
set "START_MENU=%ProgramData%\Microsoft\Windows\Start Menu\Programs\SysFinanceiro"

REM Cores (limitadas no CMD)
set "COLOR_INFO=echo [INFO]"
set "COLOR_SUCCESS=echo [SUCCESS]"
set "COLOR_WARNING=echo [WARNING]"
set "COLOR_ERROR=echo [ERROR]"

echo.
echo =================================================
echo       SysFinanceiro - Desinstalador v1.0
echo       Sistema Financeiro - Uninstaller
echo =================================================
echo.

REM Verificar se está executando como administrador
%COLOR_INFO% Verificando privilegios de administrador...
%COLOR_INFO% Checking administrator privileges...

net session >nul 2>&1
if %errorLevel% neq 0 (
    %COLOR_ERROR% Este desinstalador precisa ser executado como administrador
    %COLOR_ERROR% This uninstaller needs to be run as administrator
    echo.
    echo Clique com o botao direito no arquivo e selecione "Executar como administrador"
    echo Right-click the file and select "Run as administrator"
    pause
    exit /b 1
)

%COLOR_SUCCESS% Privilegios de administrador confirmados
%COLOR_SUCCESS% Administrator privileges confirmed

REM Confirmar desinstalação
echo.
%COLOR_WARNING% ATENCAO / WARNING:
%COLOR_WARNING% Esta operacao removera completamente o %APP_NAME% do sistema
%COLOR_WARNING% This operation will completely remove %APP_NAME% from the system
echo.
%COLOR_WARNING% Os seguintes diretorios serao removidos:
%COLOR_WARNING% The following directories will be removed:
%COLOR_WARNING% - %INSTALL_DIR%
%COLOR_WARNING% - %CONFIG_DIR%
%COLOR_WARNING% - %START_MENU%
echo.

set /p "CONFIRM=Deseja continuar? / Do you want to continue? (y/N): "
if /i not "%CONFIRM%"=="y" (
    %COLOR_INFO% Desinstalacao cancelada / Uninstallation cancelled
    pause
    exit /b 0
)

REM Parar processos do SysFinanceiro
%COLOR_INFO% Parando processos / Stopping processes...

taskkill /f /im "sysfinanceiro.exe" >nul 2>&1
taskkill /f /im "sysfinanceiro-service.exe" >nul 2>&1

%COLOR_SUCCESS% Processos parados / Processes stopped

REM Parar e remover serviços
%COLOR_INFO% Parando servicos / Stopping services...

sc query "SysFinanceiro" >nul 2>&1
if %errorLevel% equ 0 (
    sc stop "SysFinanceiro" >nul 2>&1
    sc delete "SysFinanceiro" >nul 2>&1
    %COLOR_SUCCESS% Servico removido / Service removed
)

REM Remover do PATH
%COLOR_INFO% Removendo do PATH / Removing from PATH...

for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do set "CURRENT_PATH=%%b"

set "NEW_PATH=!CURRENT_PATH!"
set "NEW_PATH=!NEW_PATH:;%INSTALL_DIR%=!"
set "NEW_PATH=!NEW_PATH:%INSTALL_DIR%;=!"
set "NEW_PATH=!NEW_PATH:%INSTALL_DIR%=!"

if not "!NEW_PATH!"=="!CURRENT_PATH!" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH /t REG_EXPAND_SZ /d "!NEW_PATH!" /f >nul
    %COLOR_SUCCESS% PATH atualizado / PATH updated
)

REM Remover atalhos do menu iniciar
%COLOR_INFO% Removendo atalhos / Removing shortcuts...

if exist "%START_MENU%" (
    rmdir /s /q "%START_MENU%" >nul 2>&1
    %COLOR_SUCCESS% Atalhos removidos / Shortcuts removed
)

REM Remover diretório de instalação
%COLOR_INFO% Removendo diretorios / Removing directories...

if exist "%INSTALL_DIR%" (
    rmdir /s /q "%INSTALL_DIR%" >nul 2>&1
    if exist "%INSTALL_DIR%" (
        %COLOR_WARNING% Alguns arquivos podem estar em uso. Tentando novamente...
        %COLOR_WARNING% Some files may be in use. Trying again...
        timeout /t 3 >nul
        rmdir /s /q "%INSTALL_DIR%" >nul 2>&1
    )
    if not exist "%INSTALL_DIR%" (
        %COLOR_SUCCESS% Diretorio de instalacao removido / Installation directory removed
    ) else (
        %COLOR_WARNING% Nao foi possivel remover completamente o diretorio de instalacao
        %COLOR_WARNING% Could not completely remove installation directory
    )
)

REM Confirmar remoção de configurações e logs
echo.
set /p "REMOVE_CONFIG=Remover configuracoes? / Remove configurations? (y/N): "
if /i "%REMOVE_CONFIG%"=="y" (
    if exist "%CONFIG_DIR%" (
        rmdir /s /q "%CONFIG_DIR%" >nul 2>&1
        if not exist "%CONFIG_DIR%" (
            %COLOR_SUCCESS% Configuracoes removidas / Configurations removed
        )
    )
) else (
    %COLOR_INFO% Configuracoes mantidas / Configurations kept
)

REM Limpar registro
%COLOR_INFO% Limpando registro / Cleaning registry...

reg delete "HKLM\SOFTWARE\SysFinanceiro" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\SysFinanceiro" /f >nul 2>&1

%COLOR_SUCCESS% Registro limpo / Registry cleaned

REM Limpar cache de usuários
%COLOR_INFO% Limpando cache / Cleaning cache...

for /d %%u in (C:\Users\*) do (
    if exist "%%u\AppData\Local\SysFinanceiro" (
        rmdir /s /q "%%u\AppData\Local\SysFinanceiro" >nul 2>&1
    )
    if exist "%%u\AppData\Roaming\SysFinanceiro" (
        rmdir /s /q "%%u\AppData\Roaming\SysFinanceiro" >nul 2>&1
    )
)

%COLOR_SUCCESS% Cache limpo / Cache cleaned

echo.
%COLOR_SUCCESS% =================================================
%COLOR_SUCCESS%    %APP_NAME% desinstalado com sucesso!
%COLOR_SUCCESS%    %APP_NAME% uninstalled successfully!
%COLOR_SUCCESS% =================================================
echo.
%COLOR_INFO% Obrigado por usar o %APP_NAME%!
%COLOR_INFO% Thank you for using %APP_NAME%!
echo.
%COLOR_INFO% Pressione qualquer tecla para finalizar...
%COLOR_INFO% Press any key to finish...
pause >nul

endlocal