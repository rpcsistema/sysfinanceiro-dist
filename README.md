# SysFinanceiro - Sistema Financeiro

## Instalador / Installer

Este repositório contém os arquivos de distribuição e instalação para o Sistema Financeiro (SysFinanceiro).

This repository contains the distribution and installation files for the Financial System (SysFinanceiro).

## Requisitos do Sistema / System Requirements

### Mínimos / Minimum:
- Windows 10+ ou Linux Ubuntu 18.04+ / Windows 10+ or Linux Ubuntu 18.04+
- 4GB RAM
- 1GB espaço livre em disco / 1GB free disk space
- Conexão com internet / Internet connection

### Recomendados / Recommended:
- Windows 11+ ou Linux Ubuntu 20.04+ / Windows 11+ or Linux Ubuntu 20.04+
- 8GB RAM
- 2GB espaço livre em disco / 2GB free disk space

## Instalação / Installation

### Windows
Execute o instalador como administrador:
```cmd
install.bat
```

### Linux/Unix
Execute o script de instalação:
```bash
chmod +x install.sh
./install.sh
```

## Desinstalação / Uninstallation

### Windows
```cmd
uninstall.bat
```

### Linux/Unix
```bash
chmod +x uninstall.sh
./uninstall.sh
```

## Estrutura do Projeto / Project Structure

```
sysfinanceiro-dist/
├── install.sh          # Instalador Linux/Unix
├── install.bat         # Instalador Windows
├── uninstall.sh        # Desinstalador Linux/Unix
├── uninstall.bat       # Desinstalador Windows
├── bin/                # Arquivos executáveis
├── config/             # Arquivos de configuração
├── docs/               # Documentação
└── README.md           # Este arquivo
```

## Licença / License

Este software é distribuído sob licença proprietária.
This software is distributed under proprietary license.
