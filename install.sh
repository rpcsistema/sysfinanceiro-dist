#!/bin/bash

# SysFinanceiro - Instalador Linux/Unix
# Installer for SysFinanceiro Financial System

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
APP_NAME="SysFinanceiro"
INSTALL_DIR="/opt/sysfinanceiro"
BIN_DIR="/usr/local/bin"
CONFIG_DIR="/etc/sysfinanceiro"
SERVICE_DIR="/etc/systemd/system"
LOG_DIR="/var/log/sysfinanceiro"

print_banner() {
    echo -e "${BLUE}"
    echo "================================================="
    echo "        SysFinanceiro - Instalador v1.0"
    echo "        Sistema Financeiro - Installer"
    echo "================================================="
    echo -e "${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Este script precisa ser executado como root (sudo)"
        print_error "This script needs to be run as root (sudo)"
        exit 1
    fi
}

check_system() {
    print_info "Verificando sistema / Checking system..."
    
    # Verificar distribuição Linux
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        print_info "Sistema detectado / System detected: $NAME $VERSION"
    else
        print_warning "Não foi possível detectar a distribuição / Could not detect distribution"
    fi
    
    # Verificar espaço em disco
    AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')
    REQUIRED_SPACE=1048576 # 1GB em KB
    
    if [[ $AVAILABLE_SPACE -lt $REQUIRED_SPACE ]]; then
        print_error "Espaço insuficiente em disco / Insufficient disk space"
        print_error "Requerido / Required: 1GB, Disponível / Available: $(($AVAILABLE_SPACE/1024))MB"
        exit 1
    fi
    
    print_success "Sistema compatível / System compatible"
}

create_directories() {
    print_info "Criando diretórios / Creating directories..."
    
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$LOG_DIR"
    
    print_success "Diretórios criados / Directories created"
}

install_files() {
    print_info "Instalando arquivos / Installing files..."
    
    # Copiar arquivos binários
    if [[ -d "bin" ]]; then
        cp -r bin/* "$INSTALL_DIR/" 2>/dev/null || true
        chmod +x "$INSTALL_DIR"/* 2>/dev/null || true
    fi
    
    # Copiar arquivos de configuração
    if [[ -d "config" ]]; then
        cp -r config/* "$CONFIG_DIR/" 2>/dev/null || true
    fi
    
    # Copiar documentação
    if [[ -d "docs" ]]; then
        cp -r docs "$INSTALL_DIR/" 2>/dev/null || true
    fi
    
    print_success "Arquivos instalados / Files installed"
}

create_symlinks() {
    print_info "Criando links simbólicos / Creating symbolic links..."
    
    # Criar link para o executável principal
    if [[ -f "$INSTALL_DIR/sysfinanceiro" ]]; then
        ln -sf "$INSTALL_DIR/sysfinanceiro" "$BIN_DIR/sysfinanceiro"
    fi
    
    print_success "Links criados / Links created"
}

setup_permissions() {
    print_info "Configurando permissões / Setting up permissions..."
    
    chown -R root:root "$INSTALL_DIR"
    chown -R root:root "$CONFIG_DIR"
    chown -R root:root "$LOG_DIR"
    
    chmod -R 755 "$INSTALL_DIR"
    chmod -R 644 "$CONFIG_DIR"
    chmod -R 755 "$LOG_DIR"
    
    print_success "Permissões configuradas / Permissions set"
}

main() {
    print_banner
    
    print_info "Iniciando instalação do $APP_NAME..."
    print_info "Starting $APP_NAME installation..."
    
    check_root
    check_system
    create_directories
    install_files
    create_symlinks
    setup_permissions
    
    print_success "================================================="
    print_success "   $APP_NAME instalado com sucesso!"
    print_success "   $APP_NAME installed successfully!"
    print_success "================================================="
    print_info "Diretório de instalação / Installation directory: $INSTALL_DIR"
    print_info "Configurações / Configuration: $CONFIG_DIR"
    print_info "Logs: $LOG_DIR"
    print_info ""
    print_info "Para desinstalar, execute / To uninstall, run: sudo ./uninstall.sh"
}

# Executar instalação
main "$@"