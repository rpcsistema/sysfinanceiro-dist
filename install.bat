@echo off
REM SysFinanceiro - Instalador Windows
REM Installer for SysFinanceiro Financial System

setlocal EnableDelayedExpansion

REM Configurações
set "APP_NAME=SysFinanceiro"
set "INSTALL_DIR=%ProgramFiles%\SysFinanceiro"
set "CONFIG_DIR=%ProgramData%\SysFinanceiro"
set "LOG_DIR=%ProgramData%\SysFinanceiro\Logs"
set "REQUIRED_SPACE=1073741824"

REM Cores (limitadas no CMD)
set "COLOR_RESET="
set "COLOR_INFO=echo [INFO]"
set "COLOR_SUCCESS=echo [SUCCESS]"
set "COLOR_WARNING=echo [WARNING]"
set "COLOR_ERROR=echo [ERROR]"

echo.
echo =================================================
echo         SysFinanceiro - Instalador v1.0
echo         Sistema Financeiro - Installer
echo =================================================
echo.

REM Verificar se está executando como administrador
%COLOR_INFO% Verificando privilegios de administrador...
%COLOR_INFO% Checking administrator privileges...

net session >nul 2>&1
if %errorLevel% neq 0 (
    %COLOR_ERROR% Este instalador precisa ser executado como administrador
    %COLOR_ERROR% This installer needs to be run as administrator
    echo.
    echo Clique com o botao direito no arquivo e selecione "Executar como administrador"
    echo Right-click the file and select "Run as administrator"
    pause
    exit /b 1
)

%COLOR_SUCCESS% Privilegios de administrador confirmados
%COLOR_SUCCESS% Administrator privileges confirmed

REM Verificar sistema
%COLOR_INFO% Verificando sistema / Checking system...

for /f "tokens=4-5 delims=. " %%i in ('ver') do set "VERSION=%%i.%%j"
%COLOR_INFO% Sistema detectado / System detected: Windows %VERSION%

REM Verificar espaço em disco
for /f "tokens=3" %%a in ('dir /-c C:\ ^| find "bytes free"') do set "AVAILABLE_SPACE=%%a"
set "AVAILABLE_SPACE=!AVAILABLE_SPACE:,=!"

if !AVAILABLE_SPACE! LSS %REQUIRED_SPACE% (
    %COLOR_ERROR% Espaco insuficiente em disco / Insufficient disk space
    %COLOR_ERROR% Requerido / Required: 1GB, Disponivel / Available: !AVAILABLE_SPACE! bytes
    pause
    exit /b 1
)

%COLOR_SUCCESS% Sistema compativel / System compatible

REM Criar diretórios
%COLOR_INFO% Criando diretorios / Creating directories...

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

%COLOR_SUCCESS% Diretorios criados / Directories created

REM Instalar arquivos
%COLOR_INFO% Instalando arquivos / Installing files...

REM Copiar arquivos binários
if exist "bin" (
    xcopy "bin\*" "%INSTALL_DIR%\" /E /I /Y >nul 2>&1
)

REM Copiar arquivos de configuração
if exist "config" (
    xcopy "config\*" "%CONFIG_DIR%\" /E /I /Y >nul 2>&1
)

REM Copiar documentação
if exist "docs" (
    xcopy "docs\*" "%INSTALL_DIR%\docs\" /E /I /Y >nul 2>&1
)

%COLOR_SUCCESS% Arquivos instalados / Files installed

REM Adicionar ao PATH
%COLOR_INFO% Configurando variaveis de ambiente / Setting environment variables...

REM Adicionar diretório de instalação ao PATH do sistema
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do set "CURRENT_PATH=%%b"

echo !CURRENT_PATH! | find /i "%INSTALL_DIR%" >nul
if errorlevel 1 (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH /t REG_EXPAND_SZ /d "!CURRENT_PATH!;%INSTALL_DIR%" /f >nul
    %COLOR_SUCCESS% PATH atualizado / PATH updated
) else (
    %COLOR_INFO% PATH ja contem o diretorio de instalacao / PATH already contains installation directory
)

REM Criar entradas no menu iniciar
%COLOR_INFO% Criando atalhos / Creating shortcuts...

set "START_MENU=%ProgramData%\Microsoft\Windows\Start Menu\Programs"
if not exist "%START_MENU%\SysFinanceiro" mkdir "%START_MENU%\SysFinanceiro"

REM Criar atalho para desinstalador
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\CreateShortcut.vbs"
echo sLinkFile = "%START_MENU%\SysFinanceiro\Desinstalar SysFinanceiro.lnk" >> "%TEMP%\CreateShortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\CreateShortcut.vbs"
echo oLink.TargetPath = "%~dp0uninstall.bat" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.WorkingDirectory = "%~dp0" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Description = "Desinstalar SysFinanceiro" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Save >> "%TEMP%\CreateShortcut.vbs"
cscript "%TEMP%\CreateShortcut.vbs" >nul 2>&1
del "%TEMP%\CreateShortcut.vbs" >nul 2>&1

%COLOR_SUCCESS% Atalhos criados / Shortcuts created

REM Configurar permissões
%COLOR_INFO% Configurando permissoes / Setting permissions...

icacls "%INSTALL_DIR%" /grant "Users:(RX)" /T >nul 2>&1
icacls "%CONFIG_DIR%" /grant "Users:(M)" /T >nul 2>&1
icacls "%LOG_DIR%" /grant "Users:(M)" /T >nul 2>&1

%COLOR_SUCCESS% Permissoes configuradas / Permissions set

echo.
%COLOR_SUCCESS% =================================================
%COLOR_SUCCESS%    %APP_NAME% instalado com sucesso!
%COLOR_SUCCESS%    %APP_NAME% installed successfully!
%COLOR_SUCCESS% =================================================
echo.
%COLOR_INFO% Diretorio de instalacao / Installation directory: %INSTALL_DIR%
%COLOR_INFO% Configuracoes / Configuration: %CONFIG_DIR%
%COLOR_INFO% Logs: %LOG_DIR%
echo.
%COLOR_INFO% Para desinstalar, execute / To uninstall, run: uninstall.bat
echo.
%COLOR_INFO% Pressione qualquer tecla para finalizar...
%COLOR_INFO% Press any key to finish...
pause >nul

endlocal