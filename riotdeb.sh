#!/bin/bash

# =============================================================================
# RIOT.DEB - Script de Instalación Avanzado para Debian
# =============================================================================
# Autor: Script Expert
# Version: 1.0
# Descripcion: Instalacion automatizada para Debian (instalacion minima)
# =============================================================================

# Colores ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/riot_deb_install.log"
INSTALLED_PACKAGES_LOG="$SCRIPT_DIR/installed_packages.log"
ADDED_REPOS_LOG="$SCRIPT_DIR/added_repos.log"
DEVICE_TYPE=""

# =============================================================================
# FUNCIONES DE UTILIDAD
# =============================================================================

print_header() {
    echo -e "${CYAN}========================================================================${NC}"
    echo -e "$1"
    echo -e "${CYAN}========================================================================${NC}"
}

print_success() {
    echo -e "${GREEN}[OK] $1${NC}"
    echo "[$(date)] OK: $1" >> "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
    echo "[$(date)] ERROR: $1" >> "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[WARN] $1${NC}"
    echo "[$(date)] WARN: $1" >> "$LOG_FILE"
}

print_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
    echo "[$(date)] INFO: $1" >> "$LOG_FILE"
}

print_question() {
    echo -e "${MAGENTA}[?] $1${NC}"
}

check_root() {
    if [ "$EUID" -eq 0 ]; then 
        print_warning "Ejecutando como root"
    else
        print_success "Ejecutando como usuario normal"
    fi
    return 0
}

run_sudo() {
    if command -v sudo &> /dev/null && [ "$EUID" -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}

log_installed_package() {
    local package="$1"
    if ! grep -q "^$package$" "$INSTALLED_PACKAGES_LOG" 2>/dev/null; then
        echo "$package" >> "$INSTALLED_PACKAGES_LOG"
    fi
}

log_added_repo() {
    local repo="$1"
    if ! grep -q "^$repo$" "$ADDED_REPOS_LOG" 2>/dev/null; then
        echo "$repo" >> "$ADDED_REPOS_LOG"
    fi
}

package_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
    return $?
}

safe_install() {
    local package="$1"
    if ! package_installed "$package"; then
        print_info "Instalando $package..."
        if run_sudo apt install -y "$package" 2>/dev/null; then
            print_success "$package instalado"
            log_installed_package "$package"
            return 0
        else
            print_warning "Problema con $package, intentando reparar..."
            run_sudo apt --fix-broken install -y
            if run_sudo apt install -y "$package"; then
                print_success "$package instalado"
                log_installed_package "$package"
                return 0
            else
                print_error "No se pudo instalar $package"
                return 1
            fi
        fi
    else
        print_warning "$package ya instalado"
        return 0
    fi
}

show_banner() {
    clear
    echo -e "${MAGENTA}"
    echo "██████╗ ██╗ ██████╗ ████████╗██████╗ ███████╗██████╗ "
    echo "██╔══██╗██║██╔═══██╗╚══██╔══╝██╔══██╗██╔════╝██╔══██╗"
    echo "██████╔╝██║██║   ██║   ██║   ██║  ██║█████╗  ██████╔╝"
    echo "██╔══██╗██║██║   ██║   ██║   ██║  ██║██╔══╝  ██╔══██╗"
    echo "██║  ██║██║╚██████╔╝   ██║   ██████╔╝███████╗██████╔╝"
    echo "╚═╝  ╚═╝╚═╝ ╚═════╝    ╚═╝   ╚═════╝ ╚══════╝╚═════╝"
    echo -e "${NC}"
    echo -e "${CYAN}${BOLD}          Script de Instalacion Avanzado para Debian${NC}"
    echo -e "${YELLOW}                     v1.0 - RIOT.DEB${NC}"
    echo -e "${YELLOW}                 qazlinux - Ángel R. Torrealba Sánchez${NC}"
    echo
}

# =============================================================================
# VERIFICACIONES INICIALES
# =============================================================================

check_internet() {
    print_info "Verificando conexion a internet..."
    if ! ping -c 1 deb.debian.org &> /dev/null; then
        print_error "Sin conexion a internet"
        exit 1
    fi
    print_success "Conexion verificada"
}

check_disk_space() {
    available=$(df / | awk 'NR==2 {print $4}')
    if [ "$available" -lt 5242880 ]; then
        print_error "Espacio insuficiente (minimo 5GB)"
        exit 1
    fi
    print_success "Espacio suficiente"
}

backup_configs() {
    BACKUP_DIR="$HOME/riot_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp /etc/apt/sources.list "$BACKUP_DIR/" 2>/dev/null
    cp -r /etc/apt/sources.list.d/ "$BACKUP_DIR/" 2>/dev/null
    cp /etc/default/grub "$BACKUP_DIR/" 2>/dev/null
    print_success "Backup en: $BACKUP_DIR"
}

fix_broken_deps() {
    print_info "Reparando dependencias rotas..."
    run_sudo apt --fix-broken install -y
    print_success "Dependencias reparadas"
}

# =============================================================================
# DESINSTALACION DE APLICACIONES (UNICA en opcion 6)
# =============================================================================

uninstall_application() {
    local package="$1"
    print_question "¿Desinstalar $package y sus dependencias? (s/n): "
    read -r confirm
    if [[ "$confirm" =~ ^[Ss]$ ]]; then
        run_sudo apt remove --purge -y "$package"
        print_success "$package desinstalado"
        sed -i "/^$package$/d" "$INSTALLED_PACKAGES_LOG" 2>/dev/null
    fi
}

show_installed_apps_menu() {
    show_banner
    print_header "GESTION DE APLICACIONES INSTALADAS"
    
    if [ ! -f "$INSTALLED_PACKAGES_LOG" ] || [ ! -s "$INSTALLED_PACKAGES_LOG" ]; then
        print_warning "No hay aplicaciones instaladas por este script"
        print_question "Volver al menu principal? (s/n): "
        read -r back
        [[ "$back" =~ ^[Ss]$ ]] && show_main_menu
        return 0
    fi
    
    echo -e "${GREEN}Aplicaciones instaladas por RIOT:${NC}"
    echo ""
    cat -n "$INSTALLED_PACKAGES_LOG"
    echo ""
    echo -e "${CYAN}1) Desinstalar aplicacion especifica${NC}"
    echo -e "${CYAN}2) Desinstalar todas las aplicaciones${NC}"
    echo -e "${CYAN}3) Ver detalles de aplicacion${NC}"
    echo -e "${CYAN}4) Volver al menu principal${NC}"
    echo ""
    read -p "$(echo -e ${MAGENTA}"Opcion: "${NC})" sub_choice
    
    case $sub_choice in
        1)
            echo -n "Numero de aplicacion: "
            read app_num
            package=$(sed -n "${app_num}p" "$INSTALLED_PACKAGES_LOG")
            if [ -n "$package" ]; then
                uninstall_application "$package"
            fi
            show_installed_apps_menu
            ;;
        2)
            print_warning "Esto desinstalara TODAS las aplicaciones"
            print_question "Confirmar? (s/n): "
            read confirm
            if [[ "$confirm" =~ ^[Ss]$ ]]; then
                while read -r package; do
                    run_sudo apt remove --purge -y "$package" 2>/dev/null
                done < "$INSTALLED_PACKAGES_LOG"
                rm -f "$INSTALLED_PACKAGES_LOG"
                print_success "Todas las aplicaciones desinstaladas"
            fi
            show_installed_apps_menu
            ;;
        3)
            echo -n "Numero de aplicacion: "
            read app_num
            package=$(sed -n "${app_num}p" "$INSTALLED_PACKAGES_LOG")
            if [ -n "$package" ]; then
                echo -e "${CYAN}Detalles de $package:${NC}"
                apt show "$package" 2>/dev/null || echo "No se encontraron detalles"
                read -p "Presiona Enter para continuar..."
            fi
            show_installed_apps_menu
            ;;
        4) show_main_menu ;;
        *) show_installed_apps_menu ;;
    esac
}

# =============================================================================
# INSTALACION BASE
# =============================================================================

install_essential_kernel_packages() {
    print_header "Instalando paquetes esenciales del kernel"
    KERNEL_PACKAGES="build-essential linux-headers-amd64 firmware-linux-free"
    for package in $KERNEL_PACKAGES; do
        safe_install "$package"
    done
}

install_network_manager() {
    if ! package_installed "network-manager"; then
        safe_install "network-manager"
        safe_install "network-manager-gnome"
        run_sudo systemctl enable NetworkManager
        run_sudo systemctl start NetworkManager
        print_success "Network Manager instalado"
    fi
}

install_xfce_desktop() {
    if ! package_installed "xfce4"; then
        print_header "Instalando XFCE Desktop"
        XFCE_PACKAGES="kitty lightdm thunar thunar-archive-plugin thunar-volman \
        xfce4 xfce4-appfinder xfce4-battery-plugin xfce4-clipman-plugin \
        xfce4-screensaver xfce4-screenshooter xfce4-whiskermenu-plugin xfwm4 \
        xfce4-power-manager xfce4-power-manager-plugins xfce4-panel xfce4-notifyd \
        xfce4-docklike-plugin blueman bluez wmctrl udiskie"
        for package in $XFCE_PACKAGES; do
            safe_install "$package"
        done
        print_success "XFCE instalado"
    fi
}

detect_device_type() {
    print_info "Detectando tipo de equipo..."
    local is_laptop=0
    
    [ -d "/sys/class/power_supply/BAT0" ] || [ -d "/sys/class/power_supply/BAT1" ] && is_laptop=1
    [ -d "/proc/acpi/button/lid" ] && is_laptop=1
    
    if command -v dmidecode &> /dev/null; then
        run_sudo dmidecode -s chassis-type 2>/dev/null | grep -qi "laptop\|notebook\|portable" && is_laptop=1
    fi
    
    if [ "$is_laptop" -eq 1 ]; then
        DEVICE_TYPE="laptop"
        print_success "Dispositivo: LAPTOP"
    else
        DEVICE_TYPE="desktop"
        print_success "Dispositivo: DESKTOP"
    fi
}

install_laptop_specific_packages() {
    if [ "$DEVICE_TYPE" = "laptop" ]; then
        print_header "Instalando paquetes especificos para laptop"
        LAPTOP_PACKAGES="acpi acpitool acpi-support laptop-detect brightnessctl"
        for package in $LAPTOP_PACKAGES; do
            safe_install "$package" 2>/dev/null
        done
        print_success "Paquetes laptop instalados"
    else
        print_info "Equipo de escritorio - omitiendo paquetes laptop"
    fi
}

# =============================================================================
# DETECCION E INSTALACION DE NVIDIA (CON OPCION DE SKIP)
# =============================================================================
detect_and_install_nvidia() {
    print_header "CONFIGURACION DE NVIDIA"
    
    if ! lspci | grep -i "vga" | grep -qi "nvidia"; then
        print_info "No se detecto GPU NVIDIA. Continuando..."
        return 0
    fi
    
    print_success "GPU NVIDIA detectada"
    
    echo -e "${GREEN}Opciones para instalar NVIDIA:${NC}"
    echo -e "${CYAN}1) Instalar automaticamente usando nvidia-detect (recomendado)${NC}"
    echo -e "${CYAN}2) Omitir instalacion - lo hare manualmente despues${NC}"
    echo -e "${YELLOW}ADVERTENCIA: La instalacion manual de NVIDIA puede ser compleja.${NC}"
    echo -e "${YELLOW}Se recomienda usar nvidia-detect para identificar el driver correcto.${NC}"
    echo
    read -p "$(echo -e ${MAGENTA}"Selecciona una opcion [1-2]: "${NC})" nvidia_choice
    
    case $nvidia_choice in
        1)
            safe_install "nvidia-detect"
            safe_install "linux-headers-amd64"
            run_sudo nvidia-detect
            print_question "¿Instalar el driver recomendado? (s/n): "
            read -r install_driver
            if [[ "$install_driver" =~ ^[Ss]$ ]]; then
                safe_install "nvidia-driver"
                safe_install "firmware-misc-nonfree"
                print_success "Driver NVIDIA instalado"
                print_warning "Recomendado reiniciar el sistema"
            fi
            ;;
        2)
            print_info "Omitiendo instalacion automatica de NVIDIA"
            print_warning "Recuerda instalar los drivers manualmente"
            ;;
        *) print_error "Opcion invalida" ;;
    esac
}

install_base_system() {
    show_banner
    detect_device_type
    install_essential_kernel_packages
    detect_and_install_nvidia
    install_network_manager
    install_xfce_desktop
    install_laptop_specific_packages
    
    print_question "Volver al menu principal? (s/n): "
    read -r back_to_menu
    [[ "$back_to_menu" =~ ^[Ss]$ ]] && show_main_menu
}

configure_grub() {
    if [ -f "/etc/default/grub" ]; then
        if ! grep -q "quiet loglevel=1" /etc/default/grub; then
            local grub_cmdline="quiet loglevel=1 rd.udev.log_level=0 systemd.show_status=false"
            run_sudo sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=\".*\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$grub_cmdline\"/" /etc/default/grub
            run_sudo update-grub
            print_success "GRUB configurado"
        fi
    fi
}

configure_system() {
    show_banner
    configure_grub
    if [ -f "/etc/lightdm/lightdm.conf" ]; then
        run_sudo sed -i 's/^#user-session=default/user-session=xfce4/' /etc/lightdm/lightdm.conf
        print_success "LightDM configurado"
    fi
    print_question "Volver al menu principal? (s/n): "
    read -r back_to_menu
    [[ "$back_to_menu" =~ ^[Ss]$ ]] && show_main_menu
}

# =============================================================================
# CONFIGURACION DE REPOSITORIOS (CORREGIDA)
# =============================================================================

configure_main_repositories() {
    print_header "Configurando Repositorios Principales"
    
    if grep -q "deb http://deb.debian.org/debian trixie" /etc/apt/sources.list; then
        print_warning "Repositorios ya configurados"
        print_question "¿Reinstalar? (s/n): "
        read -r reinstall
        [[ ! "$reinstall" =~ ^[Ss]$ ]] && return 0
    fi
    
    echo -e "${GREEN}Selecciona componentes:${NC}"
    echo -e "${CYAN}1) Libre (main)${NC}"
    echo -e "${CYAN}2) Contrib${NC}"
    echo -e "${CYAN}3) Non-Free${NC}"
    echo -e "${CYAN}4) Todos (main contrib non-free non-free-firmware)${NC}"
    echo -e "${GREEN}5) Cancelar${NC}"
    read -p "$(echo -e ${MAGENTA}"Opcion: "${NC})" component_choice
    
    case $component_choice in
        1) components="main" ;;
        2) components="contrib" ;;
        3) components="non-free" ;;
        4) components="main contrib non-free non-free-firmware" ;;
        5) return 0 ;;
        *) print_error "Opcion invalida"; return 1 ;;
    esac
    
    run_sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak."$(date +%Y%m%d_%H%M%S)" 2>/dev/null
    
    cat <<EOF | run_sudo tee /etc/apt/sources.list
deb http://deb.debian.org/debian trixie $components
deb-src http://deb.debian.org/debian trixie $components
deb http://deb.debian.org/debian-security/ trixie-security $components
deb-src http://deb.debian.org/debian-security/ trixie-security $components
deb http://deb.debian.org/debian trixie-updates $components
deb-src http://deb.debian.org/debian trixie-updates $components
EOF
    
    run_sudo apt update
    fix_broken_deps
    print_success "Repositorios configurados con: $components"
}

configure_backports() {
    print_question "¿Instalar Backports? (s/n): "
    read -r install_backports
    [[ ! "$install_backports" =~ ^[Ss]$ ]] && return 0
    
    if [ -f "/etc/apt/sources.list.d/debian-backports.sources" ]; then
        print_warning "Backports ya configurado"
        return 0
    fi
    
    cat <<EOF | run_sudo tee /etc/apt/sources.list.d/debian-backports.sources
Types: deb deb-src
URIs: http://deb.debian.org/debian
Suites: trixie-backports
Components: main
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
    log_added_repo "/etc/apt/sources.list.d/debian-backports.sources"
    print_success "Backports configurado"
}

configure_multimedia() {
    print_question "¿Instalar repositorios Multimedia? (s/n): "
    read -r install_multimedia
    [[ ! "$install_multimedia" =~ ^[Ss]$ ]] && return 0
    
    if [ -f "/etc/apt/sources.list.d/dmo.list" ]; then
        print_warning "Multimedia ya configurado"
        return 0
    fi
    
    # PASO 1: Asegurar dependencias básicas
    print_info "Verificando dependencias..."
    if ! command -v wget &> /dev/null; then
        run_sudo apt update
        run_sudo apt install -y wget apt-transport-https
    fi
    
    # PASO 2: Descargar e instalar keyring
    print_info "Descargando keyring de deb-multimedia..."
    wget -q https://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2024.9.1_all.deb -O /tmp/dmm-keyring.deb
    
    if [ ! -f /tmp/dmm-keyring.deb ]; then
        print_error "No se pudo descargar el keyring"
        return 1
    fi
    
    print_info "Instalando keyring..."
    run_sudo dpkg -i --force-depends /tmp/dmm-keyring.deb 2>/dev/null
    rm -f /tmp/dmm-keyring.deb
    
    # PASO 3: Verificar instalación del keyring
    if ! package_installed "deb-multimedia-keyring"; then
        print_error "No se pudo instalar deb-multimedia-keyring"
        return 1
    fi
    print_success "Keyring instalado correctamente"
    
    # PASO 4: Configurar repositorio (usando .list en lugar de .sources por compatibilidad)
    print_info "Configurando repositorio Multimedia..."
    cat <<EOF | run_sudo tee /etc/apt/sources.list.d/dmo.list
deb https://www.deb-multimedia.org trixie main non-free
deb-src https://www.deb-multimedia.org trixie main non-free
deb https://www.deb-multimedia.org trixie-backports main
deb-src https://www.deb-multimedia.org trixie-backports main
EOF
    
    # PASO 5: Actualizar repositorios
    run_sudo apt update
    
    print_success "Repositorio Multimedia configurado correctamente"
    log_added_repo "/etc/apt/sources.list.d/dmo.list"
}
configure_extrepo() {
    print_question "¿Instalar Extrepo? (s/n): "
    read -r install_extrepo
    [[ ! "$install_extrepo" =~ ^[Ss]$ ]] && return 0
    
    if ! package_installed "extrepo"; then
        safe_install "extrepo"
        safe_install "extrepo-offline-data"
    fi
    
    print_question "¿Habilitar non-free en Extrepo? (s/n): "
    read -r extrepo_nonfree
    if [[ "$extrepo_nonfree" =~ ^[Ss]$ ]]; then
        run_sudo sed -i 's/^# - contrib/- contrib/' /etc/extrepo/config.yaml
        run_sudo sed -i 's/^# - non-free/- non-free/' /etc/extrepo/config.yaml
    fi
    print_success "Extrepo configurado"
}

configure_all_repositories() {
    show_banner
    configure_main_repositories
    run_sudo apt update
    configure_backports
    configure_multimedia
    configure_extrepo
    run_sudo apt update
    fix_broken_deps
    
    print_question "Volver al menu principal? (s/n): "
    read -r back_to_menu
    [[ "$back_to_menu" =~ ^[Ss]$ ]] && show_main_menu
}

# =============================================================================
# LIMPIEZA
# =============================================================================

cleanup() {
    show_banner
    print_header "LIMPIEZA DEL SISTEMA"
    
    echo -e "${GREEN}Selecciona nivel de limpieza:${NC}"
    echo -e "${CYAN}1) Limpieza basica (autoremove, autoclean)${NC}"
    echo -e "${CYAN}2) Limpieza media (+ cache apt)${NC}"
    echo -e "${CYAN}3) Limpieza profunda (+ logs viejos)${NC}"
    echo -e "${CYAN}4) Limpiar paquetes huerfanos${NC}"
    echo -e "${CYAN}5) Eliminar repositorios anadidos${NC}"
    echo -e "${CYAN}6) Volver al menu principal${NC}"
    echo -e "${YELLOW}Nota: Para desinstalar aplicaciones, usa la opcion 6 del menu principal${NC}"
    read -p "$(echo -e ${MAGENTA}"Opcion: "${NC})" cleanup_choice
    
    case $cleanup_choice in
        1)
            run_sudo apt autoremove -y
            run_sudo apt autoclean -y
            print_success "Limpieza basica completada"
            ;;
        2)
            run_sudo apt autoremove -y
            run_sudo apt autoclean -y
            run_sudo apt clean -y
            print_success "Limpieza media completada"
            ;;
        3)
            run_sudo apt autoremove -y
            run_sudo apt autoclean -y
            run_sudo apt clean -y
            run_sudo journalctl --vacuum-time=7d 2>/dev/null
            rm -rf ~/.cache/thumbnails/* 2>/dev/null
            print_success "Limpieza profunda completada"
            ;;
        4)
            orphans=$(run_sudo apt-mark showorphaned 2>/dev/null)
            if [ -n "$orphans" ]; then
                echo -e "${YELLOW}Paquetes huerfanos:${NC}"
                echo "$orphans"
                print_question "¿Eliminar? (s/n): "
                read -r remove_orphans
                if [[ "$remove_orphans" =~ ^[Ss]$ ]]; then
                    run_sudo apt remove --purge -y $orphans 2>/dev/null
                    print_success "Paquetes huerfanos eliminados"
                fi
            else
                print_success "No hay paquetes huerfanos"
            fi
            ;;
        5)
            if [ -f "$ADDED_REPOS_LOG" ]; then
                print_warning "Repositorios anadidos:"
                cat "$ADDED_REPOS_LOG"
                print_question "¿Eliminar todos? (s/n): "
                read -r remove_repos
                if [[ "$remove_repos" =~ ^[Ss]$ ]]; then
                    while read -r repo; do
                        run_sudo rm -f "$repo" 2>/dev/null
                    done < "$ADDED_REPOS_LOG"
                    rm -f "$ADDED_REPOS_LOG"
                    print_success "Repositorios eliminados"
                    run_sudo apt update
                fi
            else
                print_warning "No hay repositorios registrados"
            fi
            ;;
        6) show_main_menu; return 0 ;;
        *) print_error "Opcion invalida" ;;
    esac
    
    print_question "¿Otra operacion? (s/n): "
    read -r continue_cleanup
    [[ "$continue_cleanup" =~ ^[Ss]$ ]] && cleanup || show_main_menu
}

# =============================================================================
# MENU PRINCIPAL
# =============================================================================

show_main_menu() {
    print_header "MENU PRINCIPAL"
    echo -e "${CYAN}1) Configurar Repositorios${NC}"
    echo -e "${CYAN}2) Instalar Drivers y Configuracion Base${NC}"
    echo -e "${CYAN}3) Instalar Aplicaciones${NC}"
    echo -e "${CYAN}4) Configurar Sistema (GRUB, LightDM)${NC}"
    echo -e "${CYAN}5) Limpiar Sistema${NC}"
    echo -e "${CYAN}6) Gestionar Aplicaciones Instaladas${NC}"
    echo -e "${CYAN}7) Salir${NC}"
    echo
    read -p "$(echo -e ${MAGENTA}"Opcion [1-7]: "${NC})" main_choice
    
    case $main_choice in
        1) configure_all_repositories ;;
        2) install_base_system ;;
        3) install_applications_menu ;;
        4) configure_system ;;
        5) cleanup ;;
        6) show_installed_apps_menu ;;
        7) print_success "Hasta luego!"; exit 0 ;;
        *) print_error "Opcion invalida"; sleep 2; show_main_menu ;;
    esac
}

# =============================================================================
# MENU DE APLICACIONES
# =============================================================================

install_applications_menu() {
    show_banner
    print_header "MENU DE APLICACIONES"
    echo -e "${CYAN}1) Navegadores Web${NC}"
    echo -e "${CYAN}2) Clientes de Correo${NC}"
    echo -e "${CYAN}3) Administracion de Imagenes${NC}"
    echo -e "${CYAN}4) Mensajeria${NC}"
    echo -e "${CYAN}5) Reproductores de Audio${NC}"
    echo -e "${CYAN}6) Reproductores y Editores de Video${NC}"
    echo -e "${CYAN}7) Herramientas Multimedia${NC}"
    echo -e "${CYAN}8) Seguridad y Privacidad${NC}"
    echo -e "${CYAN}9) Gestores de Energia${NC}"
    echo -e "${CYAN}10) Gestores de Respaldo${NC}"
    echo -e "${CYAN}11) Aplicaciones de Oficina${NC}"
    echo -e "${CYAN}12) Editores y Desarrollo${NC}"
    echo -e "${CYAN}13) Aplicaciones Terminal${NC}"
    echo -e "${CYAN}14) Herramientas del Sistema${NC}"
    echo -e "${CYAN}15) Fuentes y Tipografias${NC}"
    echo -e "${CYAN}16) Compresion y Archivado${NC}"
    echo -e "${CYAN}17) Construccion y Compilacion${NC}"
    echo -e "${CYAN}18) Lenguajes de Programacion${NC}"
    echo -e "${CYAN}19) Virtualizacion${NC}"
    echo -e "${CYAN}20) Gestores de Descarga${NC}"
    echo -e "${CYAN}21) Volver al Menu Principal${NC}"
    echo
    read -p "$(echo -e ${MAGENTA}"Categoria [1-21]: "${NC})" category_choice
    
    case $category_choice in
        1) install_browsers ;;
        2) install_email_clients ;;
        3) install_image_apps ;;
        4) install_messaging_apps ;;
        5) install_audio_players ;;
        6) install_video_apps ;;
        7) install_multimedia_tools ;;
        8) install_security_apps ;;
        9) install_power_managers ;;
        10) install_backup_tools ;;
        11) install_office_apps ;;
        12) install_dev_tools ;;
        13) install_terminal_apps ;;
        14) install_system_tools ;;
        15) install_fonts ;;
        16) install_archiving_tools ;;
        17) install_build_tools ;;
        18) install_programming_languages ;;
        19) install_virtualization ;;
        20) install_download_managers ;;
        21) show_main_menu ;;
        *) print_error "Opcion invalida"; sleep 2; install_applications_menu ;;
    esac
    
    print_question "Instalar mas aplicaciones? (s/n): "
    read -r continue_install
    [[ "$continue_install" =~ ^[Ss]$ ]] && install_applications_menu || show_main_menu
}

# =============================================================================
# CATEGORIA 1: NAVEGADORES WEB
# =============================================================================
install_browsers() {
    show_banner
    print_header "Navegadores Web"
    echo -e "${GREEN}Selecciona (numeros separados por espacio):${NC}"
    echo -e "${CYAN}1) Firefox${NC}"
    echo -e "${CYAN}2) Librewolf${NC}"
    echo -e "${CYAN}3) Tor Browser${NC}"
    echo -e "${CYAN}4) Mullvad Browser${NC}"
    echo -e "${CYAN}5) Epiphany${NC}"
    echo -e "${GREEN}6) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1)
                if ! package_installed "firefox"; then
                    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | run_sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
                    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | run_sudo tee /etc/apt/sources.list.d/mozilla.list
                    run_sudo apt update && safe_install "firefox"
                fi
                ;;
            2)
                if ! package_installed "librewolf"; then
                    safe_install "extrepo"
                    run_sudo extrepo enable librewolf
                    run_sudo apt update && safe_install "librewolf"
                fi
                ;;
            3)
                if ! package_installed "torbrowser-launcher"; then
                    safe_install "apt-transport-https" && safe_install "gnupg"
                    wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | run_sudo tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null
                    echo "deb [signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org trixie main" | run_sudo tee /etc/apt/sources.list.d/tor.list
                    run_sudo apt update && safe_install "tor" && safe_install "torbrowser-launcher"
                fi
                ;;
            4)
                if ! package_installed "mullvad-browser"; then
                    run_sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc
                    echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc] https://repository.mullvad.net/deb/stable stable main" | run_sudo tee /etc/apt/sources.list.d/mullvad.list
                    run_sudo apt update && safe_install "mullvad-browser"
                fi
                ;;
            5) safe_install "epiphany-browser" ;;
            6) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 2: CLIENTES DE CORREO
# =============================================================================
install_email_clients() {
    show_banner
    print_header "Clientes de Correo"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) Thunderbird${NC}"
    echo -e "${CYAN}2) Claws Mail${NC}"
    echo -e "${CYAN}3) Evolution${NC}"
    echo -e "${CYAN}4) Geary${NC}"
    echo -e "${CYAN}5) Sylpheed${NC}"
    echo -e "${CYAN}6) Balsa${NC}"
    echo -e "${GREEN}7) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "thunderbird" ;;
            2) safe_install "claws-mail" ;;
            3) safe_install "evolution" ;;
            4) safe_install "geary" ;;
            5) safe_install "sylpheed" ;;
            6) safe_install "balsa" ;;
            7) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 3: ADMINISTRACION DE IMAGENES
# =============================================================================
install_image_apps() {
    show_banner
    print_header "Aplicaciones de Imagenes"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) Darktable${NC}"
    echo -e "${CYAN}2) Drawing${NC}"
    echo -e "${CYAN}3) eog${NC}"
    echo -e "${CYAN}4) eom${NC}"
    echo -e "${CYAN}5) Geeqie${NC}"
    echo -e "${CYAN}6) Gimp${NC}"
    echo -e "${CYAN}7) gThumb${NC}"
    echo -e "${CYAN}8) Inkscape${NC}"
    echo -e "${CYAN}9) Krita${NC}"
    echo -e "${CYAN}10) mirage${NC}"
    echo -e "${CYAN}11) Ristretto${NC}"
    echo -e "${CYAN}12) Shotwell${NC}"
    echo -e "${CYAN}13) Viewnior${NC}"
    echo -e "${GREEN}14) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "darktable" ;;
            2) safe_install "drawing" ;;
            3) safe_install "eog" ;;
            4) safe_install "eom" ;;
            5) safe_install "geeqie" ;;
            6) safe_install "gimp" ;;
            7) safe_install "gthumb" ;;
            8) safe_install "inkscape" ;;
            9) safe_install "krita" ;;
            10) safe_install "mirage" ;;
            11) safe_install "ristretto" ;;
            12) safe_install "shotwell" ;;
            13) safe_install "viewnior" ;;
            14) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 4: MENSAJERIA
# =============================================================================
install_messaging_apps() {
    show_banner
    print_header "Aplicaciones de Mensajeria"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) Element${NC}"
    echo -e "${CYAN}2) Gajim${NC}"
    echo -e "${CYAN}3) Jami${NC}"
    echo -e "${CYAN}4) Pidgin + OTR${NC}"
    echo -e "${CYAN}5) Session${NC}"
    echo -e "${CYAN}6) Signal${NC}"
    echo -e "${CYAN}7) Dino-Im${NC}"
    echo -e "${CYAN}8) QTox${NC}"
    echo -e "${GREEN}9) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1)
                if ! package_installed "element-desktop"; then
                    safe_install "wget" && safe_install "apt-transport-https"
                    run_sudo wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
                    echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | run_sudo tee /etc/apt/sources.list.d/element-io.list
                    run_sudo apt update && safe_install "element-desktop"
                fi
                ;;
            2) safe_install "gajim" ;;
            3)
                if ! package_installed "jami"; then
                    safe_install "gnupg" && safe_install "dirmngr" && safe_install "ca-certificates" && safe_install "curl"
                    curl -s https://dl.jami.net/public-key.gpg | run_sudo tee /usr/share/keyrings/jami-archive-keyring.gpg > /dev/null
                    echo "deb [signed-by=/usr/share/keyrings/jami-archive-keyring.gpg] https://dl.jami.net/stable/debian_13/ jami main" | run_sudo tee /etc/apt/sources.list.d/jami.list
                    run_sudo apt update && safe_install "jami"
                fi
                ;;
            4) safe_install "pidgin" && safe_install "pidgin-otr" ;;
            5)
                if ! package_installed "session-desktop"; then
                    run_sudo curl -so /usr/share/keyrings/session-foundation.gpg https://deb.session.foundation/pub.gpg
                    echo "deb [signed-by=/usr/share/keyrings/session-foundation.gpg] https://deb.session.foundation $(lsb_release -sc) main" | run_sudo tee /etc/apt/sources.list.d/session.list
                    run_sudo apt update && safe_install "session-desktop"
                fi
                ;;
            6)
                if ! package_installed "signal-desktop"; then
                    safe_install "extrepo"
                    run_sudo extrepo enable signal
                    run_sudo apt update && safe_install "signal-desktop"
                fi
                ;;
            7) safe_install "dino-im" ;;
            8) safe_install "qtox" ;;
            9) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 5: REPRODUCTORES DE AUDIO
# =============================================================================
install_audio_players() {
    show_banner
    print_header "Reproductores de Audio"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) Audacious${NC}"
    echo -e "${CYAN}2) Clementine${NC}"
    echo -e "${CYAN}3) Exaile${NC}"
    echo -e "${CYAN}4) Lollypop${NC}"
    echo -e "${CYAN}5) Ncmpcpp${NC}"
    echo -e "${CYAN}6) Quod Libet${NC}"
    echo -e "${CYAN}7) Strawberry${NC}"
    echo -e "${CYAN}8) Amberol${NC}"
    echo -e "${GREEN}9) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "audacious" ;;
            2) safe_install "clementine" ;;
            3) safe_install "exaile" ;;
            4) safe_install "lollypop" ;;
            5) safe_install "ncmpcpp" ;;
            6) safe_install "quodlibet" ;;
            7) safe_install "strawberry" ;;
            8) safe_install "amberol" ;;
            9) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 6: REPRODUCTORES Y EDITORES DE VIDEO
# =============================================================================
install_video_apps() {
    show_banner
    print_header "Reproductores y Editores de Video"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) Avidemux${NC}"
    echo -e "${CYAN}2) Blender${NC}"
    echo -e "${CYAN}3) Celluloid${NC}"
    echo -e "${CYAN}4) Gnome Videos${NC}"
    echo -e "${CYAN}5) Handbrake${NC}"
    echo -e "${CYAN}6) MKVToolNix${NC}"
    echo -e "${CYAN}7) MPV${NC}"
    echo -e "${CYAN}8) Parole${NC}"
    echo -e "${CYAN}9) Pitivi${NC}"
    echo -e "${CYAN}10) Shotcut${NC}"
    echo -e "${CYAN}11) VLC${NC}"
    echo -e "${CYAN}12) Kodi${NC}"
    echo -e "${CYAN}13) Jellyfin${NC}"
    echo -e "${CYAN}14) yt-dlp${NC}"
    echo -e "${CYAN}15) ffmpeg${NC}"
    echo -e "${GREEN}16) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "avidemux" ;;
            2) safe_install "blender" ;;
            3) safe_install "celluloid" ;;
            4) safe_install "totem" ;;
            5) safe_install "handbrake-gtk" ;;
            6)
                if ! package_installed "mkvtoolnix-gui"; then
                    run_sudo wget -O /etc/apt/keyrings/gpg-pub-moritzbunkus.gpg https://mkvtoolnix.download/gpg-pub-moritzbunkus.gpg
                    echo "deb [signed-by=/etc/apt/keyrings/gpg-pub-moritzbunkus.gpg] https://mkvtoolnix.download/debian/ trixie main" | run_sudo tee /etc/apt/sources.list.d/mkvtoolnix.list
                    echo "deb-src [signed-by=/etc/apt/keyrings/gpg-pub-moritzbunkus.gpg] https://mkvtoolnix.download/debian/ trixie main" | run_sudo tee -a /etc/apt/sources.list.d/mkvtoolnix.list
                    run_sudo apt update && safe_install "mkvtoolnix" && safe_install "mkvtoolnix-gui"
                fi
                ;;
            7) safe_install "mpv" ;;
            8) safe_install "parole" ;;
            9) safe_install "pitivi" ;;
            10) safe_install "shotcut" ;;
            11) safe_install "vlc" ;;
            12) safe_install "kodi" ;;
            13)
                if ! package_installed "jellyfin"; then
                    safe_install "extrepo"
                    run_sudo extrepo enable jellyfin
                    run_sudo apt update && safe_install "jellyfin"
                fi
                ;;
            14) safe_install "yt-dlp" ;;
            15) safe_install "ffmpeg" ;;
            16) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 7: HERRAMIENTAS MULTIMEDIA
# =============================================================================
install_multimedia_tools() {
    show_banner
    print_header "Herramientas Multimedia"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) Aegisub${NC}"
    echo -e "${CYAN}2) Gaupol${NC}"
    echo -e "${CYAN}3) Subtitle Editor${NC}"
    echo -e "${CYAN}4) Brasero${NC}"
    echo -e "${CYAN}5) ExFalso${NC}"
    echo -e "${CYAN}6) xfburn${NC}"
    echo -e "${CYAN}7) Media-Downloader${NC}"
    echo -e "${CYAN}8) OBS Studio${NC}"
    echo -e "${CYAN}9) SimpleScreenRecorder${NC}"
    echo -e "${GREEN}10) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "aegisub" ;;
            2) safe_install "gaupol" ;;
            3) safe_install "subtitleeditor" ;;
            4) safe_install "brasero" ;;
            5) safe_install "exfalso" ;;
            6) safe_install "xfburn" ;;
            7) safe_install "media-downloader" ;;
            8) safe_install "obs-studio" ;;
            9) safe_install "simplescreenrecorder" ;;
            10) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 8: SEGURIDAD Y PRIVACIDAD (CON CARBURETOR)
# =============================================================================
install_security_apps() {
    show_banner
    print_header "Seguridad y Privacidad"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) OnionShare${NC}"
    echo -e "${CYAN}2) KeePassXC${NC}"
    echo -e "${CYAN}3) GnuPG${NC}"
    echo -e "${CYAN}4) Cryptsetup${NC}"
    echo -e "${CYAN}5) OpenVPN${NC}"
    echo -e "${CYAN}6) Riseup VPN${NC}"
    echo -e "${CYAN}7) BleachBit${NC}"
    echo -e "${CYAN}8) ClamTk${NC}"
    echo -e "${CYAN}9) Gufw Firewall${NC}"
    echo -e "${CYAN}10) Kleopatra${NC}"
    echo -e "${CYAN}11) Metadata Cleaner${NC}"
    echo -e "${CYAN}12) Secrets${NC}"
    echo -e "${CYAN}13) Mat2${NC}"
    echo -e "${CYAN}14) Tomb${NC}"
    echo -e "${CYAN}15) Carburetor (Proxy Tor system-wide)${NC}"
    echo -e "${GREEN}16) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "onionshare" ;;
            2) safe_install "keepassxc" ;;
            3) safe_install "gnupg" ;;
            4) safe_install "cryptsetup" ;;
            5) safe_install "openvpn" ;;
            6) safe_install "riseup-vpn" ;;
            7) safe_install "bleachbit" ;;
            8) safe_install "clamtk" ;;
            9) safe_install "gufw" ;;
            10) safe_install "kleopatra" ;;
            11) safe_install "metadata-cleaner" ;;
            12) safe_install "secrets" ;;
            13) safe_install "mat2" ;;
            14) safe_install "tomb" ;;
            15) safe_install "carburetor" ;;
            16) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 9: GESTORES DE ENERGIA
# =============================================================================
install_power_managers() {
    show_banner
    print_header "Gestores de Energia"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) auto-cpufreq${NC}"
    echo -e "${CYAN}2) TLP${NC}"
    echo -e "${CYAN}3) TLP for ThinkPad${NC}"
    echo -e "${CYAN}4) Powertop${NC}"
    echo -e "${GREEN}5) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1)
                if ! command -v auto-cpufreq &> /dev/null; then
                    safe_install "git" && safe_install "python3-psutil" && safe_install "python3-click" && safe_install "python3-distro" && safe_install "dmidecode"
                    git clone https://github.com/AdnanHodzic/auto-cpufreq.git
                    cd auto-cpufreq && run_sudo ./auto-cpufreq-installer
                    cd .. && rm -rf auto-cpufreq
                    print_success "auto-cpufreq instalado"
                    log_installed_package "auto-cpufreq"
                fi
                ;;
            2) safe_install "tlp" && safe_install "tlp-rdw" && run_sudo systemctl enable tlp ;;
            3) safe_install "tlp" && safe_install "tlp-rdw" ;;
            4) safe_install "powertop" ;;
            5) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 10: GESTORES DE RESPALDO
# =============================================================================
install_backup_tools() {
    show_banner
    print_header "Gestores de Respaldo"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) Back In Time${NC}"
    echo -e "${CYAN}2) BorgBackup${NC}"
    echo -e "${CYAN}3) Deja Dup${NC}"
    echo -e "${CYAN}4) Duplicity${NC}"
    echo -e "${CYAN}5) Restic${NC}"
    echo -e "${CYAN}6) rsnapshot${NC}"
    echo -e "${CYAN}7) Timeshift${NC}"
    echo -e "${CYAN}8) LuckyBackup${NC}"
    echo -e "${GREEN}9) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "backintime-qt" ;;
            2) safe_install "borgbackup" ;;
            3) safe_install "deja-dup" ;;
            4) safe_install "duplicity" ;;
            5) safe_install "restic" ;;
            6) safe_install "rsnapshot" ;;
            7) safe_install "timeshift" ;;
            8) safe_install "luckybackup" ;;
            9) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 11: APLICACIONES DE OFICINA
# =============================================================================
install_office_apps() {
    show_banner
    print_header "Aplicaciones de Oficina"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) AbiWord${NC}"
    echo -e "${CYAN}2) Atril${NC}"
    echo -e "${CYAN}3) Calligra Suite${NC}"
    echo -e "${CYAN}4) Calibre${NC}"
    echo -e "${CYAN}5) Evince${NC}"
    echo -e "${CYAN}6) Gnumeric${NC}"
    echo -e "${CYAN}7) LibreOffice${NC}"
    echo -e "${CYAN}8) Pdfarranger${NC}"
    echo -e "${CYAN}9) Scribus${NC}"
    echo -e "${CYAN}10) Zathura${NC}"
    echo -e "${CYAN}11) Foliate${NC}"
    echo -e "${GREEN}12) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "abiword" ;;
            2) safe_install "atril" ;;
            3) safe_install "calligra" ;;
            4) safe_install "calibre" ;;
            5) safe_install "evince" ;;
            6) safe_install "gnumeric" ;;
            7) safe_install "libreoffice" ;;
            8) safe_install "pdfarranger" ;;
            9) safe_install "scribus" ;;
            10) safe_install "zathura" ;;
            11) safe_install "foliate" ;;
            12) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 12: EDITORES Y DESARROLLO
# =============================================================================
install_dev_tools() {
    show_banner
    print_header "Editores y Desarrollo"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) Bluefish${NC}"
    echo -e "${CYAN}2) VSCodium${NC}"
    echo -e "${CYAN}3) Emacs${NC}"
    echo -e "${CYAN}4) Gedit${NC}"
    echo -e "${CYAN}5) Geany${NC}"
    echo -e "${CYAN}6) Mousepad${NC}"
    echo -e "${CYAN}7) Pluma${NC}"
    echo -e "${CYAN}8) Vim${NC}"
    echo -e "${CYAN}9) Neovim${NC}"
    echo -e "${GREEN}10) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "bluefish" ;;
            2)
                if ! package_installed "codium"; then
                    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | run_sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
                    echo "deb [signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg] https://download.vscodium.com/debs vscodium main" | run_sudo tee /etc/apt/sources.list.d/vscodium.list
                    run_sudo apt update && safe_install "codium"
                fi
                ;;
            3) safe_install "emacs" ;;
            4) safe_install "gedit" ;;
            5) safe_install "geany" ;;
            6) safe_install "mousepad" ;;
            7) safe_install "pluma" ;;
            8) safe_install "vim" ;;
            9) safe_install "neovim" ;;
            10) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 13: APLICACIONES TERMINAL
# =============================================================================
install_terminal_apps() {
    show_banner
    print_header "Aplicaciones Terminal"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) atop${NC}"
    echo -e "${CYAN}2) bmon${NC}"
    echo -e "${CYAN}3) btop${NC}"
    echo -e "${CYAN}4) btm (bottom)${NC}"
    echo -e "${CYAN}5) cmatrix${NC}"
    echo -e "${CYAN}6) duf${NC}"
    echo -e "${CYAN}7) fastfetch${NC}"
    echo -e "${CYAN}8) glances${NC}"
    echo -e "${CYAN}9) htop${NC}"
    echo -e "${CYAN}10) nload${NC}"
    echo -e "${CYAN}11) iftop${NC}"
    echo -e "${CYAN}12) nmon${NC}"
    echo -e "${CYAN}13) pipes-sh${NC}"
    echo -e "${CYAN}14) tcpdump${NC}"
    echo -e "${CYAN}15) tty-clock${NC}"
    echo -e "${CYAN}16) vnstat${NC}"
    echo -e "${GREEN}17) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "atop" ;;
            2) safe_install "bmon" ;;
            3) safe_install "btop" ;;
            4) safe_install "btm" ;;
            5) safe_install "cmatrix" ;;
            6) safe_install "duf" ;;
            7) safe_install "fastfetch" ;;
            8) safe_install "glances" ;;
            9) safe_install "htop" ;;
            10) safe_install "nload" ;;
            11) safe_install "iftop" ;;
            12) safe_install "nmon" ;;
            13) safe_install "pipes-sh" ;;
            14) safe_install "tcpdump" ;;
            15) safe_install "tty-clock" ;;
            16) safe_install "vnstat" ;;
            17) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 14: HERRAMIENTAS DEL SISTEMA
# =============================================================================
install_system_tools() {
    show_banner
    print_header "Herramientas del Sistema"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) BleachBit${NC}"
    echo -e "${CYAN}2) GNOME Disks${NC}"
    echo -e "${CYAN}3) GParted${NC}"
    echo -e "${CYAN}4) Hardinfo${NC}"
    echo -e "${CYAN}5) Synaptic${NC}"
    echo -e "${CYAN}6) Catfish${NC}"
    echo -e "${CYAN}7) KDE Connect${NC}"
    echo -e "${CYAN}8) galculator${NC}"
    echo -e "${CYAN}9) xarchiver${NC}"
    echo -e "${CYAN}10) Baobab${NC}"
    echo -e "${CYAN}11) Qalculate${NC}"
    echo -e "${GREEN}12) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "bleachbit" ;;
            2) safe_install "gnome-disk-utility" ;;
            3) safe_install "gparted" ;;
            4) safe_install "hardinfo" ;;
            5) safe_install "synaptic" ;;
            6) safe_install "catfish" ;;
            7) safe_install "kdeconnect" --no-install-recommends ;;
            8) safe_install "galculator" ;;
            9) safe_install "xarchiver" ;;
            10) safe_install "baobab" ;;
            11) safe_install "qalculate-gtk" ;;
            12) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 15: FUENTES Y TIPOGRAFIAS
# =============================================================================
install_fonts() {
    show_banner
    print_header "Fuentes y Tipografias"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) Fuentes base${NC}"
    echo -e "${CYAN}2) Hack (programacion)${NC}"
    echo -e "${CYAN}3) Fira Code (ligaduras)${NC}"
    echo -e "${CYAN}4) Inter (sans-serif)${NC}"
    echo -e "${CYAN}5) Noto Color Emoji${NC}"
    echo -e "${CYAN}6) Symbola${NC}"
    echo -e "${CYAN}7) JetBrains Mono${NC}"
    echo -e "${CYAN}8) Font Awesome${NC}"
    echo -e "${GREEN}9) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "fonts-recommended" && safe_install "fonts-terminus" ;;
            2) safe_install "fonts-hack-ttf" ;;
            3) safe_install "fonts-firacode" ;;
            4) safe_install "fonts-inter" ;;
            5) safe_install "fonts-noto-color-emoji" ;;
            6) safe_install "fonts-symbola" ;;
            7) safe_install "fonts-jetbrains-mono" ;;
            8) safe_install "fonts-font-awesome" ;;
            9) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 16: COMPRESION Y ARCHIVADO
# =============================================================================
install_archiving_tools() {
    show_banner
    print_header "Herramientas de Compresion"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) bzip2${NC}"
    echo -e "${CYAN}2) gzip${NC}"
    echo -e "${CYAN}3) lzip${NC}"
    echo -e "${CYAN}4) lzma${NC}"
    echo -e "${CYAN}5) p7zip-full${NC}"
    echo -e "${CYAN}6) sharutils${NC}"
    echo -e "${CYAN}7) unace${NC}"
    echo -e "${CYAN}8) tar${NC}"
    echo -e "${CYAN}9) unzip${NC}"
    echo -e "${CYAN}10) xz-utils${NC}"
    echo -e "${CYAN}11) zip${NC}"
    echo -e "${CYAN}12) unrar${NC}"
    echo -e "${CYAN}13) rar${NC}"
    echo -e "${GREEN}14) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "bzip2" ;;
            2) safe_install "gzip" ;;
            3) safe_install "lzip" ;;
            4) safe_install "lzma" ;;
            5) safe_install "p7zip-full" ;;
            6) safe_install "sharutils" ;;
            7) safe_install "unace" ;;
            8) safe_install "tar" ;;
            9) safe_install "unzip" ;;
            10) safe_install "xz-utils" ;;
            11) safe_install "zip" ;;
            12) safe_install "unrar" ;;
            13) safe_install "rar" ;;
            14) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 17: CONSTRUCCION Y COMPILACION
# =============================================================================
install_build_tools() {
    show_banner
    print_header "Herramientas de Construccion"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) build-essential${NC}"
    echo -e "${CYAN}2) make${NC}"
    echo -e "${CYAN}3) automake${NC}"
    echo -e "${CYAN}4) cmake${NC}"
    echo -e "${CYAN}5) autoconf${NC}"
    echo -e "${CYAN}6) git${NC}"
    echo -e "${CYAN}7) curl${NC}"
    echo -e "${CYAN}8) wget${NC}"
    echo -e "${CYAN}9) meson${NC}"
    echo -e "${GREEN}10) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "build-essential" ;;
            2) safe_install "make" ;;
            3) safe_install "automake" ;;
            4) safe_install "cmake" ;;
            5) safe_install "autoconf" ;;
            6) safe_install "git" ;;
            7) safe_install "curl" ;;
            8) safe_install "wget" ;;
            9) safe_install "meson" ;;
            10) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 18: LENGUAJES DE PROGRAMACION
# =============================================================================
install_programming_languages() {
    show_banner
    print_header "Lenguajes de Programacion"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) Java (JDK)${NC}"
    echo -e "${CYAN}2) Java (JRE)${NC}"
    echo -e "${CYAN}3) Python3 completo${NC}"
    echo -e "${CYAN}4) Python3 pip${NC}"
    echo -e "${CYAN}5) Go${NC}"
    echo -e "${CYAN}6) Rust${NC}"
    echo -e "${CYAN}7) Cargo${NC}"
    echo -e "${CYAN}8) Vala${NC}"
    echo -e "${CYAN}9) Clang${NC}"
    echo -e "${CYAN}10) GCC${NC}"
    echo -e "${CYAN}11) NodeJS${NC}"
    echo -e "${CYAN}12) NPM${NC}"
    echo -e "${CYAN}13) Ruby${NC}"
    echo -e "${CYAN}14) PHP${NC}"
    echo -e "${CYAN}15) Lua${NC}"
    echo -e "${CYAN}16) Haskell (GHC)${NC}"
    echo -e "${CYAN}17) OCaml${NC}"
    echo -e "${CYAN}18) R (estadisticas)${NC}"
    echo -e "${GREEN}19) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "default-jdk" ;;
            2) safe_install "default-jre" ;;
            3) safe_install "python3-full" ;;
            4) safe_install "python3-pip" ;;
            5) safe_install "golang" ;;
            6) safe_install "rustc" ;;
            7) safe_install "cargo" ;;
            8) safe_install "valac" ;;
            9) safe_install "clang" ;;
            10) safe_install "gcc" ;;
            11) safe_install "nodejs" ;;
            12) safe_install "npm" ;;
            13) safe_install "ruby-full" ;;
            14) safe_install "php-cli" && safe_install "php-dev" ;;
            15) safe_install "lua5.4" ;;
            16) safe_install "ghc" ;;
            17) safe_install "ocaml" ;;
            18) safe_install "r-base" ;;
            19) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 19: VIRTUALIZACION
# =============================================================================
install_virtualization() {
    show_banner
    print_header "Virtualizacion"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) virt-manager${NC}"
    echo -e "${CYAN}2) gnome-boxes${NC}"
    echo -e "${CYAN}3) qemu-kvm${NC}"
    echo -e "${CYAN}4) libvirt-daemon-system${NC}"
    echo -e "${CYAN}5) libvirt-clients${NC}"
    echo -e "${CYAN}6) swtpm${NC}"
    echo -e "${GREEN}7) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "virt-manager" ;;
            2) safe_install "gnome-boxes" ;;
            3) safe_install "qemu-kvm" ;;
            4) safe_install "libvirt-daemon-system" ;;
            5) safe_install "libvirt-clients" ;;
            6) safe_install "swtpm" ;;
            7) return 0 ;;
        esac
    done
    
    if package_installed "libvirt-daemon-system"; then
        run_sudo systemctl enable libvirtd
        run_sudo systemctl start libvirtd
        print_success "libvirt habilitado"
    fi
    
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# CATEGORIA 20: GESTORES DE DESCARGA
# =============================================================================
install_download_managers() {
    show_banner
    print_header "GESTORES DE DESCARGA"
    echo -e "${GREEN}Selecciona:${NC}"
    echo -e "${CYAN}1) Transmission (GTK)${NC}"
    echo -e "${CYAN}2) qBittorrent${NC}"
    echo -e "${CYAN}3) Deluge (GTK)${NC}"
    echo -e "${CYAN}4) Fragments (GTK)${NC}"
    echo -e "${CYAN}5) uGet (GTK)${NC}"
    echo -e "${CYAN}6) Persepolis${NC}"
    echo -e "${CYAN}7) Xtreme Download Manager${NC}"
    echo -e "${CYAN}8) Motrix${NC}"
    echo -e "${CYAN}9) KGet${NC}"
    echo -e "${CYAN}10) aria2 (terminal)${NC}"
    echo -e "${CYAN}11) Instalar TODOS${NC}"
    echo -e "${GREEN}12) Volver${NC}"
    read -p "$(echo -e ${MAGENTA}"Seleccion: "${NC})" -a selected_indices
    
    for idx in "${selected_indices[@]}"; do
        case $idx in
            1) safe_install "transmission-gtk" ;;
            2) safe_install "qbittorrent" ;;
            3) safe_install "deluge-gtk" ;;
            4) safe_install "fragments" ;;
            5) safe_install "uget" ;;
            6)
                if ! package_installed "persepolis"; then
                    run_sudo add-apt-repository -y ppa:persepolis/ppa 2>/dev/null
                    run_sudo apt update
                    safe_install "persepolis"
                fi
                ;;
            7)
                if ! package_installed "xdman"; then
                    wget -q https://github.com/subhra74/xdm/releases/download/2024/xdman_2024_amd64.deb -O /tmp/xdman.deb
                    run_sudo dpkg -i /tmp/xdman.deb 2>/dev/null || run_sudo apt install -f -y
                    rm -f /tmp/xdman.deb
                    log_installed_package "xdman"
                fi
                ;;
            8)
                if ! package_installed "motrix"; then
                    curl -s https://api.github.com/repos/agalwood/Motrix/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4 | wget -qi -
                    run_sudo dpkg -i Motrix_*.deb 2>/dev/null || run_sudo apt install -f -y
                    rm -f Motrix_*.deb
                    log_installed_package "motrix"
                fi
                ;;
            9) safe_install "kget" ;;
            10) safe_install "aria2" ;;
            11)
                safe_install "transmission-gtk" "qbittorrent" "deluge-gtk" "fragments"
                safe_install "uget" "kget" "aria2"
                if ! package_installed "persepolis"; then
                    run_sudo add-apt-repository -y ppa:persepolis/ppa 2>/dev/null
                    run_sudo apt update
                    safe_install "persepolis"
                fi
                if ! package_installed "motrix"; then
                    curl -s https://api.github.com/repos/agalwood/Motrix/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4 | wget -qi -
                    run_sudo dpkg -i Motrix_*.deb 2>/dev/null || run_sudo apt install -f -y
                    rm -f Motrix_*.deb
                fi
                if ! package_installed "xdman"; then
                    wget -q https://github.com/subhra74/xdm/releases/download/2024/xdman_2024_amd64.deb -O /tmp/xdman.deb
                    run_sudo dpkg -i /tmp/xdman.deb 2>/dev/null || run_sudo apt install -f -y
                    rm -f /tmp/xdman.deb
                fi
                print_success "Todos los gestores instalados"
                ;;
            12) return 0 ;;
        esac
    done
    read -p "Presiona Enter..."
    install_applications_menu
}

# =============================================================================
# FUNCION PRINCIPAL
# =============================================================================

main() {
    show_banner
    check_root
    
    if ! grep -qi "debian" /etc/os-release; then
        print_error "Este script es solo para Debian"
        exit 1
    fi
    
    touch "$LOG_FILE" "$INSTALLED_PACKAGES_LOG" "$ADDED_REPOS_LOG" 2>/dev/null
    print_success "Log: $LOG_FILE"
    
    check_internet
    check_disk_space
    backup_configs
    
    print_question "Actualizar sistema antes de comenzar? (s/n): "
    read -r update_first
    if [[ "$update_first" =~ ^[Ss]$ ]]; then
        run_sudo apt update && run_sudo apt upgrade -y
    fi
    
    fix_broken_deps
    show_main_menu
}

main "$@"
