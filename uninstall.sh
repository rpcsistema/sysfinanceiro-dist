#!/bin/bash

# SysFinanceiro - Desinstalador Linux/Unix
# Uninstaller for SysFinanceiro Financial System

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
    echo "      SysFinanceiro - Desinstalador v1.0"
    echo "      Sistema Financeiro - Uninstaller"
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

confirm_uninstall() {
    print_warning "ATENÇÃO / WARNING:"
    print_warning "Esta operação removerá completamente o $APP_NAME do sistema"
    print_warning "This operation will completely remove $APP_NAME from the system"
    print_warning ""
    print_warning "Os seguintes diretórios serão removidos:"
    print_warning "The following directories will be removed:"
    print_warning "- $INSTALL_DIR"
    print_warning "- $CONFIG_DIR"
    print_warning "- $LOG_DIR"
    print_warning ""
    
    read -p "Deseja continuar? / Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Desinstalação cancelada / Uninstallation cancelled"
        exit 0
    fi
}

stop_services() {
    print_info "Parando serviços / Stopping services..."
    
    # Parar e desabilitar serviços do systemd se existirem
    if systemctl is-active --quiet sysfinanceiro 2>/dev/null; then
        systemctl stop sysfinanceiro
        print_success "Serviço parado / Service stopped"
    fi
    
    if systemctl is-enabled --quiet sysfinanceiro 2>/dev/null; then
        systemctl disable sysfinanceiro
        print_success "Serviço desabilitado / Service disabled"
    fi
    
    # Remover arquivo de serviço
    if [[ -f "$SERVICE_DIR/sysfinanceiro.service" ]]; then
        rm -f "$SERVICE_DIR/sysfinanceiro.service"
        systemctl daemon-reload
        print_success "Arquivo de serviço removido / Service file removed"
    fi
}

remove_symlinks() {
    print_info "Removendo links simbólicos / Removing symbolic links..."
    
    if [[ -L "$BIN_DIR/sysfinanceiro" ]]; then
        rm -f "$BIN_DIR/sysfinanceiro"
        print_success "Link simbólico removido / Symbolic link removed"
    fi
}

remove_directories() {
    print_info "Removendo diretórios / Removing directories..."
    
    # Remover diretório de instalação
    if [[ -d "$INSTALL_DIR" ]]; then
        rm -rf "$INSTALL_DIR"
        print_success "Diretório de instalação removido / Installation directory removed"
    fi
    
    # Remover diretório de configuração (com confirmação)
    if [[ -d "$CONFIG_DIR" ]]; then
        print_warning "Remover configurações? / Remove configurations? (y/N): "
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$CONFIG_DIR"
            print_success "Configurações removidas / Configurations removed"
        else
            print_info "Configurações mantidas / Configurations kept"
        fi
    fi
    
    # Remover diretório de logs (com confirmação)
    if [[ -d "$LOG_DIR" ]]; then
        print_warning "Remover logs? / Remove logs? (y/N): "
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$LOG_DIR"
            print_success "Logs removidos / Logs removed"
        else
            print_info "Logs mantidos / Logs kept"
        fi
    fi
}

cleanup_cache() {
    print_info "Limpando cache / Cleaning cache..."
    
    # Limpar cache do usuário root
    rm -rf /root/.sysfinanceiro 2>/dev/null || true
    
    # Limpar cache de todos os usuários
    for user_home in /home/*; do
        if [[ -d "$user_home/.sysfinanceiro" ]]; then
            rm -rf "$user_home/.sysfinanceiro" 2>/dev/null || true
        fi
    done
    
    print_success "Cache limpo / Cache cleaned"
}

main() {
    print_banner
    
    print_info "Iniciando desinstalação do $APP_NAME..."
    print_info "Starting $APP_NAME uninstallation..."
    
    check_root
    confirm_uninstall
    stop_services
    remove_symlinks
    remove_directories
    cleanup_cache
    
    print_success "================================================="
    print_success "   $APP_NAME desinstalado com sucesso!"
    print_success "   $APP_NAME uninstalled successfully!"
    print_success "================================================="
    print_info "Obrigado por usar o $APP_NAME!"
    print_info "Thank you for using $APP_NAME!"
}

# Executar desinstalação
main "$@"