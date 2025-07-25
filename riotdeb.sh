#!/bin/bash

sudo clear

# apt install xfce4-terminal sudo nala git wget 
apt install sudo nala git wget 
sudo apt install -y acpi acpitool acpi-support rename blueman fancontrol firmware-linux-free fwupd hardinfo hwdata hwinfo irqbalance iucode-tool laptop-detect numlockx gvfs-backends gvfs-fuse lm-sensors lshw lsscsi smartmontools galternatives software-properties-gtk gnome-firmware util-linux

sudo apt install -y firmware-linux firmware-misc-nonfree

sudo apt install -y dconf-editor curl 

sudo apt install -y xorg xserver-xorg ffmpegthumbnailer gstreamer1.0-gl gstreamer1.0-nice gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-pulseaudio gstreamer1.0-x

sudo apt install -y libdvdnav4 libdvdread8 libfaac0 libmad0 libmp3lame0 libxvidcore4 vorbis-tools flac

sudo apt install -y gcc g++ gfortran clang rustc valac fpc gnat ocaml-nox crystal linux-headers-$(uname -r) build-essential make cmake meson libgcr-3-dev ninja-build cargo autoconf automake libtool scons gradle default-jdk default-jre

sudo apt install -y papirus-icon-theme arc-theme dmz-cursor-theme adwaita-qt materia-gtk-theme

sudo apt install -y arj bzip2 gzip lhasa liblhasa0 lzip lzma p7zip p7zip-full p7zip-rar sharutils rar unace unrar unrar-free tar unzip xz-utils zip

sudo apt install -y bluez bluetooth bluez-cups bluez-firmware bluez-tools btscanner pulseaudio-module-bluetooth

sudo apt install -y fonts-recommended fonts-ubuntu fonts-font-awesome fonts-terminus fonts-inter

# Define the URL of the Nerd Fonts repository
NERD_FONTS_REPO="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/"

# Specify the font you want to install (changing to "Hack")
FONT_NAME="Hack"
FONT_ZIP="${FONT_NAME}.zip"

# Create a temporary directory
TEMP_DIR=$(mktemp -d)

# Download the font
echo "Downloading the Nerd Font: $FONT_NAME..."
wget -q -O "$TEMP_DIR/$FONT_ZIP" "${NERD_FONTS_REPO}${FONT_ZIP}"

# Unzip the file
echo "Unzipping the font..."
unzip -q "$TEMP_DIR/$FONT_ZIP" -d "$TEMP_DIR"

# Check if .ttf files exist
if ls "$TEMP_DIR"/*.ttf 1> /dev/null 2>&1; then
    # Create the fonts directory if it doesn't exist
    FONT_DIR="/usr/share/fonts/truetype/nerd-fonts"
    sudo mkdir -p "$FONT_DIR"

    # Copy the fonts to the fonts folder
    echo "Installing the fonts..."
    sudo cp "$TEMP_DIR"/*.ttf "$FONT_DIR"

    # Update the font cache
    echo "Updating the font cache..."
    sudo fc-cache -f -v

    echo "The Nerd Font $FONT_NAME has been installed successfully."
else
    echo "No .ttf files found in the downloaded font package."
fi

# Clean up the temporary directory
rm -rf "$TEMP_DIR"

sudo clear

# Function for managing repositories
manage_repositories() {
    # ANSI color codes
    YELLOW='\033[1;33m'
    RED='\033[1;31m'
    NC='\033[0m' # No Color

    # Detect Debian version
    VERSION=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
    [[ -z "$VERSION" ]] && VERSION=$(lsb_release -sc)

    BACKUP="/etc/apt/sources.list.bak.$(date +%F-%H%M%S)"

    echo -e "${YELLOW}Detected Debian version: $VERSION${NC}"
    echo -e "${YELLOW}Backing up /etc/apt/sources.list to $BACKUP...${NC}"
    sudo cp /etc/apt/sources.list "$BACKUP"

    # Display main repository options
    echo -e "${YELLOW}Select main repository type for Debian $VERSION:${NC}"
    echo "1) Free (only main)"
    echo "2) Semi-free (main contrib)"
    echo "3) With proprietary software (main contrib non-free)"
    echo "4) With proprietary firmware (main contrib non-free non-free-firmware)"
    read -rp "Select repository type [1-4]: " main_repo_option

    case $main_repo_option in
        1) COMPONENTS="main" ;;
        2) COMPONENTS="main contrib" ;;
        3) COMPONENTS="main contrib non-free" ;;
        4) COMPONENTS="main contrib non-free non-free-firmware" ;;
        *) echo -e "${RED}Invalid option. Exiting.${NC}"; return ;;
    esac

    # Create new well-organized sources.list
    echo "# DEBIAN REPOSITORIES - GENERATED $(date)" | sudo tee /etc/apt/sources.list >/dev/null
    echo "" | sudo tee -a /etc/apt/sources.list

    # Main repository section
    echo "#############################################################" | sudo tee -a /etc/apt/sources.list
    echo "###                       MAIN                            ###" | sudo tee -a /etc/apt/sources.list
    echo "#############################################################" | sudo tee -a /etc/apt/sources.list
    echo "deb http://deb.debian.org/debian/ $VERSION $COMPONENTS" | sudo tee -a /etc/apt/sources.list
    echo "deb-src http://deb.debian.org/debian/ $VERSION $COMPONENTS" | sudo tee -a /etc/apt/sources.list
    echo "" | sudo tee -a /etc/apt/sources.list

    # Security updates section
    echo "#############################################################" | sudo tee -a /etc/apt/sources.list
    echo "###                     SECURITY                          ###" | sudo tee -a /etc/apt/sources.list
    echo "#############################################################" | sudo tee -a /etc/apt/sources.list
    echo "deb http://security.debian.org/debian-security $VERSION-security $COMPONENTS" | sudo tee -a /etc/apt/sources.list
    echo "deb-src http://security.debian.org/debian-security $VERSION-security $COMPONENTS" | sudo tee -a /etc/apt/sources.list
    echo "" | sudo tee -a /etc/apt/sources.list

    # Updates section
    echo "#############################################################" | sudo tee -a /etc/apt/sources.list
    echo "###                     UPDATES                           ###" | sudo tee -a /etc/apt/sources.list
    echo "#############################################################" | sudo tee -a /etc/apt/sources.list
    echo "deb http://deb.debian.org/debian/ $VERSION-updates $COMPONENTS" | sudo tee -a /etc/apt/sources.list
    echo "deb-src http://deb.debian.org/debian/ $VERSION-updates $COMPONENTS" | sudo tee -a /etc/apt/sources.list
    echo "" | sudo tee -a /etc/apt/sources.list

    while true; do
        echo -e "${YELLOW}Select an option:${NC}"
        echo "1) Add Backports repository"
        echo "2) Add Multimedia repository"
        echo "3) Add Backports and Multimedia repositories"
        echo "4) Return to main menu"
        read -rp "Option [1-4]: " repo_option

        case $repo_option in
            1|3) # Add Backports repository (option 1 or 3)
                if [[ "$main_repo_option" == "1" ]]; then
                    echo -e "${RED}Warning: Backports requires all components (main, contrib, non-free, non-free-firmware)${NC}"
                    echo -e "${YELLOW}Do you want to change your main repository to include all components? [y/N]${NC}"
                    read -rp "Choice: " change_choice
                    if [[ "$change_choice" =~ [yY] ]]; then
                        COMPONENTS="main contrib non-free non-free-firmware"
                        # Recreate sources.list with new components
                        echo "# DEBIAN REPOSITORIES - UPDATED $(date)" | sudo tee /etc/apt/sources.list >/dev/null
                        echo "" | sudo tee -a /etc/apt/sources.list

                        # Main repository section
                        echo "#############################################################" | sudo tee -a /etc/apt/sources.list
                        echo "###                       MAIN                            ###" | sudo tee -a /etc/apt/sources.list
                        echo "#############################################################" | sudo tee -a /etc/apt/sources.list
                        echo "deb http://deb.debian.org/debian/ $VERSION $COMPONENTS" | sudo tee -a /etc/apt/sources.list
                        echo "deb-src http://deb.debian.org/debian/ $VERSION $COMPONENTS" | sudo tee -a /etc/apt/sources.list
                        echo "" | sudo tee -a /etc/apt/sources.list

                        # Security updates section
                        echo "#############################################################" | sudo tee -a /etc/apt/sources.list
                        echo "###                     SECURITY                          ###" | sudo tee -a /etc/apt/sources.list
                        echo "#############################################################" | sudo tee -a /etc/apt/sources.list
                        echo "deb http://security.debian.org/debian-security $VERSION-security $COMPONENTS" | sudo tee -a /etc/apt/sources.list
                        echo "deb-src http://security.debian.org/debian-security $VERSION-security $COMPONENTS" | sudo tee -a /etc/apt/sources.list
                        echo "" | sudo tee -a /etc/apt/sources.list

                        # Updates section
                        echo "#############################################################" | sudo tee -a /etc/apt/sources.list
                        echo "###                     UPDATES                           ###" | sudo tee -a /etc/apt/sources.list
                        echo "#############################################################" | sudo tee -a /etc/apt/sources.list
                        echo "deb http://deb.debian.org/debian/ $VERSION-updates $COMPONENTS" | sudo tee -a /etc/apt/sources.list
                        echo "deb-src http://deb.debian.org/debian/ $VERSION-updates $COMPONENTS" | sudo tee -a /etc/apt/sources.list
                        echo "" | sudo tee -a /etc/apt/sources.list
                    else
                        echo -e "${RED}Skipping Backports due to incomplete components${NC}"
                        continue
                    fi
                fi
                
                echo "Adding Backports repository..."
                echo "" | sudo tee -a /etc/apt/sources.list
                echo "#############################################################" | sudo tee -a /etc/apt/sources.list
                echo "###                    BACKPORTS                          ###" | sudo tee -a /etc/apt/sources.list
                echo "#############################################################" | sudo tee -a /etc/apt/sources.list
                echo "deb http://deb.debian.org/debian/ $VERSION-backports $COMPONENTS" | sudo tee -a /etc/apt/sources.list
                echo "deb-src http://deb.debian.org/debian/ $VERSION-backports $COMPONENTS" | sudo tee -a /etc/apt/sources.list
                echo "" | sudo tee -a /etc/apt/sources.list
                echo "Backports repository added."
                ;;
            2|3) # Add Multimedia repository (option 2 or 3)
                if [[ "$repo_option" == "3" ]]; then
                    echo "Also adding Multimedia repository..."
                else
                    echo "Adding Multimedia repository..."
                fi

                # Create the sources file for the multimedia repository
                echo "#############################################################" | sudo tee -a /etc/apt/sources.list
                echo "###                   MULTIMEDIA                           ###" | sudo tee -a /etc/apt/sources.list
                echo "#############################################################" | sudo tee -a /etc/apt/sources.list
                echo "deb [signed-by=/usr/share/keyrings/deb-multimedia-keyring.gpg
                echo "deb [signed-by=/usr/share/keyrings/deb-multimedia-keyring.gpg] https://www.deb-multimedia.org $VERSION main non-free" | sudo tee -a /etc/apt/sources.list
                echo "" | sudo tee -a /etc/apt/sources.list

                # Download and install the repository key
                echo "Downloading and installing deb-multimedia-keyring key..."
                wget https://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2024.9.1_all.deb
                sha256sum_expected="8dc6cbb266c701cfe58bd1d2eb9fe2245a1d6341c7110cfbfe3a5a975dcf97ca"
                sha256sum_file=$(sha256sum deb-multimedia-keyring_2024.9.1_all.deb | awk '{print $1}')
                
                if [[ "$sha256sum_file" == "$sha256sum_expected" ]]; then
                    echo "✔ SHA256 verification successful."
                    sudo dpkg -i deb-multimedia-keyring_2024.9.1_all.deb
                else
                    echo -e "${RED}Error: SHA256 verification of the package failed. Aborting.${NC}"
                    exit 1
                fi

                sudo rm deb-multimedia-keyring_2024.9.1_all.deb

                # Final update to ensure everything is set up correctly
                echo "Updating package list to include the new repository..."
                sudo apt update
                sudo apt upgrade -y

                echo "Multimedia repository added and key installed."
                ;;
            4) # Return to main menu
                echo "Returning to the main menu."
                break
                ;;
            *) # Invalid option
                echo -e "${RED}Invalid option. Please enter a number between 1 and 4.${NC}"
                ;;
        esac

        if [[ "$repo_option" =~ ^[1-3]$ ]]; then
            sudo apt update
            sudo apt upgrade -y
            clear
        fi
    done
    sudo clear
}


# Function for installing minimal desktop environments and applications
install_minimal_desktop_envs() {
    # ANSI color codes
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color

    while true; do
        echo -e "${YELLOW}Select an option:${NC}"
        echo "1) Install minimal Gnome environment"
        echo "2) Install minimal Budgie environment"
        echo "3) Install minimal XFCE environment"
        echo "4) Exit"
        read -rp "Option [1-4]: " main_option

        if [[ "$main_option" =~ ^[1-4]$ ]]; then
            case $main_option in
                1) # GNOME
                    echo "Installing minimal Gnome environment..."
                    nala install -y gnome-core gedit eog tilix nautilus mpv synaptic || { echo "Error installing GNOME environment"; exit 1; }
                    gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark'
                    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
                    gsettings set org.gnome.shell.extensions.user-theme name 'Arc-Dark'
                    echo "Installing LibreWolf..."
                    sudo apt update && sudo apt install extrepo -y
                    sudo extrepo enable librewolf
                    sudo apt update && sudo apt install librewolf -y || { echo "Error installing LibreWolf"; exit 1; }
                    echo "GNOME installation completed."
                    ;;
                2) # Budgie
                    echo "Installing minimal Budgie environment..."
                    nala install -y budgie-desktop budgie* tilix slick-greeter mousepad eog mpv thunar thunar-archive-plugin thunar-volman synaptic || { echo "Error installing Budgie environment"; exit 1; }
                    gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark'
                    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
                    echo "Installing LibreWolf..."
                    sudo apt update && sudo apt install extrepo -y
                    sudo extrepo enable librewolf
                    sudo apt update && sudo apt install librewolf -y || { echo "Error installing LibreWolf"; exit 1; }

                    # Ruta al archivo lightdm.conf
                    LIGHTDM_CONF="/etc/lightdm/lightdm.conf"

                    # Verifica si Budgie está instalado
                    if ! dpkg -l | grep -q budgie-desktop; then
                        echo "Budgie no está instalado. Instalando Budgie..."
                        sudo apt update
                        sudo apt install -y budgie-desktop
                    fi

                    # Verifica si el archivo lightdm.conf existe
                    if [ -f "$LIGHTDM_CONF" ]; then
                        # Verifica si la línea ya está configurada
                        if grep -q "^user-session=budgie-desktop" "$LIGHTDM_CONF"; then
                            echo "La sesión ya está configurada como budgie-desktop."
                        else
                            # Usa sed para descomentar y cambiar la línea
                            sudo sed -i 's/^#user-session=.*/user-session=budgie-desktop/' "$LIGHTDM_CONF"
                            
                            # Verifica si el comando sed tuvo éxito
                            if [ $? -eq 0 ]; then
                                echo "La línea ha sido modificada correctamente."
                            else
                                echo "Error al modificar la línea en $LIGHTDM_CONF."
                                exit 1
                            fi
                        fi

                        # Reinicia LightDM para aplicar los cambios
                        echo "Reiniciando LightDM..."
                        sudo systemctl restart lightdm

                        if [ $? -eq 0 ]; then
                            echo "LightDM reiniciado correctamente."
                        else
                            echo "Error al reiniciar LightDM."
                            exit 1
                        fi
                    else
                        echo "El archivo $LIGHTDM_CONF no existe."
                        exit 1
                    fi
                    echo "Budgie installation completed."
                    ;;
                3) # XFCE
                    echo "Installing minimal XFCE environment..."
                    nala install -y xfce4 tilix slick-greeter mousepad ristretto mpv thunar thunar-archive-plugin thunar-volman synaptic || { echo "Error installing XFCE environment"; exit 1; }
                    xfconf-query -c xsettings -p /Net/ThemeName -s "Arc-Dark"
                    xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"
                    xfconf-query -c xfwm4 -p /general/theme -s "Arc-Dark"
                    echo "Installing LibreWolf..."
                    sudo apt update && sudo apt install extrepo -y
                    sudo extrepo enable librewolf
                    sudo apt update && sudo apt install librewolf -y || { echo "Error installing LibreWolf"; exit 1; }
                    echo "XFCE installation completed."
                    ;;
                4) # Exit
                    echo "Exiting the installation menu."
                    sudo clear
                    return
                    ;;
                *) # Invalid option
                    echo "Invalid option: $main_option"
                    ;;
            esac
        else
            echo "Invalid option. Please enter a number between 1 and 4."
        fi
    done
}


# Enable error handling
set -e

# Log file
LOGFILE="/var/log/firmware_update.log"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to update the system and handle package issues
update_system() {
    log "Updating the package list..."
    if ! sudo nala update; then
        log "Failed to update package list. Attempting to fix broken packages..."
        sudo nala install -f || log "Failed to fix broken packages."
    fi

    log "Upgrading installed packages..."
    if ! sudo nala upgrade; then
        log "Failed to upgrade packages. Attempting to fix broken packages..."
        sudo nala install -f || log "Failed to fix broken packages."
    fi

    log "Cleaning up unused packages..."
    sudo nala autoremove -y || true  # Ignore errors and continue
}

# Function to update and manage firmware
update_firmware() {
    log "Starting firmware update process..."

    # Update the system first
    update_system

    # Install fwupd if it's not already installed
    if ! command_exists fwupdmgr; then
        log "fwupd is not installed. Installing fwupd..."
        sudo nala install fwupd -y
    fi

    # Refresh the fwupd database
    log "Refreshing the fwupd database..."
    sudo fwupdmgr refresh || true  # Ignore errors and continue

    # List available firmware updates
    log "Checking for available firmware updates..."
    available_firmware=$(sudo fwupdmgr get-updates || true)  # Ignore errors and continue

    if [[ -z "$available_firmware" ]]; then
        log "No available firmware updates found."
    else
        log "Available firmware updates:"
        echo "$available_firmware"

        # Install firmware updates without prompting
        log "Installing firmware updates..."
        sudo fwupdmgr update || log "Failed to install firmware updates."
    fi

    # Install common additional firmware
    log "Installing common additional firmware..."
    sudo nala install firmware-linux firmware-linux-nonfree -y || log "Failed to install additional firmware."
    sudo clear
    
    # Clean the package cache
    log "Cleaning the package cache..."
    sudo nala clean || true  # Ignore errors and continue
    sudo clear
    
    log "Firmware search and installation process completed."
    sudo clear
}

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo "  -l, --log         Specify a log file (default: /var/log/firmware_update.log)"
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        -l|--log) LOGFILE="$2"; shift ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

# Ensure the terminal is cleared before exiting
sudo clear

# Function to check if an application is installed
is_installed() {
    dpkg -l | grep -q "$1"
}

# Function to display the application status
get_app_status() {
    if is_installed "$1"; then
        echo "✅"  # For installed
    else
        echo "❌"  # For not installed
    fi
}

# Function to detect the CPU
detect_cpu() {
    echo "Detecting CPU..."
    if CPU_INFO=$(cat /proc/cpuinfo | grep "model name" | uniq); then
        echo "Detected CPU: $CPU_INFO"
    else
        echo "Failed to detect CPU."
        exit 1
    fi
}

# Function to detect the GPU
detect_gpu() {
    echo "Detecting GPU..."
    if command -v lspci &> /dev/null; then
        GPU_INFO=$(lspci | grep -E "VGA|3D")
        echo "Detected GPU: $GPU_INFO"
    else
        echo "lspci is not installed. Please install it to detect the GPU."
        exit 1
    fi
}

# Function to manage installations and uninstalls
manage_installations() {
    detect_cpu
    detect_gpu

    while true; do
        echo "Your CPU is: $CPU_INFO"
        echo "Your GPU is: $GPU_INFO"
        echo "Recommended installations based on your hardware:"

        if echo "$GPU_INFO" | grep -i "nvidia" &> /dev/null; then
            echo "1. Install NVIDIA drivers $(get_app_status nvidia-driver)"
            echo "2. Install open-source NVIDIA driver (nouveau) $(get_app_status xserver-xorg-video-nouveau)"
            echo "3. Install NVIDIA monitoring tools (nvidia-smi) $(get_app_status nvidia-smi)"
        elif echo "$GPU_INFO" | grep -i "amd" &> /dev/null; then
            echo "1. Install AMD drivers (firmware-amd-graphics) $(get_app_status firmware-amd-graphics)"
            echo "2. Install CoreCtrl (for monitoring and control) $(get_app_status corectrl)"
            echo "3. Install Radeontop (for monitoring) $(get_app_status radeontop)"
        else
            echo "No supported GPU detected."
            exit 1
        fi

        echo "4. Exit"

        read -p "Select an option (1-4): " option

        case $option in
            1)
                if echo "$GPU_INFO" | grep -i "nvidia" &> /dev/null; then
                    read -p "Do you want to install the proprietary NVIDIA driver (1) or the open-source driver (2)? " driver_option
                    if [[ "$driver_option" == "1" ]]; then
                        echo "Installing NVIDIA drivers..."
                        if sudo nala install -y nvidia-driver; then
                            echo "NVIDIA drivers installed successfully."
                        else
                            echo "Failed to install NVIDIA drivers."
                        fi
                    elif [[ "$driver_option" == "2" ]]; then
                        echo "Installing open-source NVIDIA driver..."
                        if sudo nala install -y xserver-xorg-video-nouveau; then
                            echo "Open-source NVIDIA driver installed successfully."
                        else
                            echo "Failed to install open-source NVIDIA driver."
                        fi
                    else
                        echo "Invalid option. Please select 1 or 2."
                    fi
                elif echo "$GPU_INFO" | grep -i "amd" &> /dev/null; then
                    echo "Installing AMD drivers..."
                    if sudo nala install -y firmware-amd-graphics; then
                        echo "AMD drivers installed successfully."
                    else
                        echo "Failed to install AMD drivers."
                    fi
                fi
                ;;
            2)
                if echo "$GPU_INFO" | grep -i "amd" &> /dev/null; then
                    echo "Installing CoreCtrl..."
                    if sudo nala install -y corectrl; then
                        echo "CoreCtrl installed successfully."
                    else
                        echo "Failed to install CoreCtrl."
                    fi
                fi
                ;;
            3)
                if echo "$GPU_INFO" | grep -i "amd" &> /dev/null; then
                    echo "Installing Radeontop..."
                    if sudo nala install -y radeontop; then
                        echo "Radeontop installed successfully."
                    else
                        echo "Failed to install Radeontop."
                    fi
                elif echo "$GPU_INFO" | grep -i "nvidia" &> /dev/null; then
                    echo "Installing NVIDIA monitoring tools..."
                    if sudo nala install -y nvidia-smi; then
                        echo "NVIDIA monitoring tools installed successfully."
                    else
                        echo "Failed to install NVIDIA monitoring tools."
                    fi
                fi
                ;;

            4)
               sudo clear
               return
               ;; 
            *)
                echo "Invalid option. Please try again."
                ;;
        esac

        echo "Installation/Uninstallation complete. Returning to the main menu..."
        echo ""
    done
}

# Function to install browsers
install_browsers() {
    # ANSI color codes
    YELLOW='\033[38;5;178m'
    GREEN='\033[0;32m'
    CYAN='\033[0;36m'
    BLUE='\033[0;34m'
    RED='\033[0;31m'
    NC='\033[0m' # No Color

    # Function to display language packages in responsive columns
    select_language_package() {
        local browser_name=$1
        echo -e "\n${YELLOW}=== Available Language Packs for $browser_name ===${NC}"
        
        # Calculate number of columns based on terminal width
        local term_width=$(tput cols)
        local min_col_width=30
        local max_columns=$((term_width / min_col_width))
        local columns=$((max_columns < 3 ? max_columns : 3))
        
        # Display header
        echo -e "${GREEN}ID  | Language${NC}"
        echo -e "${GREEN}----|--------${NC}"
        
        # Create array with packages
        local packages_array=()
        while IFS= read -r package; do
            packages_array+=("$package")
        done <<< "$language_packages"
        
        local total_packages=${#packages_array[@]}
        local rows=$(( (total_packages + columns - 1) / columns ))
        
        # Display in columns
        for ((row=0; row<rows; row++)); do
            for ((col=0; col<columns; col++)); do
                local index=$((row + col * rows))
                if ((index < total_packages)); then
                    local package=${packages_array[index]}
                    local lang_code=$(echo "$package" | cut -d'-' -f3-)
                    local lang_name=$(grep -i "Language:.*${lang_code}" /usr/share/i18n/SUPPORTED 2>/dev/null | head -1 | cut -d' ' -f2-)
                    [ -z "$lang_name" ] && lang_name="$lang_code"
                    
                    printf "${YELLOW}%2d)${NC} %-25s" "$((index+1))" "$lang_name"
                fi
            done
            echo ""
        done
        
        echo -e "\n${CYAN}0) None (don't install language pack)${NC}"
        echo -e "${CYAN}q) Quit${NC}"
        
        # User selection
        while true; do
            read -p "Select language ID [0-$total_packages] or 'q' to quit: " lang_option
            
            case "$lang_option" in
                0)
                    echo -e "${BLUE}No language pack will be installed.${NC}"
                    return 1
                    ;;
                [Qq])
                    echo -e "${BLUE}Quitting...${NC}"
                    return 1
                    ;;
                *)
                    if [[ "$lang_option" =~ ^[0-9]+$ ]] && [ "$lang_option" -ge 1 ] && [ "$lang_option" -le "$total_packages" ]; then
                        selected_package=${packages_array[$((lang_option-1))]}
                        echo -e "\n${GREEN}Selected language:${NC} ${YELLOW}$(echo "$selected_package" | cut -d'-' -f3-)${NC}"
                        return 0
                    else
                        echo -e "${RED}Invalid option. Please try again.${NC}"
                    fi
                    ;;
            esac
        done
    }

    while true; do
        echo -e "\nSelect an option:"
        echo "1) Install browsers"
        echo "2) Uninstall browsers"
        echo "3) Exit"
        read -p "Option [1-3]: " main_option

        if [[ "$main_option" =~ ^[1-3]$ ]]; then
            if [ "$main_option" -eq 1 ]; then
                # Installation menu
                echo -e "\nSelect browsers to install (enter numbers separated by spaces):"
                echo -e "1) Epiphany ${YELLOW}- Simple web browser for GNOME.${NC} $(get_app_status epiphany-browser)"
                echo -e "2) Firefox ${YELLOW}- Popular open-source web browser.${NC} $(get_app_status firefox)"
                echo -e "3) Firefox ESR ${YELLOW}- Extended Support Release of Firefox.${NC} $(get_app_status firefox-esr)"
                echo -e "4) Icecat ${YELLOW}- GNU version of Firefox focused on privacy.${NC} $(get_app_status icecat)"
                echo -e "5) LibreWolf (RECOMMENDED) ${YELLOW}- Privacy-focused Firefox fork.${NC} $(get_app_status librewolf)"
                echo -e "6) Mullvad ${YELLOW}- Privacy-focused browser from Mullvad VPN.${NC} $(get_app_status mullvad-browser)"
                echo -e "7) Tor Browser ${YELLOW}- Browser for anonymous web browsing.${NC} $(get_app_status torbrowser-launcher)"
                echo "8) None"
                read -p "Option [1-8]: " -a options

                for option in "${options[@]}"; do
                    case $option in
                        1) # Epiphany
                            echo -e "\n${GREEN}Installing Epiphany...${NC}"
                            nala update && nala install -y epiphany-browser || {
                                echo -e "${RED}Error installing Epiphany${NC}"
                                exit 1
                            }
                            ;;
                        2) # Firefox
                            echo -e "\n${GREEN}Installing Firefox...${NC}"
                            wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
                            echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
                            nala update && nala install -y firefox || {
                                echo -e "${RED}Error installing Firefox${NC}"
                                exit 1
                            }
                            
                            language_packages=$(apt-cache search firefox-l10n | awk '{print $1}' | sort)
                            if [ -n "$language_packages" ]; then
                                select_language_package "Firefox" && {
                                    echo "Installing language pack: $selected_package..."
                                    nala install -y "$selected_package" || echo -e "${YELLOW}Warning: Failed to install language pack${NC}"
                                }
                            else
                                echo -e "${YELLOW}No Firefox language packs available${NC}"
                            fi
                            ;;
                        3) # Firefox-ESR
                            echo -e "\n${GREEN}Installing Firefox ESR...${NC}"
                            nala install -y firefox-esr || {
                                echo -e "${RED}Error installing Firefox ESR${NC}"
                                exit 1
                            }
                            
                            language_packages=$(apt-cache search firefox-esr-l10n | awk '{print $1}' | sort)
                            if [ -n "$language_packages" ]; then
                                select_language_package "Firefox ESR" && {
                                    echo "Installing language pack: $selected_package..."
                                    nala install -y "$selected_package" || echo -e "${YELLOW}Warning: Failed to install language pack${NC}"
                                }
                            else
                                echo -e "${YELLOW}No Firefox ESR language packs available${NC}"
                            fi
                            ;;
                        4) # Icecat
echo -e "\n${GREEN}Installing Icecat...${NC}"
temp_dir=$(mktemp -d)
cd "$temp_dir" || {
    echo -e "${RED}Failed to create temp directory${NC}"
    exit 1
}

LATEST_URL=$(curl -s https://codeberg.org/chippy/gnuzilla/releases | grep -oP 'https://codeberg.org/chippy/gnuzilla/releases/download/[^"]+icecat_[^"]+_amd64\.deb' | head -n 1)
[ -z "$LATEST_URL" ] && {
    echo -e "${RED}Could not get latest Icecat download URL${NC}"
    exit 1
}

echo "Downloading Icecat from: $LATEST_URL"
wget -q "$LATEST_URL" -O icecat.deb || {
    echo -e "${RED}Failed to download Icecat${NC}"
    exit 1
}

sudo dpkg -i icecat.deb || {
    echo -e "${RED}Failed to install Icecat. Attempting to fix dependencies...${NC}"
    sudo apt-get install -f -y || {
        echo -e "${RED}Could not fix dependencies. Icecat installation failed.${NC}"
        cd - >/dev/null
        rm -rf "$temp_dir"
        exit 1
    }
}

# Create symlink if needed
[ ! -f /usr/bin/icecat ] && sudo ln -s /usr/local/bin/icecat /usr/bin/icecat

# Download icon
ICON_URL="https://upload.wikimedia.org/wikipedia/commons/d/df/Icecat.png"
sudo wget -q "$ICON_URL" -O /usr/share/pixmaps/icecat.png || {
    echo -e "${RED}Failed to download Icecat icon.${NC}"
}

# Create desktop file if needed
DESKTOP_FILE=/usr/share/applications/icecat.desktop
[ ! -f "$DESKTOP_FILE" ] && {
    cat <<EOF | sudo tee "$DESKTOP_FILE" > /dev/null
[Desktop Entry]
Version=1.0
Name=Icecat
Exec=/usr/bin/icecat %U
Icon=/usr/share/pixmaps/icecat.png
Type=Application
Categories=Network;WebBrowser;
Terminal=false
EOF
    sudo chmod 644 "$DESKTOP_FILE"
}

cd - >/dev/null
rm -rf "$temp_dir"
echo -e "${GREEN}Icecat installation completed successfully!${NC}"
;;
                        5) # LibreWolf
                            echo -e "\n${GREEN}Installing LibreWolf...${NC}"
                            nala update && nala install -y extrepo || {
                                echo -e "${RED}Error installing extrepo${NC}"
                                exit 1
                            }
                            sudo extrepo enable librewolf
                            nala update && nala install -y librewolf || {
                                echo -e "${RED}Error installing LibreWolf${NC}"
                                exit 1
                            }
                            ;;
                        6) # Mullvad
                            echo -e "\n${GREEN}Installing Mullvad...${NC}"
                            sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc
                            echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$(dpkg --print-architecture)] https://repository.mullvad.net/deb/stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mullvad.list
                            sudo nala update && sudo nala install -y mullvad-browser || {
                                echo -e "${RED}Error installing Mullvad${NC}"
                                exit 1
                            }
                            ;;
                        7) # Tor Browser
                            echo -e "\n${GREEN}Installing Tor Browser...${NC}"
                            nala update && nala install -y apt-transport-https || {
                                echo -e "${RED}Error installing apt-transport-https${NC}"
                                exit 1
                            }
                            echo "deb [signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/tor.list
                            wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | sudo tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null
                            nala update && nala install -y tor deb.torproject.org-keyring torbrowser-launcher || {
                                echo -e "${RED}Error installing Tor Browser${NC}"
                                exit 1
                            }
                            ;;
                        8) # None
                            echo -e "\n${BLUE}No browsers will be installed.${NC}"
                            clear
                            return
                            ;;
                        *)
                            echo -e "\n${RED}Invalid option: $option${NC}"
                            ;;
                    esac
                done
                echo -e "\n${GREEN}Browser installation completed successfully!${NC}"
                clear

            elif [ "$main_option" -eq 2 ]; then
                # Uninstallation menu
                echo -e "\nSelect browsers to uninstall (enter numbers separated by spaces):"
                echo -e "1) Epiphany ${YELLOW}- Simple web browser for GNOME.${NC} $(get_app_status epiphany-browser)"
                echo -e "2) Firefox ${YELLOW}- Popular open-source web browser.${NC} $(get_app_status firefox)"
                echo -e "3) Firefox ESR ${YELLOW}- Extended Support Release of Firefox.${NC} $(get_app_status firefox-esr)"
                echo -e "4) Icecat ${YELLOW}- GNU version of Firefox focused on privacy.${NC} $(get_app_status icecat)"
                echo -e "5) LibreWolf ${YELLOW}- Privacy-focused Firefox fork.${NC} $(get_app_status librewolf)"
                echo -e "6) Mullvad ${YELLOW}- Privacy-focused browser from Mullvad VPN.${NC} $(get_app_status mullvad-browser)"
                echo -e "7) Tor Browser ${YELLOW}- Browser for anonymous web browsing.${NC} $(get_app_status torbrowser-launcher)"
                echo "8) None"
                read -p "Option [1-8]: " -a uninstall_options

                for option in "${uninstall_options[@]}"; do
                    case $option in
                        1) # Epiphany
                            echo -e "\n${GREEN}Uninstalling Epiphany...${NC}"
                            nala remove --purge -y epiphany-browser || echo -e "${YELLOW}Warning: Error uninstalling Epiphany${NC}"
                            ;;
                        2) # Firefox
                            echo -e "\n${GREEN}Uninstalling Firefox...${NC}"
                            nala remove --purge -y firefox || echo -e "${YELLOW}Warning: Error uninstalling Firefox${NC}"
                            sudo rm -f /etc/apt/sources.list.d/mozilla.list /etc/apt/keyrings/packages.mozilla.org.asc
                            ;;
                        3) # Firefox-ESR
                            echo -e "\n${GREEN}Uninstalling Firefox ESR...${NC}"
                            nala remove --purge -y firefox-esr || echo -e "${YELLOW}Warning: Error uninstalling Firefox ESR${NC}"
                            ;;
                        4) # Icecat
                            echo -e "\n${GREEN}Uninstalling Icecat...${NC}"
                            sudo dpkg --purge icecat || echo -e "${YELLOW}Warning: Error uninstalling Icecat${NC}"
                            sudo rm -f /usr/local/bin/icecat /usr/share/pixmaps/icecat.png /usr/share/applications/icecat.desktop
                            ;;
                        5) # LibreWolf
                            echo -e "\n${GREEN}Uninstalling LibreWolf...${NC}"
                            nala remove --purge -y librewolf || echo -e "${YELLOW}Warning: Error uninstalling LibreWolf${NC}"
                            sudo extrepo disable librewolf
                            ;;
                        6) # Mullvad
                            echo -e "\n${GREEN}Uninstalling Mullvad...${NC}"
                            nala remove --purge -y mullvad-browser || echo -e "${YELLOW}Warning: Error uninstalling Mullvad${NC}"
                            sudo rm -f /etc/apt/sources.list.d/mullvad.list /usr/share/keyrings/mullvad-keyring.asc
                            ;;
                        7) # Tor Browser
                            echo -e "\n${GREEN}Uninstalling Tor Browser...${NC}"
                            nala remove --purge -y tor torbrowser-launcher || echo -e "${YELLOW}Warning: Error uninstalling Tor Browser${NC}"
                            sudo rm -f /etc/apt/sources.list.d/tor.list /usr/share/keyrings/deb.torproject.org-keyring.gpg
                            ;;
                        8) # None
                            echo -e "\n${BLUE}No browsers will be uninstalled.${NC}"
                            clear
                            return
                            ;;
                        *)
                            echo -e "\n${RED}Invalid option: $option${NC}"
                            ;;
                    esac
                done

                echo -e "\n${GREEN}Cleaning up orphaned packages...${NC}"
                nala autoremove -y || echo -e "${YELLOW}Warning: Error cleaning orphaned packages${NC}"
                echo -e "\n${GREEN}Uninstallation completed successfully!${NC}"
                clear

            elif [ "$main_option" -eq 3 ]; then
                echo -e "\n${BLUE}Exiting browser menu...${NC}"
                clear
                break
            else
                echo -e "\n${RED}Invalid option. Please try again.${NC}"
            fi
        else
            echo -e "\n${RED}Invalid option. Please try again.${NC}"
        fi
    done
}

manage_image_apps() {
    # ANSI color codes
    YELLOW='\033[38;5;178m'  # For descriptions
    WHITE='\033[0;37m'       # For status and messages
    NC='\033[0m'             # No Color

    # Improved application status check
    get_app_status() {
        if dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "ok installed"; then
            echo "✅"
        else
            echo "❌"
        fi
    }

    # Corrected Photo installation function
install_elementary_photo() {
    echo -e "${WHITE}Installing Elementary OS Photos...${NC}"
    local temp_deb="/tmp/elementary-photos.deb"
    
    # GitHub API URL to get the latest release
    local api_url="https://api.github.com/repos/qazlinux/photos/releases/latest"
    
    # Get the download URL for the latest .deb file
    local photo_url=$(curl -s $api_url | grep "browser_download_url.*\.deb" | cut -d '"' -f 4)

    # Check if the URL was found
    if [ -z "$photo_url" ]; then
        echo -e "${WHITE}No .deb file found for download.${NC}"
        return 1
    fi

    # Download the package
    if ! wget -q "$photo_url" -O "$temp_deb"; then
        echo -e "${WHITE}Failed to download Photos package from: $photo_url${NC}"
        return 1
    fi

    # Install with dependency resolution
    if ! sudo dpkg -i "$temp_deb"; then
        sudo apt-get install -f -y
    fi
    
    # Verify installation
    if dpkg-query -W -f='${Status}' "photos" 2>/dev/null | grep -q "ok installed"; then
        echo -e "${WHITE}Successfully installed Elementary OS Photos${NC}"
    else
        echo -e "${WHITE}Failed to install Elementary OS Photos${NC}"
    fi
    
    # Clean up
    rm -f "$temp_deb"
}

    while true; do
        echo ""
        echo -e "${YELLOW}=== IMAGE APPLICATIONS MANAGER ===${NC}"
        echo "1) Install image applications"
        echo "2) Uninstall image applications"
        echo "3) Return to main menu"
        read -p "Select option [1-3]: " main_option

        if [[ "$main_option" =~ ^[1-3]$ ]]; then
            if [ "$main_option" -eq 1 ]; then
                clear
                echo -e "${YELLOW}=== IMAGE APPLICATIONS MANAGER ===${NC}"
                echo "Select applications to install (separate numbers with spaces):"
                echo -e "1) Darktable ${YELLOW}- Professional photography workflow${NC} $(get_app_status darktable)"
                echo -e "2) Drawing ${YELLOW}- Simple drawing application${NC} $(get_app_status drawing)"
                echo -e "3) eog (Eye of GNOME) ${YELLOW}- Default GNOME image viewer${NC} $(get_app_status eog)"
                echo -e "4) eom (Eye of MATE) ${YELLOW}- Default MATE image viewer${NC} $(get_app_status eom)"
                echo -e "5) Geeqie ${YELLOW}- Lightweight image viewer${NC} $(get_app_status geeqie)"
                echo -e "6) Gimp ${YELLOW}- GNU Image Manipulation Program${NC} $(get_app_status gimp)"
                echo -e "7) gThumb ${YELLOW}- Image organizer and viewer${NC} $(get_app_status gthumb)"
                echo -e "8) Inkscape ${YELLOW}- Professional vector graphics editor${NC} $(get_app_status inkscape)"
                echo -e "9) Krita ${YELLOW}- Digital painting application${NC} $(get_app_status krita)"
                echo -e "10) mirage ${YELLOW}- Simple and fast image viewer${NC} $(get_app_status mirage)"
                echo -e "11) Photo (Elementary OS) ${YELLOW}- Minimalist photo viewer${NC} $(get_app_status photos)"
                echo -e "12) Ristretto ${YELLOW}- Xfce desktop image viewer${NC} $(get_app_status ristretto)"
                echo -e "13) Shotwell ${YELLOW}- Personal photo manager${NC} $(get_app_status shotwell)"
                echo -e "14) Viewnior ${YELLOW}- Fast and simple image viewer${NC} $(get_app_status viewnior)"
                echo "15) Install All"
                echo "16) Cancel"
                read -p "Enter your choices: " -a options

                for option in "${options[@]}"; do
                    case $option in
                        1) nala install -y darktable || echo -e "${WHITE}Failed to install Darktable${NC}" ;;
                        2) nala install -y drawing || echo -e "${WHITE}Failed to install Drawing${NC}" ;;
                        3) nala install -y eog || echo -e "${WHITE}Failed to install Eye of GNOME${NC}" ;;
                        4) nala install -y eom || echo -e "${WHITE}Failed to install Eye of MATE${NC}" ;;
                        5) nala install -y geeqie || echo -e "${WHITE}Failed to install Geeqie${NC}" ;;
                        6) nala install -y gimp || echo -e "${WHITE}Failed to install GIMP${NC}" ;;
                        7) nala install -y gthumb || echo -e "${WHITE}Failed to install gThumb${NC}" ;;
                        8) nala install -y inkscape || echo -e "${WHITE}Failed to install Inkscape${NC}" ;;
                        9) nala install -y krita || echo -e "${WHITE}Failed to install Krita${NC}" ;;
                        10) nala install -y mirage || echo -e "${WHITE}Failed to install Mirage${NC}" ;;
                        11) install_elementary_photo ;;
                        12) nala install -y ristretto || echo -e "${WHITE}Failed to install Ristretto${NC}" ;;
                        13) nala install -y shotwell || echo -e "${WHITE}Failed to install Shotwell${NC}" ;;
                        14) nala install -y viewnior || echo -e "${WHITE}Failed to install Viewnior${NC}" ;;
                        15)
                            echo -e "${WHITE}Installing all applications...${NC}"
                            nala install -y darktable drawing eog eom geeqie gimp gthumb inkscape krita mirage ristretto shotwell viewnior
                            install_elementary_photo
                            ;;
                        16) echo "Installation canceled" ;;
                        *) echo "Invalid option: $option" ;;
                    esac
                done
                read -p "Press Enter to continue..."

            elif [ "$main_option" -eq 2 ]; then
                clear
                echo -e "${YELLOW}=== IMAGE APPLICATIONS MANAGER ===${NC}"
                echo "Select applications to uninstall (separate numbers with spaces):"
                echo -e "1) Darktable ${YELLOW}- Professional photography workflow${NC} $(get_app_status darktable)"
                echo -e "2) Drawing ${YELLOW}- Simple drawing application${NC} $(get_app_status drawing)"
                echo -e "3) eog (Eye of GNOME) ${YELLOW}- Default GNOME image viewer${NC} $(get_app_status eog)"
                echo -e "4) eom (Eye of MATE) ${YELLOW}- Default MATE image viewer${NC} $(get_app_status eom)"
                echo -e "5) Geeqie ${YELLOW}- Lightweight image viewer${NC} $(get_app_status geeqie)"
                echo -e "6) Gimp ${YELLOW}- GNU Image Manipulation Program${NC} $(get_app_status gimp)"
                echo -e "7) gThumb ${YELLOW}- Image organizer and viewer${NC} $(get_app_status gthumb)"
                echo -e "8) Inkscape ${YELLOW}- Professional vector graphics editor${NC} $(get_app_status inkscape)"
                echo -e "9) Krita ${YELLOW}- Digital painting application${NC} $(get_app_status krita)"
                echo -e "10) mirage ${YELLOW}- Simple and fast image viewer${NC} $(get_app_status mirage)"
                echo -e "11) Photo (Elementary OS) ${YELLOW}- Minimalist photo viewer${NC} $(get_app_status photos)"
                echo -e "12) Ristretto ${YELLOW}- Xfce desktop image viewer${NC} $(get_app_status ristretto)"
                echo -e "13) Shotwell ${YELLOW}- Personal photo manager${NC} $(get_app_status shotwell)"
                echo -e "14) Viewnior ${YELLOW}- Fast and simple image viewer${NC} $(get_app_status viewnior)"
                echo "15) Uninstall All"
                echo "16) Cancel"
                read -p "Enter your choices: " -a options

                for option in "${options[@]}"; do
                    case $option in
                        1) nala remove --purge -y darktable 2>/dev/null || echo -e "${WHITE}Darktable not installed or already removed${NC}" ;;
                        2) nala remove --purge -y drawing 2>/dev/null || echo -e "${WHITE}Drawing not installed or already removed${NC}" ;;
                        3) nala remove --purge -y eog 2>/dev/null || echo -e "${WHITE}Eye of GNOME not installed or already removed${NC}" ;;
                        4) nala remove --purge -y eom 2>/dev/null || echo -e "${WHITE}Eye of MATE not installed or already removed${NC}" ;;
                        5) nala remove --purge -y geeqie 2>/dev/null || echo -e "${WHITE}Geeqie not installed or already removed${NC}" ;;
                        6) nala remove --purge -y gimp 2>/dev/null || echo -e "${WHITE}GIMP not installed or already removed${NC}" ;;
                        7) nala remove --purge -y gthumb 2>/dev/null || echo -e "${WHITE}gThumb not installed or already removed${NC}" ;;
                        8) nala remove --purge -y inkscape 2>/dev/null || echo -e "${WHITE}Inkscape not installed or already removed${NC}" ;;
                        9) nala remove --purge -y krita 2>/dev/null || echo -e "${WHITE}Krita not installed or already removed${NC}" ;;
                        10) nala remove --purge -y mirage 2>/dev/null || echo -e "${WHITE}Mirage not installed or already removed${NC}" ;;
                        11) nala remove --purge -y photos 2>/dev/null || echo -e "${WHITE}Elementary Photo not installed or already removed${NC}" ;;
                        12) nala remove --purge -y ristretto 2>/dev/null || echo -e "${WHITE}Ristretto not installed or already removed${NC}" ;;
                        13) nala remove --purge -y shotwell 2>/dev/null || echo -e "${WHITE}Shotwell not installed or already removed${NC}" ;;
                        14) nala remove --purge -y viewnior 2>/dev/null || echo -e "${WHITE}Viewnior not installed or already removed${NC}" ;;
                        15)
                            echo -e "${WHITE}Uninstalling all applications...${NC}"
                            for app in darktable drawing eog eom geeqie gimp gthumb inkscape krita mirage photos ristretto shotwell viewnior; do
                                nala remove --purge -y "$app" 2>/dev/null || echo -e "${WHITE}$app not installed or already removed${NC}"
                            done
                            nala autoremove -y
                            ;;
                        16) echo "Uninstallation canceled" ;;
                        *) echo "Invalid option: $option" ;;
                    esac
                done
                nala autoremove -y
                read -p "Press Enter to continue..."

            elif [ "$main_option" -eq 3 ]; then
                clear
                return 0
            fi
        else
            echo -e "${WHITE}Invalid option. Please enter a number between 1 and 3.${NC}"
            sleep 2
        fi
    done
}

# Función para mostrar el estado de la aplicación
get_app_status() {
    if is_installed "$1"; then
        echo -e "\e[32m✅ Instalado\e[0m"
    else
        echo -e "\e[31m❌ No instalado\e[0m"
    fi
}


# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -E "^ii\s+$1" > /dev/null
}

# Function to display the application status
get_app_status() {
    if is_installed "$1"; then
        echo -e "\e[32m✅\e[0m"  # For installed
    else
        echo "❌"  # For not installed
    fi
}

# Function to check if an application is installed
is_installed() {
    dpkg -l | grep -q "$1"
}

# Function for messaging application installation
install_messaging_apps() {
    # ANSI color codes
    YELLOW='\033[38;5;178m'
    NC='\033[0m' # No Color

    while true; do
        echo "Select an option:"
        echo "1) Install messaging applications"
        echo "2) Uninstall messaging applications"
        echo "3) Exit"
        read -p "Option [1-3]: " option_main
        case $option_main in
            1)  # Install applications
                echo "Select applications to install:"
                echo -e "1) Element ${YELLOW} - Secure messaging app based on Matrix.${NC} $(get_app_status element-desktop)"
                echo -e "2) Gajim ${YELLOW} - Jabber/XMPP client with a user-friendly interface.${NC} $(get_app_status gajim)"
                echo -e "3) Jami ${YELLOW} - Decentralized communication platform for voice, video, and messaging.${NC} $(get_app_status jami)"
                echo -e "4) Pidgin + OTR ${YELLOW} - Multi-protocol instant messaging client with encryption.${NC} $(get_app_status pidgin)"
                echo -e "5) Session ${YELLOW} - Privacy-focused messaging app that doesn't require a phone number.${NC} $(get_app_status session-desktop)"
                echo -e "6) Signal ${YELLOW} - Encrypted messaging app known for its strong privacy features.${NC} $(get_app_status signal-desktop)"
                echo -e "7) QTox ${YELLOW} - Secure and private messaging app based on Tox protocol.${NC} $(get_app_status qtox)"
                echo "8) None"

                read -p "Option [1-8]: " -a options

                # Install the selected messaging applications
                for option in "${options[@]}"; do
                    case $option in
                        1) # Element
                            if is_installed "element-desktop"; then
                                echo "Element is already installed."
                            else
                                echo "Installing Element..."
                                sudo nala install -y wget apt-transport-https
                                sudo wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
                                echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | sudo tee /etc/apt/sources.list.d/element-io.list
                                sudo nala update
                                sudo nala install -y element-desktop
                            fi
                            ;;
                        2) # Gajim
                            if is_installed "gajim"; then
                                echo "Gajim is already installed."
                            else
                                echo "Installing Gajim..."
                                sudo nala install -y gajim || { echo "Error installing Gajim."; }
                            fi
                            ;;
                        3) # Jami
                            if is_installed "jami"; then
                                echo "Jami is already installed."
                            else
                                echo "Installing Jami..."
                                sudo nala install gnupg dirmngr ca-certificates curl --no-install-recommends 
                                curl -s https://dl.jami.net/public-key.gpg | sudo tee /usr/share/keyrings/jami-archive-keyring.gpg > /dev/null
                                sudo sh -c "echo 'deb [signed-by=/usr/share/keyrings/jami-archive-keyring.gpg] https://dl.jami.net/stable/debian_12/ jami main' > /etc/apt/sources.list.d/jami.list"
                                sudo nala update
                                sudo nala install -y jami || { echo "Error installing Jami."; }
                            fi
                            ;;
                        4) # Pidgin + OTR
                            if is_installed "pidgin"; then
                                echo "Pidgin is already installed."
                            else
                                echo "Installing Pidgin + OTR..."
                                sudo nala install -y pidgin pidgin-otr || { echo "Error installing Pidgin + OTR."; }
                            fi
                            sudo clear
                            ;;
                        5) # Session
                            if is_installed "session-desktop"; then
                                echo "Session is already installed."
                            else
                                echo "Installing Session..."
                                sudo curl -so /etc/apt/trusted.gpg.d/oxen.gpg https://deb.oxen.io/pub.gpg
                                echo "deb https://deb.oxen.io $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/oxen.list
                                sudo nala update
                                sudo nala install -y session-desktop || { echo "Error installing Session."; }
                            fi
                            ;;
                        6) # Signal
                            if is_installed "signal-desktop"; then
                                echo "Signal is already installed."
                            else
                                echo "Installing Signal..."
                                wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
                                cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
                                echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal-xenial.list
                                sudo nala update
                                sudo nala install -y signal-desktop || { echo "Error installing Signal."; }
                            fi
                            ;;
                        7) # QTox
                            if is_installed "qtox"; then
                                echo "QTox is already installed."
                            else
                                echo "Installing QTox..."
                                sudo nala install -y qtox || { echo "Error installing QTox."; }
                            fi
                            ;;
                        8) # None
                            echo "No applications will be installed."
                            sudo clear
                            return
                            ;;
                        *) # Invalid option
                            echo "Invalid option: $option"
                            ;;
                    esac
                done

                echo "Installation completed."
                # Clean up orphaned packages
                sudo nala autoremove -y
                ;;

            2)  # Uninstall applications
                echo -e "1) Element ${YELLOW} - Secure messaging app based on Matrix.${NC} $(get_app_status element-desktop)"
                echo -e "2) Gajim ${YELLOW} - Jabber/XMPP client with a user-friendly interface.${NC} $(get_app_status gajim)"
                echo -e "3) Jami ${YELLOW} - Decentralized communication platform for voice, video, and messaging.${NC} $(get_app_status jami)"
                echo -e "4) Pidgin + OTR ${YELLOW} - Multi-protocol instant messaging client with encryption.${NC} $(get_app_status pidgin)"
                echo -e "5) Session ${YELLOW} - Privacy-focused messaging app that doesn't require a phone number.${NC} $(get_app_status session-desktop)"
                echo -e "6) Signal ${YELLOW} - Encrypted messaging app known for its strong privacy features.${NC} $(get_app_status signal-desktop)"
                echo -e "7) QTox ${YELLOW} - Secure and private messaging app based on Tox protocol.${NC} $(get_app_status qtox)"
                echo "8) None"

                read -p "Option [1-8]: " -a options

                # Uninstall the selected messaging applications
                for option in "${options[@]}"; do
                    case $option in
                        1) # Element
                            if is_installed "element-desktop"; then
                                echo "Uninstalling Element..."
                                sudo nala remove --purge -y element-desktop || { echo "Error uninstalling Element."; }
                                sudo rm -r /etc/apt/sources.list.d/element-io.list
	                            else
                                echo "Element is not installed."
                            fi
                            ;;
                        2) # Gajim
                            if is_installed "gajim"; then
                                echo "Uninstalling Gajim..."
                                sudo nala remove --purge -y gajim || { echo "Error uninstalling Gajim."; }
                            else
                                echo "Gajim is not installed."
                            fi
                            ;;
                        3) # Jami
                            if is_installed "jami"; then
                                echo "Uninstalling Jami..."
                                sudo rm -f /etc/apt/sources.list.d/jami.list
                                sudo rm -f /usr/share/keyrings/jami-archive-keyring.gpg
                                sudo nala remove --purge -y jami || { echo "Error uninstalling Jami."; }
                            else
                                echo "Jami is not installed."
                            fi
                            ;;
                        4) # Pidgin + OTR
                            if is_installed "pidgin"; then
                                echo "Uninstalling Pidgin + OTR..."
                                sudo nala remove --purge -y pidgin pidgin-otr || { echo "Error uninstalling Pidgin + OTR."; }
                            else
                                echo "Pidgin is not installed."
                            fi
                            ;;
                        5) # Session
                            if is_installed "session-desktop"; then
                                echo "Uninstalling Session..."
                                sudo rm -f /etc/apt/sources.list.d/oxen.list
                                sudo rm -f /etc/apt/trusted.gpg.d/oxen.gpg
                                sudo nala remove --purge -y session-desktop || { echo "Error uninstalling Session."; }
                            else
                                echo "Session is not installed."
                            fi
                            ;;
                        6) # Signal
                            if is_installed "signal-desktop"; then
                                echo "Uninstalling Signal..."
                                sudo rm -f /etc/apt/sources.list.d/signal-xenial.list
                                sudo rm -f /usr/share/keyrings/signal-desktop-keyring.gpg
                                sudo nala remove --purge -y signal-desktop || { echo "Error uninstalling Signal."; }
                            else
                                echo "Signal is not installed."
                            fi
                            ;;
                        7) # QTox
                            if is_installed "qtox"; then
                                echo "Uninstalling QTox..."
                                sudo nala remove --purge -y qtox || { echo "Error uninstalling QTox."; }
                            else
                                echo "QTox is not installed."
                            fi
                            ;;
                        8) # None
                            echo "No applications will be uninstalled."
                            sudo clear
                            return
                            ;;
                        *) # Invalid option
                            echo "Invalid option: $option"
                            ;;
                    esac
                done

                echo "Uninstallation completed."
                # Clean up orphaned packages
                sudo nala autoremove -y
                ;;
            3)  # Exit
                echo "Exiting..."
                break
                ;;
            *)  # Invalid option
                echo "Invalid option. Please select again."
                ;;
        esac
    done
sudo clear
}


# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -E "^ii\s+($1|$1-gui|$1-gtk)" > /dev/null 2>&1
}

# Function to display the application status
get_app_status() {
    if is_installed "$1"; then
        echo -e "\e[32m✅\e[0m"  # For installed
    else
        echo "❌"  # For not installed
    fi
}
## Function to check if an application is installed
is_installed() {
    dpkg -l | grep -q "$1"
}

# Function for music application installation
install_music_apps() {
    # ANSI color codes
    YELLOW='\033[38;5;178m'
    NC='\033[0m' # No Color

    while true; do
        echo "Select an option:"
        echo "1) Install music applications"
        echo "2) Uninstall music applications"
        echo "3) Exit"
        read -p "Option [1-3]: " main_option

        if [[ "$main_option" =~ ^[1-3]$ ]]; then
            if [ "$main_option" -eq 1 ]; then
                # Installation menu
                echo "Select the music applications you want to install (enter the corresponding numbers, separated by spaces):"
                echo -e "1) Audacious ${YELLOW} - Lightweight music player with a simple interface.${NC} $(get_app_status audacious)"
                echo -e "2) Clementine ${YELLOW} - Modern music player and library organizer.${NC} $(get_app_status clementine)"
                echo -e "3) Exaile ${YELLOW} - Music player and library manager with a focus on simplicity.${NC} $(get_app_status exaile)"
                echo -e "4) Lollypop ${YELLOW} - Modern music player with a beautiful interface.${NC} $(get_app_status lollypop)"
                echo -e "5) Ncmpcpp ${YELLOW} - Feature-rich music player client for MPD.${NC} $(get_app_status ncmpcpp)"
                echo -e "6) Quod Libet ${YELLOW} - Music player with a focus on flexibility and extensibility.${NC} $(get_app_status quodlibet)"
                echo -e "7) Strawberry ${YELLOW} - Music player and library organizer inspired by Clementine.${NC} $(get_app_status strawberry)"
                echo "8) None"
                read -p "Option [1-8]: " -a options

                # Install selected applications
                for option in "${options[@]}"; do
                    case $option in
                        1) # Audacious
                            echo "Installing Audacious..."
                            nala install -y audacious || { echo "Error installing Audacious"; exit 1; }
                            ;;
                        2) # Clementine
                            echo "Installing Clementine..."
                            nala install -y clementine || { echo "Error installing Clementine"; exit 1; }
                            ;;
                        3) # Exaile
                            echo "Installing Exaile..."
                            nala install -y exaile || { echo "Error installing Exaile"; exit 1; }
                            ;;
                        4) # Lollypop
                            echo "Installing Lollypop..."
                            nala install -y lollypop || { echo "Error installing Lollypop"; exit 1; }
                            ;;
                        5) # Ncmpcpp
                            echo "Installing Ncmpcpp..."
                            nala install -y ncmpcpp || { echo "Error installing Ncmpcpp"; exit 1; }
                            ;;
                        6) # Quod Libet
                            echo "Installing Quod Libet..."
                            nala install -y quodlibet || { echo "Error installing Quod Libet"; exit 1; }
                            ;;
                        7) # Strawberry
                            echo "Installing Strawberry..."
                            nala install -y strawberry || { echo "Error installing Strawberry"; exit 1; }
                            ;;
                        8) # None
                            echo "No music application will be installed."
                            break
                            ;;
                        *) # Invalid option
                            echo "Invalid option: $option"
                            ;;
                    esac
                done

                echo "Installation completed. Enjoy your music applications!"
                clear

            elif [ "$main_option" -eq 2 ]; then
                # Uninstallation menu
                echo "Select the music applications you want to uninstall (enter the corresponding numbers, separated by spaces):"
                echo -e "1) Audacious ${YELLOW} - Lightweight music player with a simple interface.${NC} $(get_app_status audacious)"
                echo -e "2) Clementine ${YELLOW} - Modern music player and library organizer.${NC} $(get_app_status clementine)"
                echo -e "3) Exaile ${YELLOW} - Music player and library manager with a focus on simplicity.${NC} $(get_app_status exaile)"
                echo -e "4) Lollypop ${YELLOW} - Modern music player with a beautiful interface.${NC} $(get_app_status lollypop)"
                echo -e "5) Ncmpcpp ${YELLOW} - Feature-rich music player client for MPD.${NC} $(get_app_status ncmpcpp)"
                echo -e "6) Quod Libet ${YELLOW} - Music player with a focus on flexibility and extensibility.${NC} $(get_app_status quodlibet)"
                echo -e "7) Strawberry ${YELLOW} - Music player and library organizer inspired by Clementine.${NC} $(get_app_status strawberry)"
                echo "8) None"
                read -p "Option [1-8]: " -a options

                # Uninstall selected applications
                for option in "${options[@]}"; do
                    case $option in
                        1) # Audacious
                            echo "Uninstalling Audacious..."
                            nala remove --purge -y audacious || { echo "Error uninstalling Audacious"; }
                            ;;
                        2) # Clementine
                            echo "Uninstalling Clementine..."
                            nala remove --purge -y clementine || { echo "Error uninstalling Clementine"; }
                            ;;
                        3) # Exaile
                            echo "Uninstalling Exaile..."
                            nala remove --purge -y exaile || { echo "Error uninstalling Exaile"; }
                            ;;
                        4) # Lollypop
                            echo "Uninstalling Lollypop..."
                            nala remove --purge -y lollypop || { echo "Error uninstalling Lollypop"; }
                            ;;
                        5) # Ncmpcpp
                            echo "Uninstalling Ncmpcpp..."
                            nala remove --purge -y ncmpcpp || { echo "Error uninstalling Ncmpcpp"; }
                            ;;
                        6) # Quod Libet
                            echo "Uninstalling Quod Libet..."
                            nala remove --purge -y quodlibet || { echo "Error uninstalling Quod Libet"; }
                            ;;
                        7) # Strawberry
                            echo "Uninstalling Strawberry..."
                            nala remove --purge -y strawberry || { echo "Error uninstalling Strawberry"; }
                            ;;
                        8) # None
                            echo "No music application will be uninstalled."
                            break
                            ;;
                        *) # Invalid option
                            echo "Invalid option: $option"
                            ;;
                    esac
                done

                # Clean up orphaned packages
                echo "Cleaning orphaned packages..."
                nala autoremove -y

                echo "Uninstallation completed."
                clear

            elif [ "$main_option" -eq 3 ]; then
                echo "Exiting the music application menu."
                clear
                return
            else
                echo "Invalid option: $main_option"
            fi
        else
            echo "Invalid option. Please enter a number between 1 and 3."
        fi
    done
}

# Function for video application installation
install_video_apps() {
    # ANSI color codes
    YELLOW='\033[38;5;178m'
    NC='\033[0m' # No Color

    while true; do
        echo "Select an option:"
        echo "1) Install video applications"
        echo "2) Uninstall video applications"
        echo "3) Exit"
        read -p "Option [1-3]: " main_option

        if [[ "$main_option" =~ ^[1-3]$ ]]; then
            if [ "$main_option" -eq 1 ]; then
                # Installation menu
                echo "Select the video applications you want to install (enter the corresponding numbers, separated by spaces):"
                echo -e "1) Avidemux ${YELLOW} - Video editor designed for quick cutting, filtering, and encoding.${NC} $(get_app_status avidemux)"
                echo -e "2) Blender ${YELLOW} - Powerful open-source 3D creation suite with video editing capabilities.${NC} $(get_app_status blender)"
                echo -e "3) Celluloid ${YELLOW} - Simple video player for the GNOME desktop.${NC} $(get_app_status celluloid)"
                echo -e "4) Gnome Videos (Totem) ${YELLOW} - Default video player for GNOME, easy to use.${NC} $(get_app_status totem)"
                echo -e "5) Handbrake ${YELLOW} - Open-source video transcoder for converting video files.${NC} $(get_app_status handbrake)"
                echo -e "6) MKVToolNix ${YELLOW} - Set of tools to create, alter, and inspect Matroska files.${NC} $(get_app_status mkvtoolnix)"
                echo -e "7) MPV ${YELLOW} - Versatile media player based on MPlayer and mplayer2.${NC} $(get_app_status mpv)"
                echo -e "8) Parole ${YELLOW} - Media player designed for the Xfce desktop environment.${NC} $(get_app_status parole)"
                echo -e "9) Pitivi ${YELLOW} - Open-source video editor with a user-friendly interface.${NC} $(get_app_status pitivi)"
                echo -e "10) Shotcut ${YELLOW} - Open-source video editor with a wide range of features.${NC} $(get_app_status shotcut)"
                echo -e "11) VLC Media Player ${YELLOW} - Popular open-source media player that supports various formats.${NC} $(get_app_status vlc)"
                echo "12) None"
                read -p "Option [1-12]: " -a options

                # Install selected applications
                for option in "${options[@]}"; do
                    case $option in
                        1) # Avidemux
                            echo "Installing Avidemux..."
                            nala install -y avidemux || { echo "Error installing Avidemux"; exit 1; }
                            ;;
                        2) # Blender
                            echo "Installing Blender..."
                            nala install -y blender || { echo "Error installing Blender"; exit 1; }
                            ;;
                        3) # Celluloid
                            echo "Installing Celluloid..."
                            nala install -y celluloid || { echo "Error installing Celluloid"; exit 1; }
                            ;;
                        4) # Gnome Videos (Totem)
                            echo "Installing Gnome Videos (Totem)..."
                            nala install -y totem || { echo "Error installing Gnome Videos (Totem)"; exit 1; }
                            ;;
                        5) # Handbrake
                            echo "Installing Handbrake..."
                            nala install -y handbrake handbrake-gtk || { echo "Error installing HandBrake"; exit 1; }
                            ;;
                        6) # MKVToolNix
                            echo "Installing MKVToolNix..."
                            sudo wget -O /usr/share/keyrings/gpg-pub-moritzbunkus.gpg https://mkvtoolnix.download/gpg-pub-moritzbunkus.gpg
                            echo "deb [signed-by=/usr/share/keyrings/gpg-pub-moritzbunkus.gpg] https://mkvtoolnix.download/debian/ bookworm main" | sudo tee /etc/apt/sources.list.d/mkvtoolnix.download.list
                            echo "deb-src [signed-by=/usr/share/keyrings/gpg-pub-moritzbunkus.gpg] https://mkvtoolnix.download/debian/ bookworm main" | sudo tee -a /etc/apt/sources.list.d/mkvtoolnix.download.list
                            nala update
                            nala install -y mkvtoolnix mkvtoolnix-gui || { echo "Error installing MKVToolNix"; exit 1; }
                            ;;
                        7) # MPV
                            echo "Installing MPV..."
                            nala install -y mpv || { echo "Error installing MPV"; exit 1; }
                            ;;
                        8) # Parole
                            echo "Installing Parole..."
                            nala install -y parole || { echo "Error installing Parole"; exit 1; }
                            ;;
                        9) # Pitivi
                            echo "Installing Pitivi..."
                            nala install -y pitivi || { echo "Error installing Pitivi"; exit 1; }
                            ;;
                        10) # Shotcut
                            echo "Installing Shotcut..."
                            nala install -y shotcut || { echo "Error installing Shotcut"; exit 1; }
                            ;;
                        11) # VLC Media Player
                            echo "Installing VLC Media Player..."
                            nala install -y vlc || { echo "Error installing VLC Media Player"; exit 1; }
                            ;;
                        12) # None
                            echo "No video application will be installed."
                            break
                            ;;
                        *) # Invalid option
                            echo "Invalid option: $option"
                            ;;
                    esac
                done

                echo "Installation completed. Enjoy your video applications!"
                clear

            elif [ "$main_option" -eq 2 ]; then
                # Uninstallation menu
                echo "Select the video applications you want to uninstall (enter the corresponding numbers, separated by spaces):"
                echo -e "1) Avidemux ${YELLOW} - Video editor designed for quick cutting, filtering, and encoding.${NC} $(get_app_status avidemux)"
                echo -e "2) Blender ${YELLOW} - Powerful open-source 3D creation suite with video editing capabilities.${NC} $(get_app_status blender)"
                echo -e "3) Celluloid ${YELLOW} - Simple video player for the GNOME desktop.${NC} $(get_app_status celluloid)"
                echo -e "4) Gnome Videos (Totem) ${YELLOW} - Default video player for GNOME, easy to use.${NC} $(get_app_status totem)"
                echo -e "5) Handbrake ${YELLOW} - Open-source video transcoder for converting video files.${NC} $(get_app_status handbrake)"
                echo -e "6) MKVToolNix ${YELLOW} - Set of tools to create, alter, and inspect Matroska files.${NC} $(get_app_status mkvtoolnix)"
                echo -e "7) MPV ${YELLOW} - Versatile media player based on MPlayer and mplayer2.${NC} $(get_app_status mpv)"
                echo -e "8) Parole ${YELLOW} - Media player designed for the Xfce desktop environment.${NC} $(get_app_status parole)"
                echo -e "9) Pitivi ${YELLOW} - Open-source video editor with a user-friendly interface.${NC} $(get_app_status pitivi)"
                echo -e "10) Shotcut ${YELLOW} - Open-source video editor with a wide range of features.${NC} $(get_app_status shotcut)"
                echo -e "11) VLC Media Player ${YELLOW} - Popular open-source media player that supports various formats.${NC} $(get_app_status vlc)"
                echo "12) None"
                read -p "Option [1-12]: " -a options

                # Uninstall selected applications
                for option in "${options[@]}"; do
                    case $option in
                        1) # Avidemux
                            echo "Uninstalling Avidemux..."
                            nala remove --purge -y avidemux || { echo "Error uninstalling Avidemux"; }
                            ;;
                        2) # Blender
                            echo "Uninstalling Blender..."
                            nala remove --purge -y blender || { echo "Error uninstalling Blender"; }
                            ;;
                        3) # Celluloid
                            echo "Uninstalling Celluloid..."
                            nala remove --purge -y celluloid || { echo "Error uninstalling Celluloid"; }
                            ;;
                        4) # Gnome Videos (Totem)
                            echo "Uninstalling Gnome Videos (Totem)..."
                            nala remove --purge -y totem || { echo "Error uninstalling Gnome Videos (Totem)"; }
                            ;;
                        5) # Handbrake
                            echo "Uninstalling Handbrake..."
                            nala remove --purge -y handbrake handbrake-gtk || { echo "Error uninstalling Handbrake"; }
                            ;;
                        6) # MKVToolNix
                            echo "Uninstalling MKVToolNix..."
                            nala remove --purge -y mkvtoolnix mkvtoolnix-gui || { echo "Error uninstalling MKVToolNix"; }
                            # Optionally remove the repository
                            if [ -f "/etc/apt/sources.list.d/mkvtoolnix.download.list" ]; then
                                sudo rm /etc/apt/sources.list.d/mkvtoolnix.download.list
                                sudo rm /usr/share/keyrings/gpg-pub-moritzbunkus.gpg
                                nala update
                            fi
                            ;;
                        7) # MPV
                            echo "Uninstalling MPV..."
                            nala remove --purge -y mpv || { echo "Error uninstalling MPV"; }
                            ;;
                        8) # Parole
                            echo "Uninstalling Parole..."
                            nala remove --purge -y parole || { echo "Error uninstalling Parole"; }
                            ;;
                        9) # Pitivi
                            echo "Uninstalling Pitivi..."
                            nala remove --purge -y pitivi || { echo "Error uninstalling Pitivi"; }
                            ;;
                        10) # Shotcut
                            echo "Uninstalling Shotcut..."
                            nala remove --purge -y shotcut || { echo "Error uninstalling Shotcut"; }
                            ;;
                        11) # VLC Media Player
                            echo "Uninstalling VLC Media Player..."
                            nala remove --purge -y vlc || { echo "Error uninstalling VLC Media Player"; }
                            ;;
                        12) # None
                            echo "No video application will be uninstalled."
                            break
                            ;;
                        *) # Invalid option
                            echo "Invalid option: $option"
                            ;;
                    esac
                done

                # Clean up orphaned packages
                echo "Cleaning orphaned packages..."
                nala autoremove -y

                echo "Uninstallation completed."
                clear

            elif [ "$main_option" -eq 3 ]; then
                echo "Exiting the video application menu."
                clear     
                return
            else
                echo "Invalid option: $main_option"
            fi
        else
            echo "Invalid option. Please enter a number between 1 and 3."
        fi
    done
}


# Function for multimedia application installation
install_multimedia_apps() {
    # ANSI color codes
    YELLOW='\033[38;5;178m'
    NC='\033[0m' # No Color

    while true; do
        echo "Select an option:"
        echo "1) Install multimedia applications"
        echo "2) Uninstall multimedia applications"
        echo "3) Exit"
        read -p "Option [1-3]: " main_option

        if [[ "$main_option" =~ ^[1-3]$ ]]; then
            if [ "$main_option" -eq 1 ]; then
                # Installation menu
                echo "Select the multimedia applications you want to install (enter the corresponding numbers, separated by spaces):"
                echo -e "1) Aegisub ${YELLOW} - Subtitle editor for creating and editing subtitles.${NC} $(get_app_status aegisub)"
                echo -e "2) Brasero ${YELLOW} - Disc burning application for GNOME.${NC} $(get_app_status brasero)"
                echo -e "3) ExFalso ${YELLOW} - Audio tag editor for various audio formats.${NC} $(get_app_status exfalso)"
                echo -e "4) Kodi ${YELLOW} - Open-source media center for managing and playing media.${NC} $(get_app_status kodi)"
                echo -e "5) Media-Downloader ${YELLOW} - Tool for downloading media from various sources.${NC} $(get_app_status media-downloader)"
                echo -e "6) Mediainfo ${YELLOW} - Tool for reading media file information.${NC} $(get_app_status mediainfo)"
                echo -e "7) OBS Studio ${YELLOW} - Open-source software for video recording and live streaming.${NC} $(get_app_status obs-studio)"
                echo -e "8) SimpleScreenRecorder ${YELLOW} - Easy-to-use screen recording application.${NC} $(get_app_status simplescreenrecorder)"
                echo -e "9) Stremio ${YELLOW} - Media center for streaming and organizing content.${NC} $(get_app_status stremio)"
                echo "10) None"
                read -p "Option [1-10]: " -a options

                # Install selected applications
                for option in "${options[@]}"; do
                    case $option in
                        1) # Aegisub
                            echo "Installing Aegisub..."
                            nala install -y aegisub || { echo "Error installing Aegisub"; exit 1; }
                            ;;
                        2) # Brasero
                            echo "Installing Brasero..."
                            nala install -y brasero || { echo "Error installing Brasero"; exit 1; }
                            ;;
                        3) # ExFalso
                            echo "Installing ExFalso..."
                            nala install -y exfalso || { echo "Error installing ExFalso"; exit 1; }
                            ;;
                        4) # Kodi
                            echo "Installing Kodi..."
                            nala install -y kodi || { echo "Error installing Kodi"; exit 1; }
                            ;;
                        5) # Media-Downloader
                            echo "Installing Media-Downloader..."
                            nala install -y media-downloader || { echo "Error installing Media-Downloader"; exit 1; }
                            ;;
                        6) # Mediainfo
                            echo "Installing Mediainfo..."
                            nala install -y mediainfo || { echo "Error installing Mediainfo"; exit 1; }
                            ;;
                        7) # OBS Studio
                            echo "Installing OBS Studio..."
                            nala install -y obs-studio || { echo "Error installing OBS Studio"; exit 1; }
                            ;;
                        8) # SimpleScreenRecorder
                            echo "Installing SimpleScreenRecorder..."
                            nala install -y simplescreenrecorder || { echo "Error installing SimpleScreenRecorder"; exit 1; }
                            ;;
                        9) # Stremio
                            echo "Installing Stremio..."
                            # Create temp directory for downloads
                            temp_dir=$(mktemp -d)
                            cd "$temp_dir" || { echo "Failed to create temp directory"; exit 1; }
                            
                            # Install dependencies
                            sudo mkdir -p /usr/share/desktop-directories/
                            wget -q http://ftp.es.debian.org/debian/pool/main/m/mpv/libmpv1_0.32.0-3_amd64.deb || { echo "Failed to download libmpv"; exit 1; }
                            sudo dpkg -i libmpv1_0.32.0-3_amd64.deb || sudo apt-get install -f -y
                            
                            # Install Stremio
                            wget -q https://dl.strem.io/shell-linux/v4.4.165/Stremio_v4.4.165.deb || { echo "Failed to download Stremio"; exit 1; }
                            sudo dpkg -i Stremio_v4.4.165.deb || sudo apt-get install -f -y
                            
                            # Clean up
                            cd - >/dev/null
                            rm -rf "$temp_dir"
                            ;;
                        10) # None
                            echo "No multimedia application will be installed."
                            break
                            ;;
                        *) # Invalid option
                            echo "Invalid option: $option"
                            ;;
                    esac
                done

                echo "Installation completed. Enjoy your multimedia applications!"
                clear

            elif [ "$main_option" -eq 2 ]; then
                # Uninstallation menu
                echo "Select the multimedia applications you want to uninstall (enter the corresponding numbers, separated by spaces):"
                echo -e "1) Aegisub ${YELLOW} - Subtitle editor for creating and editing subtitles.${NC} $(get_app_status aegisub)"
                echo -e "2) Brasero ${YELLOW} - Disc burning application for GNOME.${NC} $(get_app_status brasero)"
                echo -e "3) ExFalso ${YELLOW} - Audio tag editor for various audio formats.${NC} $(get_app_status exfalso)"
                echo -e "4) Kodi ${YELLOW} - Open-source media center for managing and playing media.${NC} $(get_app_status kodi)"
                echo -e "5) Media-Downloader ${YELLOW} - Tool for downloading media from various sources.${NC} $(get_app_status media-downloader)"
                echo -e "6) Mediainfo ${YELLOW} - Tool for reading media file information.${NC} $(get_app_status mediainfo)"
                echo -e "7) OBS Studio ${YELLOW} - Open-source software for video recording and live streaming.${NC} $(get_app_status obs-studio)"
                echo -e "8) SimpleScreenRecorder ${YELLOW} - Easy-to-use screen recording application.${NC} $(get_app_status simplescreenrecorder)"
                echo -e "9) Stremio ${YELLOW} - Media center for streaming and organizing content.${NC} $(get_app_status stremio)"
                echo "10) None"
                read -p "Option [1-10]: " -a options

                # Uninstall selected applications
                for option in "${options[@]}"; do
                    case $option in
                        1) # Aegisub
                            echo "Uninstalling Aegisub..."
                            nala remove --purge -y aegisub || { echo "Error uninstalling Aegisub"; }
                            ;;
                        2) # Brasero
                            echo "Uninstalling Brasero..."
                            nala remove --purge -y brasero || { echo "Error uninstalling Brasero"; }
                            ;;
                        3) # ExFalso
                            echo "Uninstalling ExFalso..."
                            nala remove --purge -y exfalso || { echo "Error uninstalling ExFalso"; }
                            ;;
                        4) # Kodi
                            echo "Uninstalling Kodi..."
                            nala remove --purge -y kodi || { echo "Error uninstalling Kodi"; }
                            ;;
                        5) # Media-Downloader
                            echo "Uninstalling Media-Downloader..."
                            nala remove --purge -y media-downloader || { echo "Error uninstalling Media-Downloader"; }
                            ;;
                        6) # Mediainfo
                            echo "Uninstalling Mediainfo..."
                            nala remove --purge -y mediainfo || { echo "Error uninstalling Mediainfo"; }
                            ;;
                        7) # OBS Studio
                            echo "Uninstalling OBS Studio..."
                            nala remove --purge -y obs-studio || { echo "Error uninstalling OBS Studio"; }
                            ;;
                        8) # SimpleScreenRecorder
                            echo "Uninstalling SimpleScreenRecorder..."
                            nala remove --purge -y simplescreenrecorder || { echo "Error uninstalling SimpleScreenRecorder"; }
                            ;;
                        9) # Stremio
                            echo "Uninstalling Stremio..."
                            nala remove --purge -y stremio || { echo "Error uninstalling Stremio"; }
                            # Remove potential leftover files
                            sudo rm -f /usr/share/desktop-directories/stremio.directory
                            ;;
                        10) # None
                            echo "No multimedia application will be uninstalled."
                            break
                            ;;
                        *) # Invalid option
                            echo "Invalid option: $option"
                            ;;
                    esac
                done

                # Clean up orphaned packages
                echo "Cleaning orphaned packages..."
                nala autoremove -y

                echo "Uninstallation completed."
                clear

            elif [ "$main_option" -eq 3 ]; then
                echo "Exiting the multimedia application menu."
                clear
                return
            else
                echo "Invalid option: $main_option"
            fi
        else
            echo "Invalid option. Please enter a number between 1 and 3."
        fi
    done
}

# Function to check if an application is installed
is_installed() {
    dpkg -l | grep -qw "$1"
}

# Function to display the application status with emoji
get_app_status() {
    if is_installed "$1"; then
        echo -e "\e[32m✅ Installed\e[0m"  # Green checkmark for installed
    else
        echo -e "\e[31m❌ Not installed\e[0m"  # Red X for not installed
    fi
}

# Function to install security and privacy applications
install_security_privacy_apps() {
    # ANSI color codes
    YELLOW='\033[38;5;178m'
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    while true; do
        echo -e "\n${BLUE}Security & Privacy Applications Menu:${NC}"
        echo "1) Install security and privacy applications"
        echo "2) Uninstall security and privacy applications"
        echo "3) Exit"
        read -p "Select option [1-3]: " main_option

        if [[ "$main_option" =~ ^[1-3]$ ]]; then
            if [ "$main_option" -eq 1 ]; then
                # Installation menu
                echo -e "\n${GREEN}Available Security & Privacy Applications:${NC}"
                echo -e "1) OnionShare ${YELLOW}- Anonymous file sharing tool.${NC} $(get_app_status onionshare)"
                echo -e "2) KeePassXC ${YELLOW}- Password manager.${NC} $(get_app_status keepassxc)"
                echo -e "3) GnuPG ${YELLOW}- Secure communication tool.${NC} $(get_app_status gnupg)"
                echo -e "4) VeraCrypt ${YELLOW}- Disk encryption software.${NC} $(get_app_status veracrypt)"
                echo -e "5) Cryptsetup ${YELLOW}- Disk encryption tool.${NC} $(get_app_status cryptsetup)"
                echo -e "6) OpenVPN ${YELLOW}- VPN client.${NC} $(get_app_status openvpn)"
                echo -e "7) Riseup VPN ${YELLOW}- Privacy-focused VPN.${NC} $(get_app_status riseup-vpn)"
                echo -e "8) BleachBit ${YELLOW}- Privacy and cleaning tool.${NC} $(get_app_status bleachbit)"
                echo -e "9) ClamTk ${YELLOW}- GUI for ClamAV.${NC} $(get_app_status clamtk)"
                echo -e "10) Gufw Firewall ${YELLOW}- User-friendly firewall.${NC} $(get_app_status gufw)"
                echo -e "11) Kleopatra ${YELLOW}- Certificate manager.${NC} $(get_app_status kleopatra)"
                echo -e "12) Metadata Cleaner ${YELLOW}- Removes metadata from files.${NC} $(get_app_status metadata-cleaner)"
                echo -e "13) Syncthing ${YELLOW}- Continuous file synchronization program.${NC} $(get_app_status syncthing)"
                echo -e "14) ${BLUE}None${NC}"
                
                read -p "Select applications to install (space-separated numbers) [1-14]: " -a options

                for option in "${options[@]}"; do
                    case $option in
                        1) # OnionShare
                            echo -e "\n${GREEN}Installing OnionShare...${NC}"
                            nala install -y onionshare || {
                                echo -e "${RED}Error installing OnionShare${NC}"
                                exit 1
                            }
                            ;;
                        2) # KeePassXC
                            echo -e "\n${GREEN}Installing KeePassXC...${NC}"
                            nala install -y keepassxc || {
                                echo -e "${RED}Error installing KeePassXC${NC}"
                                exit 1
                            }
                            ;;
                        3) # GnuPG
                            echo -e "\n${GREEN}Installing GnuPG...${NC}"
                            nala install -y gnupg || {
                                echo -e "${RED}Error installing GnuPG${NC}"
                                exit 1
                            }
                            ;;
                        4) # VeraCrypt
                           # Base URL for VeraCrypt
                           BASE_URL="https://launchpad.net/veracrypt/trunk"

                           # Get the latest version
                           LATEST_VERSION=$(curl -s "$BASE_URL" | grep -oP 'veracrypt-\K[0-9.]+(?=-Debian-12-amd64\.deb)' | sort -V | tail -n 1)

                           # Construct the download URL
                           DOWNLOAD_URL="$BASE_URL/$LATEST_VERSION/+download/veracrypt-$LATEST_VERSION-Debian-12-amd64.deb"

                           # Download the file
                           wget "$DOWNLOAD_URL" -O "veracrypt-$LATEST_VERSION-Debian-12-amd64.deb"

                           # Install the package
                           sudo nala install -y libwxgtk3.2-1
                           sudo dpkg -i "veracrypt-$LATEST_VERSION-Debian-12-amd64.deb"

                           # Check if the installation was successful
                           if [ $? -eq 0 ]; then
                               echo "VeraCrypt $LATEST_VERSION installed successfully."
                               # Delete the downloaded file
                               rm "veracrypt-$LATEST_VERSION-Debian-12-amd64.deb"
                               echo "Downloaded file deleted."
                           else
                               echo "Error installing VeraCrypt."
                           fi
                            ;;
                        5) # Cryptsetup
                            echo -e "\n${GREEN}Installing Cryptsetup...${NC}"
                            nala install -y cryptsetup || {
                                echo -e "${RED}Error installing Cryptsetup${NC}"
                                exit 1
                            }
                            ;;
                        6) # OpenVPN
                            echo -e "\n${GREEN}Installing OpenVPN...${NC}"
                            nala install -y openvpn || {
                                echo -e "${RED}Error installing OpenVPN${NC}"
                                exit 1
                            }
                            ;;
                        7) # Riseup VPN
                            echo -e "\n${GREEN}Installing Riseup VPN...${NC}"
                            nala install -y riseup-vpn || {
                                echo -e "${RED}Error installing Riseup VPN${NC}"
                                exit 1
                            }
                            ;;
                        8) # BleachBit
                            echo -e "\n${GREEN}Installing BleachBit...${NC}"
                            nala install -y bleachbit || {
                                echo -e "${RED}Error installing BleachBit${NC}"
                                exit 1
                            }
                            ;;
                        9) # ClamTk
                            echo -e "\n${GREEN}Installing ClamTk...${NC}"
                            nala install -y clamtk || {
                                echo -e "${RED}Error installing ClamTk${NC}"
                                exit 1
                            }
                            ;;
                        10) # Gufw Firewall
                            echo -e "\n${GREEN}Installing Gufw Firewall...${NC}"
                            nala install -y gufw || {
                                echo -e "${RED}Error installing Gufw Firewall${NC}"
                                exit 1
                            }
                            ;;
                        11) # Kleopatra
                            echo -e "\n${GREEN}Installing Kleopatra...${NC}"
                            nala install -y kleopatra || {
                                echo -e "${RED}Error installing Kleopatra${NC}"
                                exit 1
                            }
                            ;;
                        12) # Metadata Cleaner
                            echo -e "\n${GREEN}Installing Metadata Cleaner...${NC}"
                            nala install -y metadata-cleaner || {
                                echo -e "${RED}Error installing Metadata Cleaner${NC}"
                                exit 1
                            }
                            ;;
                        13) # Syncthing
                            echo -e "\n${GREEN}Installing Syncthing...${NC}"
                            nala install -y syncthing || {
                                echo -e "${RED}Error installing Syncthing${NC}"
                                exit 1
                            }
                            ;;
                        14) # None
                            echo -e "\n${BLUE}Skipping application installation${NC}"
                            break
                            ;;
                        *)
                            echo -e "\n${RED}Invalid option: $option${NC}"
                            ;;
                    esac
                done

                echo -e "\n${GREEN}Installation completed successfully!${NC}"
                clear

            elif [ "$main_option" -eq 2 ]; then
                # Uninstallation menu
                echo -e "\n${GREEN}Installed Security & Privacy Applications:${NC}"
                echo -e "1) OnionShare ${YELLOW}- Anonymous file sharing tool.${NC} $(get_app_status onionshare)"
                echo -e "2) KeePassXC ${YELLOW}- Password manager.${NC} $(get_app_status keepassxc)"
                echo -e "3) GnuPG ${YELLOW}- Secure communication tool.${NC} $(get_app_status gnupg)"
                echo -e "4) VeraCrypt ${YELLOW}- Disk encryption software.${NC} $(get_app_status veracrypt)"
                echo -e "5) Cryptsetup ${YELLOW}- Disk encryption tool.${NC} $(get_app_status cryptsetup)"
                echo -e "6) OpenVPN ${YELLOW}- VPN client.${NC} $(get_app_status openvpn)"
                echo -e "7) Riseup VPN ${YELLOW}- Privacy-focused VPN.${NC} $(get_app_status riseup-vpn)"
                echo -e "8) BleachBit ${YELLOW}- Privacy and cleaning tool.${NC} $(get_app_status bleachbit)"
                echo -e "9) ClamTk ${YELLOW}- GUI for ClamAV.${NC} $(get_app_status clamtk)"
                echo -e "10) Gufw Firewall ${YELLOW}- User-friendly firewall.${NC} $(get_app_status gufw)"
                echo -e "11) Kleopatra ${YELLOW}- Certificate manager.${NC} $(get_app_status kleopatra)"
                echo -e "12) Metadata Cleaner ${YELLOW}- Removes metadata from files.${NC} $(get_app_status metadata-cleaner)"
                echo -e "13) Syncthing ${YELLOW}- Continuous file synchronization program.${NC} $(get_app_status syncthing)"
                echo -e "14) ${BLUE}None${NC}"
                
                read -p "Select applications to uninstall (space-separated numbers) [1-14]: " -a uninstall_options

                for option in "${uninstall_options[@]}"; do
                    case $option in
                        1) # OnionShare
                            echo -e "\n${GREEN}Uninstalling OnionShare...${NC}"
                            nala remove --purge -y onionshare || echo -e "${YELLOW}Warning: Error uninstalling OnionShare${NC}"
                            ;;
                        2) # KeePassXC
                            echo -e "\n${GREEN}Uninstalling KeePassXC...${NC}"
                            nala remove --purge -y keepassxc || echo -e "${YELLOW}Warning: Error uninstalling KeePassXC${NC}"
                            ;;
                        3) # GnuPG
                            echo -e "\n${GREEN}Uninstalling GnuPG...${NC}"
                            nala remove --purge -y gnupg || echo -e "${YELLOW}Warning: Error uninstalling GnuPG${NC}"
                            ;;
                        4) # VeraCrypt
                            echo -e "\n${GREEN}Uninstalling VeraCrypt...${NC}"
                            nala remove --purge -y veracrypt || echo -e "${YELLOW}Warning: Error uninstalling VeraCrypt${NC}"
                            ;;
                        5) # Cryptsetup
                            echo -e "\n${GREEN}Uninstalling Cryptsetup...${NC}"
                            nala remove --purge -y cryptsetup || echo -e "${YELLOW}Warning: Error uninstalling Cryptsetup${NC}"
                            ;;
                        6) # OpenVPN
                            echo -e "\n${GREEN}Uninstalling OpenVPN...${NC}"
                            nala remove --purge -y openvpn || echo -e "${YELLOW}Warning: Error uninstalling OpenVPN${NC}"
                            ;;
                        7) # Riseup VPN
                            echo -e "\n${GREEN}Uninstalling Riseup VPN...${NC}"
                            nala remove --purge -y riseup-vpn || echo -e "${YELLOW}Warning: Error uninstalling Riseup VPN${NC}"
                            ;;
                        8) # BleachBit
                            echo -e "\n${GREEN}Uninstalling BleachBit...${NC}"
                            nala remove --purge -y bleachbit || echo -e "${YELLOW}Warning: Error uninstalling BleachBit${NC}"
                            ;;
                        9) # ClamTk
                            echo -e "\n${GREEN}Uninstalling ClamTk...${NC}"
                            nala remove --purge -y clamtk || echo -e "${YELLOW}Warning: Error uninstalling ClamTk${NC}"
                            ;;
                        10) # Gufw Firewall
                            echo -e "\n${GREEN}Uninstalling Gufw Firewall...${NC}"
                            nala remove --purge -y gufw || echo -e "${YELLOW}Warning: Error uninstalling Gufw Firewall${NC}"
                            ;;
                        11) # Kleopatra
                            echo -e "\n${GREEN}Uninstalling Kleopatra...${NC}"
                            nala remove --purge -y kleopatra || echo -e "${YELLOW}Warning: Error uninstalling Kleopatra${NC}"
                            ;;
                        12) # Metadata Cleaner
                            echo -e "\n${GREEN}Uninstalling Metadata Cleaner...${NC}"
                            nala remove --purge -y metadata-cleaner || echo -e "${YELLOW}Warning: Error uninstalling Metadata Cleaner${NC}"
                            ;;
                        13) # Syncthing
                            echo -e "\n${GREEN}Uninstalling Syncthing...${NC}"
                            nala remove --purge -y syncthing || echo -e "${YELLOW}Warning: Error uninstalling Syncthing${NC}"
                            ;;
                        14) # None
                            echo -e "\n${BLUE}Skipping application uninstallation${NC}"
                            break
                            ;;
                        *)
                            echo -e "\n${RED}Invalid option: $option${NC}"
                            ;;
                    esac
                done

                echo -e "\n${GREEN}Cleaning up orphaned packages...${NC}"
                nala autoremove -y || echo -e "${YELLOW}Warning: Error cleaning orphaned packages${NC}"
                
                echo -e "\n${GREEN}Uninstallation completed successfully!${NC}"
                clear

            elif [ "$main_option" -eq 3 ]; then
                echo -e "\n${BLUE}Exiting security and privacy applications menu...${NC}"
                clear
                break
            else
                echo -e "\n${RED}Invalid option: $main_option${NC}"
            fi
        else
            echo -e "\n${RED}Invalid option. Please enter a number between 1 and 3.${NC}"
        fi
    done
}
#!/bin/bash

# Function to install audit and security testing applications
install_audit_security_apps() {
    # ANSI color codes
    YELLOW='\033[38;5;178m'
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color

    while true; do
        echo -e "\n${CYAN}Audit & Security Testing Applications Menu:${NC}"
        echo "1) Install audit and security testing applications"
        echo "2) Uninstall audit and security testing applications"
        echo "3) Exit"
        read -p "Select option [1-3]: " main_option

        if [[ "$main_option" =~ ^[1-3]$ ]]; then
            if [ "$main_option" -eq 1 ]; then
                # Installation menu
                echo -e "\n${GREEN}Available Audit & Security Testing Applications:${NC}"
                echo -e "1) Nmap ${YELLOW}- Network exploration tool.${NC} $(get_app_status nmap)"
                echo -e "2) Wireshark ${YELLOW}- Network protocol analyzer.${NC} $(get_app_status wireshark)"
                echo -e "3) John the Ripper ${YELLOW}- Password cracking tool.${NC} $(get_app_status john)"
                echo -e "4) SQLMap ${YELLOW}- SQL injection testing tool.${NC} $(get_app_status sqlmap)"
                echo -e "5) Ettercap ${YELLOW}- Network sniffer/interceptor/logger.${NC} $(get_app_status ettercap)"
                echo -e "6) Lynis ${YELLOW}- Security auditing tool.${NC} $(get_app_status lynis)"
                echo -e "7) Gobuster ${YELLOW}- Directory/file brute-forcer.${NC} $(get_app_status gobuster)"
                echo -e "8) Suricata ${YELLOW}- Network threat detection engine.${NC} $(get_app_status suricata)"
                echo -e "9) Recon-ng ${YELLOW}- Web reconnaissance framework.${NC} $(get_app_status recon-ng)"
                echo -e "10) Social-Engineer Toolkit (SET) ${YELLOW}- Penetration testing framework for social engineering.${NC} $(get_app_status set)"
                echo -e "11) ${BLUE}None${NC}"
                
                read -p "Select applications to install (space-separated numbers) [1-11]: " -a options

                for option in "${options[@]}"; do
                    case $option in
                        1) # Nmap
                            echo -e "\n${GREEN}Installing Nmap...${NC}"
                            nala install -y nmap || {
                                echo -e "${RED}Error installing Nmap${NC}"
                                exit 1
                            }
                            ;;
                        2) # Wireshark
                            echo -e "\n${GREEN}Installing Wireshark...${NC}"
                            nala install -y wireshark || {
                                echo -e "${RED}Error installing Wireshark${NC}"
                                exit 1
                            }
                            ;;
                        3) # John the Ripper
                            echo -e "\n${GREEN}Installing John the Ripper...${NC}"
                            nala install -y john || {
                                echo -e "${RED}Error installing John the Ripper${NC}"
                                exit 1
                            }
                            ;;
                        4) # SQLMap
                            echo -e "\n${GREEN}Installing SQLMap...${NC}"
                            nala install -y sqlmap || {
                                echo -e "${RED}Error installing SQLMap${NC}"
                                exit 1
                            }
                            ;;
                        5) # Ettercap
                            echo -e "\n${GREEN}Installing Ettercap...${NC}"
                            nala install -y ettercap-graphical || {
                                echo -e "${RED}Error installing Ettercap${NC}"
                                exit 1
                            }
                            ;;
                        6) # Lynis
                            echo -e "\n${GREEN}Installing Lynis...${NC}"
                            nala install -y lynis || {
                                echo -e "${RED}Error installing Lynis${NC}"
                                exit 1
                            }
                            ;;
                        7) # Gobuster
                            echo -e "\n${GREEN}Installing Gobuster...${NC}"
                            nala install -y gobuster || {
                                echo -e "${RED}Error installing Gobuster${NC}"
                                exit 1
                            }
                            ;;
                        8) # Suricata
                            echo -e "\n${GREEN}Installing Suricata...${NC}"
                            nala install -y suricata || {
                                echo -e "${RED}Error installing Suricata${NC}"
                                exit 1
                            }
                            ;;
                        9) # Recon-ng
                            echo -e "\n${GREEN}Installing Recon-ng...${NC}"
                            nala install -y recon-ng || {
                                echo -e "${RED}Error installing Recon-ng${NC}"
                                exit 1
                            }
                            ;;
                        10) # SET
                            echo -e "\n${GREEN}Installing Social-Engineer Toolkit...${NC}"
                            nala install -y set || {
                                echo -e "${RED}Error installing Social-Engineer Toolkit${NC}"
                                exit 1
                            }
                            ;;
                        11) # None
                            echo -e "\n${BLUE}Skipping application installation${NC}"
                            break
                            ;;
                        *)
                            echo -e "\n${RED}Invalid option: $option${NC}"
                            ;;
                    esac
                done

                echo -e "\n${GREEN}Installation completed successfully!${NC}"
                clear

            elif [ "$main_option" -eq 2 ]; then
                # Uninstallation menu
                echo -e "\n${GREEN}Installed Audit & Security Testing Applications:${NC}"
                echo -e "1) Nmap ${YELLOW}- Network exploration tool.${NC} $(get_app_status nmap)"
                echo -e "2) Wireshark ${YELLOW}- Network protocol analyzer.${NC} $(get_app_status wireshark)"
                echo -e "3) John the Ripper ${YELLOW}- Password cracking tool.${NC} $(get_app_status john)"
                echo -e "4) SQLMap ${YELLOW}- SQL injection testing tool.${NC} $(get_app_status sqlmap)"
                echo -e "5) Ettercap ${YELLOW}- Network sniffer/interceptor/logger.${NC} $(get_app_status ettercap)"
                echo -e "6) Lynis ${YELLOW}- Security auditing tool.${NC} $(get_app_status lynis)"
                echo -e "7) Gobuster ${YELLOW}- Directory/file brute-forcer.${NC} $(get_app_status gobuster)"
                echo -e "8) Suricata ${YELLOW}- Network threat detection engine.${NC} $(get_app_status suricata)"
                echo -e "9) Recon-ng ${YELLOW}- Web reconnaissance framework.${NC} $(get_app_status recon-ng)"
                echo -e "10) Social-Engineer Toolkit (SET) ${YELLOW}- Penetration testing framework for social engineering.${NC} $(get_app_status set)"
                echo -e "11) ${BLUE}None${NC}"
                
                read -p "Select applications to uninstall (space-separated numbers) [1-11]: " -a uninstall_options

                for option in "${uninstall_options[@]}"; do
                    case $option in
                        1) # Nmap
                            echo -e "\n${GREEN}Uninstalling Nmap...${NC}"
                            nala remove --purge -y nmap || echo -e "${YELLOW}Warning: Error uninstalling Nmap${NC}"
                            ;;
                        2) # Wireshark
                            echo -e "\n${GREEN}Uninstalling Wireshark...${NC}"
                            nala remove --purge -y wireshark || echo -e "${YELLOW}Warning: Error uninstalling Wireshark${NC}"
                            ;;
                        3) # John the Ripper
                            echo -e "\n${GREEN}Uninstalling John the Ripper...${NC}"
                            nala remove --purge -y john || echo -e "${YELLOW}Warning: Error uninstalling John the Ripper${NC}"
                            ;;
                        4) # SQLMap
                            echo -e "\n${GREEN}Uninstalling SQLMap...${NC}"
                            nala remove --purge -y sqlmap || echo -e "${YELLOW}Warning: Error uninstalling SQLMap${NC}"
                            ;;
                        5) # Ettercap
                            echo -e "\n${GREEN}Uninstalling Ettercap...${NC}"
                            nala remove --purge -y ettercap-graphical || echo -e "${YELLOW}Warning: Error uninstalling Ettercap${NC}"
                            ;;
                        6) # Lynis
                            echo -e "\n${GREEN}Uninstalling Lynis...${NC}"
                            nala remove --purge -y lynis || echo -e "${YELLOW}Warning: Error uninstalling Lynis${NC}"
                            ;;
                        7) # Gobuster
                            echo -e "\n${GREEN}Uninstalling Gobuster...${NC}"
                            nala remove --purge -y gobuster || echo -e "${YELLOW}Warning: Error uninstalling Gobuster${NC}"
                            ;;
                        8) # Suricata
                            echo -e "\n${GREEN}Uninstalling Suricata...${NC}"
                            nala remove --purge -y suricata || echo -e "${YELLOW}Warning: Error uninstalling Suricata${NC}"
                            ;;
                        9) # Recon-ng
                            echo -e "\n${GREEN}Uninstalling Recon-ng...${NC}"
                            nala remove --purge -y recon-ng || echo -e "${YELLOW}Warning: Error uninstalling Recon-ng${NC}"
                            ;;
                        10) # SET
                            echo -e "\n${GREEN}Uninstalling Social-Engineer Toolkit...${NC}"
                            nala remove --purge -y set || echo -e "${YELLOW}Warning: Error uninstalling Social-Engineer Toolkit${NC}"
                            ;;
                        11) # None
                            echo -e "\n${BLUE}Skipping application uninstallation${NC}"
                            break
                            ;;
                        *)
                            echo -e "\n${RED}Invalid option: $option${NC}"
                            ;;
                    esac
                done

                echo -e "\n${GREEN}Cleaning up orphaned packages...${NC}"
                nala autoremove -y || echo -e "${YELLOW}Warning: Error cleaning orphaned packages${NC}"
                
                echo -e "\n${GREEN}Uninstallation completed successfully!${NC}"
                clear

            elif [ "$main_option" -eq 3 ]; then
                echo -e "\n${BLUE}Exiting audit and security testing applications menu...${NC}"
                clear
                break
            else
                echo -e "\n${RED}Invalid option: $main_option${NC}"
            fi
        else
            echo -e "\n${RED}Invalid option. Please enter a number between 1 and 3.${NC}"
        fi
    done
}
# Function for download manager and BitTorrent client installation
install_download_apps() {
    # ANSI color codes
    YELLOW='\033[38;5;178m'
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color

    while true; do
        echo -e "\n${CYAN}Download Manager & BitTorrent Client Menu:${NC}"
        echo "1) Install download managers and BitTorrent clients"
        echo "2) Uninstall download managers and BitTorrent clients"
        echo "3) Exit"
        read -p "Select option [1-3]: " main_option

        if [[ "$main_option" =~ ^[1-3]$ ]]; then
            if [ "$main_option" -eq 1 ]; then
                # Installation menu
                echo -e "\n${GREEN}Available Download Managers & BitTorrent Clients:${NC}"
                echo -e "1) Deluge ${YELLOW}- Feature-rich BitTorrent client${NC} $(get_app_status deluge)"
                echo -e "2) qBittorrent ${YELLOW}- Open-source BitTorrent client${NC} $(get_app_status qbittorrent)"
                echo -e "3) Transmission ${YELLOW}- Lightweight BitTorrent client${NC} $(get_app_status transmission-common transmission-gtk)"
                echo -e "4) Free Download Manager (FDM) ${YELLOW}- Powerful download manager${NC} $(get_app_status fdm)"
                echo -e "5) uGet ${YELLOW}- Lightweight download manager${NC} $(get_app_status uget)"
                echo -e "6) ${BLUE}None${NC}"
                
                read -p "Select applications to install (space-separated numbers) [1-6]: " -a options

                for option in "${options[@]}"; do
                    case $option in
                        1) # Deluge
                            echo -e "\n${GREEN}Installing Deluge...${NC}"
                            nala install -y deluge || {
                                echo -e "${RED}Error installing Deluge${NC}"
                                exit 1
                            }
                            ;;
                        2) # qBittorrent
                            echo -e "\n${GREEN}Installing qBittorrent...${NC}"
                            nala install -y qbittorrent || {
                                echo -e "${RED}Error installing qBittorrent${NC}"
                                exit 1
                            }
                            ;;
                        3) # Transmission
                            echo -e "\n${GREEN}Installing Transmission...${NC}"
                            nala install -y transmission-common transmission-gtk || {
                                echo -e "${RED}Error installing Transmission${NC}"
                                exit 1
                            }
                            ;;
                        4) # FDM
                            echo -e "\n${GREEN}Installing Free Download Manager...${NC}"
                            nala install -y fdm || {
                                echo -e "${RED}Error installing Free Download Manager${NC}"
                                exit 1
                            }
                            ;;
                        5) # uGet
                            echo -e "\n${GREEN}Installing uGet...${NC}"
                            nala install -y uget aria2 || {
                                echo -e "${RED}Error installing uGet${NC}"
                                exit 1
                            }
                            ;;
                        6) # None
                            echo -e "\n${BLUE}Skipping application installation${NC}"
                            break
                            ;;
                        *)
                            echo -e "\n${RED}Invalid option: $option${NC}"
                            ;;
                    esac
                done

                echo -e "\n${GREEN}Installation completed successfully!${NC}"
                clear

            elif [ "$main_option" -eq 2 ]; then
                # Uninstallation menu
                echo -e "\n${GREEN}Installed Download Managers & BitTorrent Clients:${NC}"
                echo -e "1) Deluge ${YELLOW}- Feature-rich BitTorrent client${NC} $(get_app_status deluge)"
                echo -e "2) qBittorrent ${YELLOW}- Open-source BitTorrent client${NC} $(get_app_status qbittorrent)"
                echo -e "3) Transmission ${YELLOW}- Lightweight BitTorrent client${NC} $(get_app_status transmission-common transmission-gtk)"
                echo -e "4) Free Download Manager (FDM) ${YELLOW}- Powerful download manager${NC} $(get_app_status fdm)"
                echo -e "5) uGet ${YELLOW}- Lightweight download manager${NC} $(get_app_status uget)"
                echo -e "6) ${BLUE}None${NC}"
                
                read -p "Select applications to uninstall (space-separated numbers) [1-6]: " -a uninstall_options

                for option in "${uninstall_options[@]}"; do
                    case $option in
                        1) # Deluge
                            echo -e "\n${GREEN}Uninstalling Deluge...${NC}"
                            nala remove --purge -y deluge || echo -e "${YELLOW}Warning: Error uninstalling Deluge${NC}"
                            ;;
                        2) # qBittorrent
                            echo -e "\n${GREEN}Uninstalling qBittorrent...${NC}"
                            nala remove --purge -y qbittorrent || echo -e "${YELLOW}Warning: Error uninstalling qBittorrent${NC}"
                            ;;
                        3) # Transmission
                            echo -e "\n${GREEN}Uninstalling Transmission...${NC}"
                            nala remove --purge -y transmission-common transmission-gtk || echo -e "${YELLOW}Warning: Error uninstalling Transmission${NC}"
                            ;;
                        4) # FDM
                            echo -e "\n${GREEN}Uninstalling Free Download Manager...${NC}"
                            nala remove --purge -y fdm || echo -e "${YELLOW}Warning: Error uninstalling Free Download Manager${NC}"
                            ;;
                        5) # uGet
                            echo -e "\n${GREEN}Uninstalling uGet...${NC}"
                            nala remove --purge -y uget aria2 || echo -e "${YELLOW}Warning: Error uninstalling uGet${NC}"
                            ;;
                        6) # None
                            echo -e "\n${BLUE}Skipping application uninstallation${NC}"
                            break
                            ;;
                        *)
                            echo -e "\n${RED}Invalid option: $option${NC}"
                            ;;
                    esac
                done

                echo -e "\n${GREEN}Cleaning up orphaned packages...${NC}"
                nala autoremove -y || echo -e "${YELLOW}Warning: Error cleaning orphaned packages${NC}"
                
                echo -e "\n${GREEN}Uninstallation completed successfully!${NC}"
                clear

            elif [ "$main_option" -eq 3 ]; then
                echo -e "\n${BLUE}Exiting download manager and BitTorrent client menu...${NC}"
                clear
                break
            else
                echo -e "\n${RED}Invalid option: $main_option${NC}"
            fi
        else
            echo -e "\n${RED}Invalid option. Please enter a number between 1 and 3.${NC}"
        fi
    done
}

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check dependencies
check_dependencies() {
    echo -e "\n${BLUE}Checking dependencies...${NC}"
    local missing=0
    
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Error: git is not installed.${NC}"
        missing=1
    fi
    
    if ! command -v nala &> /dev/null; then
        echo -e "${RED}Error: nala is not installed.${NC}"
        missing=1
    fi
    
    if [ $missing -eq 1 ]; then
        echo -e "\n${YELLOW}Please install missing dependencies and try again.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}All dependencies are satisfied.${NC}"
    return 0
}

# Function to install auto-cpufreq from GitHub
install_energy_management_tool() {
    echo -e "\n${BLUE}Installing auto-cpufreq...${NC}"
    
    # Check for existing directory
    if [ -d "auto-cpufreq" ]; then
        echo -e "${YELLOW}'auto-cpufreq' directory already exists. Removing it to clone fresh.${NC}"
        rm -rf auto-cpufreq || {
            echo -e "${RED}Error: Failed to remove existing directory.${NC}"
            return 1
        }
    fi

    # Clone repository
    echo -e "${BLUE}Cloning auto-cpufreq from GitHub...${NC}"
    git clone https://github.com/AdnanHodzic/auto-cpufreq.git || {
        echo -e "${RED}Error: Failed to clone auto-cpufreq repository.${NC}"
        return 1
    }

    cd auto-cpufreq || {
        echo -e "${RED}Error: Failed to enter 'auto-cpufreq' directory.${NC}"
        return 1
    }
    
    # Install
    echo -e "${BLUE}Running installer...${NC}"
    sudo ./auto-cpufreq-installer || {
        echo -e "${RED}Error: auto-cpufreq installation failed.${NC}"
        cd ..
        return 1
    }
    
    echo -e "${GREEN}auto-cpufreq installed successfully.${NC}"
    
    # Prompt for configuration
    read -p "$(echo -e ${YELLOW}"Do you want to run 'sudo auto-cpufreq --install' now? (y/n): "${NC})" run_option
    if [[ "$run_option" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Configuring auto-cpufreq...${NC}"
        sudo auto-cpufreq --install || {
            echo -e "${YELLOW}Warning: Failed to configure auto-cpufreq.${NC}"
            cd ..
            return 1
        }
        echo -e "${GREEN}auto-cpufreq has been configured.${NC}"
    fi

    # Return to previous directory
    cd .. || {
        echo -e "${YELLOW}Warning: Failed to return to previous directory.${NC}"
        return 1
    }
}

# Function to install TLP normally
install_tlp() {
    echo -e "\n${BLUE}Installing TLP...${NC}"
    
    echo -e "${BLUE}Updating package lists...${NC}"
    sudo nala update || {
        echo -e "${RED}Error: Failed to update package lists.${NC}"
        return 1
    }
    
    echo -e "${BLUE}Installing TLP...${NC}"
    sudo nala install -y tlp || {
        echo -e "${RED}Error: Failed to install TLP.${NC}"
        return 1
    }
    
    echo -e "${GREEN}TLP installed successfully.${NC}"
}

# Function to install TLP for ThinkPad
install_tlp_thinkpad() {
    echo -e "\n${BLUE}Installing TLP for ThinkPad...${NC}"
    
    echo -e "${BLUE}Updating package lists...${NC}"
    sudo nala update || {
        echo -e "${RED}Error: Failed to update package lists.${NC}"
        return 1
    }
    
    echo -e "${BLUE}Installing TLP and ThinkPad-specific packages...${NC}"
    sudo nala install -y tlp tlp-rdw || {
        echo -e "${RED}Error: Failed to install TLP for ThinkPad.${NC}"
        return 1
    }
    
    echo -e "${GREEN}TLP for ThinkPad installed successfully.${NC}"
}

# Function to uninstall auto-cpufreq
uninstall_auto_cpufreq() {
    echo -e "\n${BLUE}Uninstalling auto-cpufreq...${NC}"
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || {
        echo -e "${RED}Error: Failed to create temp directory.${NC}"
        return 1
    }
    
    echo -e "${BLUE}Cloning auto-cpufreq for uninstallation...${NC}"
    git clone https://github.com/AdnanHodzic/auto-cpufreq.git || {
        echo -e "${RED}Error: Failed to clone auto-cpufreq repository.${NC}"
        cd ..
        rm -rf "$temp_dir"
        return 1
    }
    
    cd auto-cpufreq || {
        echo -e "${RED}Error: Failed to enter 'auto-cpufreq' directory.${NC}"
        cd ..
        rm -rf "$temp_dir"
        return 1
    }
    
    sudo ./auto-cpufreq-installer --remove || {
        echo -e "${RED}Error: Failed to uninstall auto-cpufreq.${NC}"
        cd ../..
        rm -rf "$temp_dir"
        return 1
    }
    
    cd ../..
    rm -rf "$temp_dir"
    echo -e "${GREEN}auto-cpufreq uninstalled successfully.${NC}"
}

# Function to uninstall TLP
uninstall_tlp() {
    echo -e "\n${BLUE}Uninstalling TLP...${NC}"
    
    sudo nala remove --purge -y tlp || {
        echo -e "${RED}Error: Failed to uninstall TLP.${NC}"
        return 1
    }
    
    echo -e "${GREEN}TLP uninstalled successfully.${NC}"
}

# Function to manage energy management tools
manage_energy_tools() {
    while true; do
        echo -e "\n${CYAN}Energy Management Tools Installation:${NC}"
        echo "1) Install auto-cpufreq"
        echo "2) Install TLP"
        echo "3) Install TLP for ThinkPad"
        echo "4) Go back to the main menu"
        read -p "$(echo -e ${YELLOW}"Select option [1-4]: "${NC})" install_option

        case $install_option in
            1)
                install_energy_management_tool
                ;;
            2)
                install_tlp
                ;;
            3)
                install_tlp_thinkpad
                ;;
            4)
                echo -e "${BLUE}Returning to the main menu.${NC}"
                return
                ;;
            *)
                echo -e "${RED}Invalid option. Please enter a number between 1 and 4.${NC}"
                ;;
        esac
    done
}

# Function to remove energy management tools
remove_energy_tools() {
    while true; do
        echo -e "\n${CYAN}Energy Management Tools Removal:${NC}"
        echo "1) Remove auto-cpufreq"
        echo "2) Remove TLP"
        echo "3) Go back to the main menu"
        read -p "$(echo -e ${YELLOW}"Select option [1-3]: "${NC})" remove_option

        case $remove_option in
            1)
                uninstall_auto_cpufreq
                ;;
            2)
                uninstall_tlp
                ;;
            3)
                echo -e "${BLUE}Returning to the main menu.${NC}"
                return
                ;;
            *)
                echo -e "${RED}Invalid option. Please enter a number between 1 and 3.${NC}"
                ;;
        esac
    done
}

# Main function to manage energy tools
manage_energy_tools_menu() {
    check_dependencies || return 1
    
    while true; do
        echo -e "\n${CYAN}Energy Management Tools Menu:${NC}"
        echo "1) Manage energy management tools"
        echo "2) Remove energy management tools"
        echo "3) Exit"
        read -p "$(echo -e ${YELLOW}"Select option [1-3]: "${NC})" app_option

        case $app_option in
            1)
                manage_energy_tools
                ;;
            2)
                remove_energy_tools
                ;;
            3)
                echo -e "${BLUE}Exiting the energy management menu.${NC}"
                clear
                return
                ;;
            *)
                echo -e "${RED}Invalid option. Please enter a number between 1 and 3.${NC}"
                ;;
        esac
    done
}

# Function for backup application installation
install_backup_apps() {
    # ANSI color codes
    YELLOW='\033[38;5;178m'
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color

    while true; do
        echo -e "\n${CYAN}Backup Applications Menu:${NC}"
        echo "1) Install backup applications"
        echo "2) Uninstall backup applications"
        echo "3) Exit"
        read -p "$(echo -e ${YELLOW}"Select option [1-3]: "${NC})" main_option

        if [[ "$main_option" =~ ^[1-3]$ ]]; then
            if [ "$main_option" -eq 1 ]; then
                # Installation menu
                echo -e "\n${GREEN}Available Backup Applications:${NC}"
                echo -e "1) Back In Time ${YELLOW}- Simple backup tool for Linux.${NC} $(get_app_status backintime-common backintime-qt)"
                echo -e "2) BorgBackup ${YELLOW}- Deduplicating backup program.${NC} $(get_app_status borgbackup)"
                echo -e "3) Deja Dup ${YELLOW}- Simple backup tool with encryption.${NC} $(get_app_status deja-dup)"
                echo -e "4) Duplicity ${YELLOW}- Encrypted bandwidth-efficient backup.${NC} $(get_app_status duplicity)"
                echo -e "5) Restic ${YELLOW}- Fast, secure, and efficient backup.${NC} $(get_app_status restic)"
                echo -e "6) rsnapshot ${YELLOW}- Filesystem snapshot utility for backups.${NC} $(get_app_status rsnapshot)"
                echo -e "7) Timeshift ${YELLOW}- System restore utility for Linux.${NC} $(get_app_status timeshift)"
                echo -e "8) ${BLUE}None${NC}"
                
                read -p "$(echo -e ${YELLOW}"Select applications to install (space-separated numbers) [1-8]: "${NC})" -a options

                for option in "${options[@]}"; do
                    case $option in
                        1) # Back In Time
                            echo -e "\n${GREEN}Installing Back In Time...${NC}"
                            nala install -y backintime-qt || {
                                echo -e "${RED}Error installing Back In Time${NC}"
                                exit 1
                            }
                            ;;
                        2) # BorgBackup
                            echo -e "\n${GREEN}Installing BorgBackup...${NC}"
                            nala install -y borgbackup || {
                                echo -e "${RED}Error installing BorgBackup${NC}"
                                exit 1
                            }
                            ;;
                        3) # Deja Dup
                            echo -e "\n${GREEN}Installing Deja Dup...${NC}"
                            nala install -y deja-dup || {
                                echo -e "${RED}Error installing Deja Dup${NC}"
                                exit 1
                            }
                            ;;
                        4) # Duplicity
                            echo -e "\n${GREEN}Installing Duplicity...${NC}"
                            nala install -y duplicity || {
                                echo -e "${RED}Error installing Duplicity${NC}"
                                exit 1
                            }
                            ;;
                        5) # Restic
                            echo -e "\n${GREEN}Installing Restic...${NC}"
                            nala install -y restic || {
                                echo -e "${RED}Error installing Restic${NC}"
                                exit 1
                            }
                            ;;
                        6) # rsnapshot
                            echo -e "\n${GREEN}Installing rsnapshot...${NC}"
                            nala install -y rsnapshot || {
                                echo -e "${RED}Error installing rsnapshot${NC}"
                                exit 1
                            }
                            ;;
                        7) # Timeshift
                            echo -e "\n${GREEN}Installing Timeshift...${NC}"
                            nala install -y timeshift || {
                                echo -e "${RED}Error installing Timeshift${NC}"
                                exit 1
                            }
                            ;;
                        8) # None
                            echo -e "\n${BLUE}Skipping application installation${NC}"
                            break
                            ;;
                        *)
                            echo -e "\n${RED}Invalid option: $option${NC}"
                            ;;
                    esac
                done

                echo -e "\n${GREEN}Installation completed successfully!${NC}"
                clear

            elif [ "$main_option" -eq 2 ]; then
                # Uninstallation menu
                echo -e "\n${GREEN}Installed Backup Applications:${NC}"
                echo -e "1) Back In Time ${YELLOW}- Simple backup tool for Linux.${NC} $(get_app_status backintime-common backintime-qt)"
                echo -e "2) BorgBackup ${YELLOW}- Deduplicating backup program.${NC} $(get_app_status borgbackup)"
                echo -e "3) Deja Dup ${YELLOW}- Simple backup tool with encryption.${NC} $(get_app_status deja-dup)"
                echo -e "4) Duplicity ${YELLOW}- Encrypted bandwidth-efficient backup.${NC} $(get_app_status duplicity)"
                echo -e "5) Restic ${YELLOW}- Fast, secure, and efficient backup.${NC} $(get_app_status restic)"
                echo -e "6) rsnapshot ${YELLOW}- Filesystem snapshot utility for backups.${NC} $(get_app_status rsnapshot)"
                echo -e "7) Timeshift ${YELLOW}- System restore utility for Linux.${NC} $(get_app_status timeshift)"
                echo -e "8) ${BLUE}None${NC}"
                
                read -p "$(echo -e ${YELLOW}"Select applications to uninstall (space-separated numbers) [1-8]: "${NC})" -a uninstall_options

                for option in "${uninstall_options[@]}"; do
                    case $option in
                        1) # Back In Time
                            echo -e "\n${GREEN}Uninstalling Back In Time...${NC}"
                            nala remove --purge -y backintime* || echo -e "${YELLOW}Warning: Error uninstalling Back In Time${NC}"
                            ;;
                        2) # BorgBackup
                            echo -e "\n${GREEN}Uninstalling BorgBackup...${NC}"
                            nala remove --purge -y borgbackup || echo -e "${YELLOW}Warning: Error uninstalling BorgBackup${NC}"
                            ;;
                        3) # Deja Dup
                            echo -e "\n${GREEN}Uninstalling Deja Dup...${NC}"
                            nala remove --purge -y deja-dup || echo -e "${YELLOW}Warning: Error uninstalling Deja Dup${NC}"
                            ;;
                        4) # Duplicity
                            echo -e "\n${GREEN}Uninstalling Duplicity...${NC}"
                            nala remove --purge -y duplicity || echo -e "${YELLOW}Warning: Error uninstalling Duplicity${NC}"
                            ;;
                        5) # Restic
                            echo -e "\n${GREEN}Uninstalling Restic...${NC}"
                            nala remove --purge -y restic || echo -e "${YELLOW}Warning: Error uninstalling Restic${NC}"
                            ;;
                        6) # rsnapshot
                            echo -e "\n${GREEN}Uninstalling rsnapshot...${NC}"
                            nala remove --purge -y rsnapshot || echo -e "${YELLOW}Warning: Error uninstalling rsnapshot${NC}"
                            ;;
                        7) # Timeshift
                            echo -e "\n${GREEN}Uninstalling Timeshift...${NC}"
                            nala remove --purge -y timeshift || echo -e "${YELLOW}Warning: Error uninstalling Timeshift${NC}"
                            ;;
                        8) # None
                            echo -e "\n${BLUE}Skipping application uninstallation${NC}"
                            break
                            ;;
                        *)
                            echo -e "\n${RED}Invalid option: $option${NC}"
                            ;;
                    esac
                done

                echo -e "\n${GREEN}Cleaning up orphaned packages...${NC}"
                nala autoremove -y || echo -e "${YELLOW}Warning: Error cleaning orphaned packages${NC}"
                
                echo -e "\n${GREEN}Uninstallation completed successfully!${NC}"
                clear

            elif [ "$main_option" -eq 3 ]; then
                echo -e "\n${BLUE}Exiting backup applications menu...${NC}"
                clear
                return
            else
                echo -e "\n${RED}Invalid option: $main_option${NC}"
            fi
        else
            echo -e "\n${RED}Invalid option. Please enter a number between 1 and 3.${NC}"
        fi
    done
}

manage_pdf_office_apps() {
    # ANSI Color Codes
    CYAN='\033[0;36m'
    YELLOW='\033[1;33m'
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    # Complete language map with consistent names
    declare -A lang_map=(
        [af]="Afrikaans" [am]="Amharic" [ar]="Arabic" [as]="Assamese" [ast]="Asturian"
        [be]="Belarusian" [bg]="Bulgarian" [bn]="Bengali" [bo]="Tibetan" [br]="Breton"
        [brx]="Bodo (India)" [bs]="Bosnian" [ca]="Catalan" [ca_valencia]="Valencian"
        [cs]="Czech" [cy]="Welsh" [da]="Danish" [de]="German" [dgo]="Dogri"
        [dz]="Dzongkha" [el]="Greek" [en]="English" [en_GB]="English (UK)" 
        [en_ZA]="English (South Africa)" [eo]="Esperanto" [es]="Spanish" [et]="Estonian" 
        [eu]="Basque" [fa]="Persian" [fi]="Finnish" [fr]="French" [ga]="Irish"
        [gd]="Scottish Gaelic" [gl]="Galician" [gu]="Gujarati" [he]="Hebrew" [hi]="Hindi"
        [hr]="Croatian" [hu]="Hungarian" [id]="Indonesian" [is]="Icelandic" [it]="Italian"
        [ja]="Japanese" [ka]="Georgian" [kk]="Kazakh" [km]="Khmer" [kmr_Latn]="Kurdish (Latin)"
        [kn]="Kannada" [ko]="Korean" [kok]="Konkani" [ks]="Kashmiri" [ku]="Kurdish"
        [lb]="Luxembourgish" [lo]="Lao" [lt]="Lithuanian" [lv]="Latvian" [mai]="Maithili"
        [mk]="Macedonian" [ml]="Malayalam" [mn]="Mongolian" [mni]="Manipuri" [mr]="Marathi"
        [my]="Burmese" [nb]="Norwegian Bokmål" [ne]="Nepali" [nl]="Dutch" [nn]="Norwegian Nynorsk"
        [nr]="Southern Ndebele" [nso]="Northern Sotho" [oc]="Occitan" [om]="Oromo"
        [or]="Odia" [pa]="Punjabi" [pl]="Polish" [pt]="Portuguese" [pt_BR]="Portuguese (Brazil)"
        [ro]="Romanian" [ru]="Russian" [rw]="Kinyarwanda" [sa]="Sanskrit" [sat]="Santali"
        [sd]="Sindhi" [si]="Sinhala" [sid]="Sidamo" [sk]="Slovak" [sl]="Slovenian"
        [sq]="Albanian" [sr]="Serbian" [sr_Latn]="Serbian (Latin)" [ss]="Swazi" [st]="Southern Sotho"
        [sv]="Swedish" [sw_TZ]="Swahili (Tanzania)" [ta]="Tamil" [te]="Telugu" [tg]="Tajik"
        [th]="Thai" [tn]="Tswana" [tr]="Turkish" [ts]="Tsonga" [tt]="Tatar" [ug]="Uyghur"
        [uk]="Ukrainian" [uz]="Uzbek" [ve]="Venda" [vi]="Vietnamese" [xh]="Xhosa"
        [zh_CN]="Chinese (Simplified)" [zh_TW]="Chinese (Traditional)" [zu]="Zulu"
    )

    # Application list with descriptions and packages
    declare -a apps=(
        "AbiWord|Lightweight word processor|abiword"
        "Atril|Document viewer for PDF and other formats|atril"
        "Calligra Suite|Office suite|calligra calligrasuite"
        "Calibre|E-book manager|calibre"
        "Evince|PDF document viewer|evince"
        "Gnumeric|Spreadsheet program|gnumeric"
        "LibreOffice (Normal)|Office suite with PDF support|libreoffice libreoffice-core"
        "LibreOffice (Backports)|Newer version from backports|libreoffice/bookworm-backports"
        "Pdfarranger|PDF document editor|pdfarranger"
        "Scribus|Desktop publishing software|scribus"
        "Zathura|Minimal PDF viewer with vim-like controls|zathura"
    )

    # Function to check if application is installed (including backports)
    is_installed() {
        for pkg in "$@"; do
            if [[ $pkg == *"/"* ]]; then
                local pkg_name=$(echo "$pkg" | cut -d'/' -f1)
                if dpkg -l | grep -q "^ii  $pkg_name "; then
                    local installed_version=$(apt-cache policy "$pkg_name" | grep "Installed:" | awk '{print $2}')
                    if [[ $installed_version == *"bookworm-backports"* ]]; then
                        return 0
                    fi
                fi
            elif dpkg -l | grep -q "^ii  $pkg "; then
                return 0
            fi
        done
        return 1
    }

    # Function to display application status
    get_app_status() {
        if is_installed "$@"; then
            echo -e "\e[32m✓\e[0m"  # Green check for installed
        else
            echo -e "\e[31m✗\e[0m"  # Red X for not installed
        fi
    }

    # Function to select language packages
    select_language_package() {
        local browser_name=$1
        local backports=$2
        local language_packages=($(apt-cache search ^libreoffice-l10n- | awk '{print $1}' | sort))
        
        if [ ${#language_packages[@]} -eq 0 ]; then
            echo -e "${YELLOW}No language packages available in repositories.${NC}"
            return 1
        fi

        echo -e "\n${YELLOW}=== Available Language Packs for $browser_name ===${NC}"
        
        # Display in 3 columns
        local count=1
        for pkg in "${language_packages[@]}"; do
            local lang_code=$(echo "$pkg" | cut -d'-' -f3-)
            local lang_name="${lang_map[$lang_code]:-$lang_code}"
            printf "${YELLOW}%2d)${NC} %-25s" "$count" "$lang_name"
            [ $((count % 3)) -eq 0 ] && echo ""
            ((count++))
        done
        [ $(( (count-1) % 3 )) -ne 0 ] && echo ""

        echo -e "\n${CYAN}0) Don't install language pack${NC}"
        read -p "$(echo -e ${CYAN}"Select language [0-$((${#language_packages[@]}))]: "${NC})" lang_opt

        if [[ "$lang_opt" == "0" ]]; then
            echo -e "${BLUE}Skipping language pack installation.${NC}"
            return 1
        elif [[ "$lang_opt" =~ ^[0-9]+$ && "$lang_opt" -le "${#language_packages[@]}" ]]; then
            local selected_pkg="${language_packages[$((lang_opt-1))]}"
            echo -e "${GREEN}Selected language: ${lang_map[$(echo "$selected_pkg" | cut -d'-' -f3-)]:-$(echo "$selected_pkg" | cut -d'-' -f3-)}${NC}"
            LANGUAGE_PACK="$selected_pkg"
            return 0
        else
            echo -e "${RED}Invalid selection.${NC}"
            return 1
        fi
    }

    # Main function menu
    while true; do
        echo -e "\n${CYAN}📚 PDF Readers and Office Suites Manager${NC}"
        echo -e "1) ${YELLOW}Install applications${NC}"
        echo -e "2) ${YELLOW}Uninstall applications${NC}"
        echo -e "3) ${YELLOW}Return to main menu${NC}"

        read -p "$(echo -e ${CYAN}"Select option [1-3]: "${NC})" main_choice

        case "$main_choice" in
            1)
                # Installation submenu
                echo -e "\n${GREEN}Available applications:${NC}"
                for i in "${!apps[@]}"; do
                    IFS='|' read -r name desc pkg <<< "${apps[$i]}"
                    echo -e "$(($i+1))) $name ${YELLOW}- $desc${NC} $(get_app_status $pkg)"
                done

                read -p "$(echo -e ${CYAN}"Select applications [1-${#apps[@]}]: "${NC})" -a selections

                for selection in "${selections[@]}"; do
                    if [[ "$selection" =~ ^[0-9]+$ && "$selection" -le "${#apps[@]}" ]]; then
                        IFS='|' read -r name desc pkg <<< "${apps[$((selection-1))]}"
                        
                        if ! is_installed $pkg; then
                            echo -e "\n${GREEN}Installing $name...${NC}"
                            if [[ "$name" == *"LibreOffice (Backports)"* ]]; then
                                echo "deb http://deb.debian.org/debian bookworm-backports main" | sudo tee /etc/apt/sources.list.d/backports.list
                                sudo apt update
                                sudo apt install -y -t bookworm-backports libreoffice && \
                                select_language_package "$name" "true" && \
                                sudo apt install -y -t bookworm-backports "$LANGUAGE_PACK"
                            elif [[ "$name" == *"LibreOffice (Normal)"* ]]; then
                                sudo apt install -y libreoffice libreoffice-gtk3 libreoffice-style-elementary && \
                                select_language_package "$name" "false" && \
                                sudo apt install -y "$LANGUAGE_PACK"
                            else
                                sudo apt install -y $pkg
                            fi
                            echo -e "${GREEN}✓ $name installed successfully${NC}"
                        else
                            echo -e "${YELLOW}ℹ $name is already installed${NC}"
                        fi
                    fi
                done
                ;;
            2)
                # Uninstallation submenu - shows ALL applications but marks installed ones
                echo -e "\n${GREEN}Applications:${NC}"
                for i in "${!apps[@]}"; do
                    IFS='|' read -r name desc pkg <<< "${apps[$i]}"
                    status=$(get_app_status $pkg)
                    echo -e "$(($i+1))) $name ${YELLOW}- $desc${NC} $status"
                done

                read -p "$(echo -e ${CYAN}"Select applications to uninstall [1-${#apps[@]}]: "${NC})" -a selections

                for selection in "${selections[@]}"; do
                    if [[ "$selection" =~ ^[0-9]+$ && "$selection" -le "${#apps[@]}" ]]; then
                        IFS='|' read -r name desc pkg <<< "${apps[$((selection-1))]}"
                        
                        if is_installed $pkg; then
                            echo -e "\n${GREEN}Removing $name...${NC}"
                            if [[ "$name" == *"LibreOffice"* ]]; then
                                sudo apt remove --purge -y libreoffice*
                                [[ "$name" == *"Backports"* ]] && sudo rm /etc/apt/sources.list.d/backports.list
                                sudo apt autoremove -y
                            else
                                sudo apt remove --purge -y $pkg
                            fi
                            echo -e "${GREEN}✓ $name removed successfully${NC}"
                        else
                            echo -e "${YELLOW}ℹ $name is not installed${NC}"
                        fi
                    fi
                done
                ;;
            3)
                echo -e "\n${BLUE}Returning to main menu...${NC}"
                return 0
                ;;
            *)
                echo -e "\n${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
    done
}

# Function for development application installation
install_development_apps() {
    # ANSI color codes
    YELLOW='\033[38;5;178m'
    WHITE='\033[0;37m'
    NC='\033[0m' # No Color

    # Function to get latest Code release
    get_latest_code_release() {
        local api_url="https://api.github.com/repos/qazlinux/code/releases/latest"
        local download_url=$(curl -s $api_url | grep -oP 'browser_download_url": "\K[^"]+amd64\.deb')
        
        if [ -z "$download_url" ]; then
            echo -e "${WHITE}Failed to find download URL${NC}"
            return 1
        fi
        
        echo "$download_url"
    }

    while true; do
        clear
        echo -e "${YELLOW}=== DEVELOPMENT APPLICATIONS MANAGER ===${NC}"
        echo "1) Install development applications"
        echo "2) Uninstall development applications"
        echo "3) Exit"
        read -p "Option [1-3]: " main_option

        if [[ "$main_option" =~ ^[1-3]$ ]]; then
            if [ "$main_option" -eq 1 ]; then
                clear
                echo "Select the development applications you want to install (enter numbers separated by spaces):"
                echo -e "1) Bluefish ${YELLOW}- GTK HTML/Code editor (GPL)${NC} $(get_app_status bluefish)"
                echo -e "2) Code ${YELLOW}- Lightweight code editor (MIT)${NC} $(get_app_status code)"
                echo -e "3) Emacs ${YELLOW}- Extensible text editor (GPLv3)${NC} $(get_app_status emacs)"
                echo -e "4) Gedit ${YELLOW}- GNOME text editor (GPL)${NC} $(get_app_status gedit)"
                echo -e "5) Geany ${YELLOW}- Lightweight IDE (GPLv2)${NC} $(get_app_status geany)"
                echo -e "6) Mousepad ${YELLOW}- Xfce text editor (BSD)${NC} $(get_app_status mousepad)"
                echo -e "7) NetBeans ${YELLOW}- Java IDE (Apache 2.0)${NC} $(get_app_status netbeans)"
                echo "8) Install All"
                echo "9) None"
                read -p "Option [1-9]: " -a options

                # Install the selected development applications
                for option in "${options[@]}"; do
                    case $option in
                        1) # Bluefish
                            echo -e "${WHITE}Installing Bluefish...${NC}"
                            nala install -y bluefish || echo -e "${WHITE}Error installing Bluefish${NC}"
                            ;;
                        2) # Code
                            echo -e "${WHITE}Installing Code...${NC}"
                            download_url=$(get_latest_code_release)
                            if [ $? -eq 0 ]; then
                                temp_deb="/tmp/code_$(date +%s).deb"
                                wget -q "$download_url" -O "$temp_deb" || { echo -e "${WHITE}Failed to download Code${NC}"; continue; }
                                sudo dpkg -i "$temp_deb" || sudo apt-get install -f -y
                                rm -f "$temp_deb"
                            else
                                echo -e "${WHITE}Skipping Code installation${NC}"
                            fi
                            ;;
                        3) # Emacs
                            echo -e "${WHITE}Installing Emacs...${NC}"
                            nala install -y emacs || echo -e "${WHITE}Error installing Emacs${NC}"
                            ;;
                        4) # Gedit
                            echo -e "${WHITE}Installing Gedit...${NC}"
                            nala install -y gedit || echo -e "${WHITE}Error installing Gedit${NC}"
                            ;;
                        5) # Geany
                            echo -e "${WHITE}Installing Geany...${NC}"
                            nala install -y geany || echo -e "${WHITE}Error installing Geany${NC}"
                            ;;
                        6) # Mousepad
                            echo -e "${WHITE}Installing Mousepad...${NC}"
                            nala install -y mousepad || echo -e "${WHITE}Error installing Mousepad${NC}"
                            ;;
                        7) # NetBeans
                            echo -e "${WHITE}Installing NetBeans...${NC}"
                            temp_dir=$(mktemp -d)
                            cd "$temp_dir"
                            LATEST_VERSION=$(curl -s https://dlcdn.apache.org/netbeans/netbeans-installers/ | grep -oP '(?<=href=")[0-9]+/' | sort -V | tail -n 1 | tr -d '/')
                            wget "https://dlcdn.apache.org/netbeans/netbeans-installers/${LATEST_VERSION}/apache-netbeans_${LATEST_VERSION}-1_all.deb" || { echo -e "${WHITE}Error downloading NetBeans${NC}"; continue; }
                            sudo dpkg -i "apache-netbeans_${LATEST_VERSION}-1_all.deb" || sudo apt-get install -f -y
                            cd -
                            rm -rf "$temp_dir"
                            ;;
                        8) # Install All
                            echo -e "${WHITE}Installing all development applications...${NC}"
                            nala install -y bluefish emacs gedit geany mousepad || echo -e "${WHITE}Some packages failed to install${NC}"
                            
                            # Install Code
                            download_url=$(get_latest_code_release)
                            if [ $? -eq 0 ]; then
                                temp_deb="/tmp/code_$(date +%s).deb"
                                wget -q "$download_url" -O "$temp_deb" || echo -e "${WHITE}Failed to download Code${NC}"
                                sudo dpkg -i "$temp_deb" || sudo apt-get install -f -y
                                rm -f "$temp_deb"
                            fi
                            
                            # Install NetBeans
                            temp_dir=$(mktemp -d)
                            cd "$temp_dir"
                            LATEST_VERSION=$(curl -s https://dlcdn.apache.org/netbeans/netbeans-installers/ | grep -oP '(?<=href=")[0-9]+/' | sort -V | tail -n 1 | tr -d '/')
                            wget "https://dlcdn.apache.org/netbeans/netbeans-installers/${LATEST_VERSION}/apache-netbeans_${LATEST_VERSION}-1_all.deb" || echo -e "${WHITE}Error downloading NetBeans${NC}"
                            sudo dpkg -i "apache-netbeans_${LATEST_VERSION}-1_all.deb" || sudo apt-get install -f -y
                            cd -
                            rm -rf "$temp_dir"
                            ;;
                        9) # None
                            echo "No development application will be installed."
                            ;;
                        *) # Invalid option
                            echo "Invalid option: $option"
                            ;;
                    esac
                done

                echo -e "${WHITE}Installation completed. Press Enter to continue...${NC}"
                read

            elif [ "$main_option" -eq 2 ]; then
                clear
                echo "Select the development applications you want to uninstall (enter numbers separated by spaces):"
                echo -e "1) Bluefish ${YELLOW}- GTK HTML/Code editor${NC} $(get_app_status bluefish)"
                echo -e "2) Code ${YELLOW}- Lightweight code editor${NC} $(get_app_status code)"
                echo -e "3) Emacs ${YELLOW}- Extensible text editor${NC} $(get_app_status emacs)"
                echo -e "4) Gedit ${YELLOW}- GNOME text editor${NC} $(get_app_status gedit)"
                echo -e "5) Geany ${YELLOW}- Lightweight IDE${NC} $(get_app_status geany)"
                echo -e "6) Mousepad ${YELLOW}- Xfce text editor${NC} $(get_app_status mousepad)"
                echo -e "7) NetBeans ${YELLOW}- Java IDE${NC} $(get_app_status netbeans)"
                echo "8) Uninstall All"
                echo "9) None"
                read -p "Option [1-9]: " -a uninstall_options

                # Uninstall the selected development applications
                for option in "${uninstall_options[@]}"; do
                    case $option in
                        1) nala remove --purge -y bluefish || echo -e "${WHITE}Error uninstalling Bluefish${NC}" ;;
                        2) nala remove --purge -y code || echo -e "${WHITE}Error uninstalling Code${NC}" ;;
                        3) nala remove --purge -y emacs || echo -e "${WHITE}Error uninstalling Emacs${NC}" ;;
                        4) nala remove --purge -y gedit || echo -e "${WHITE}Error uninstalling Gedit${NC}" ;;
                        5) nala remove --purge -y geany || echo -e "${WHITE}Error uninstalling Geany${NC}" ;;
                        6) nala remove --purge -y mousepad || echo -e "${WHITE}Error uninstalling Mousepad${NC}" ;;
                        7) nala remove --purge -y netbeans || echo -e "${WHITE}Error uninstalling NetBeans${NC}" ;;
                        8)
                            echo -e "${WHITE}Uninstalling all development applications...${NC}"
                            nala remove --purge -y bluefish code emacs gedit geany mousepad netbeans
                            nala autoremove -y
                            ;;
                        9) echo "No development application will be uninstalled." ;;
                        *) echo "Invalid option: $option" ;;
                    esac
                done

                echo -e "${WHITE}Cleaning orphaned packages...${NC}"
                nala autoremove -y
                echo -e "${WHITE}Uninstallation completed. Press Enter to continue...${NC}"
                read

            elif [ "$main_option" -eq 3 ]; then
                clear
                return 0
            fi
        else
            echo -e "${WHITE}Invalid option. Please enter a number between 1 and 3.${NC}"
            sleep 2
        fi
    done
}

# Function for terminal application installation
install_terminal_apps() {
    # ANSI color codes
    YELLOW='\033[38;5;178m'
    NC='\033[0m' # No Color

    while true; do
        echo "Select an option:"
        echo "1) Install terminal applications"
        echo "2) Uninstall terminal applications"
        echo "3) Exit"
        read -p "Option [1-3]: " main_option

        if [[ "$main_option" =~ ^[1-3]$ ]]; then
            if [ "$main_option" -eq 1 ]; then
                echo "Select the terminal applications you want to install (enter the corresponding numbers, separated by spaces):"
                echo -e "1) atop ${YELLOW} - Advanced system and process monitor.${NC} $(get_app_status atop)"
                echo -e "2) bmon ${YELLOW} - Bandwidth monitor and rate estimator.${NC} $(get_app_status bmon)"
                echo -e "3) cmatrix ${YELLOW} - The Matrix in your terminal.${NC} $(get_app_status cmatrix)"
                echo -e "4) DUF ${YELLOW} - Disk Usage/Free Utility.${NC} $(get_app_status duf)"
                echo -e "5) fastfetch ${YELLOW} - Fast and simple system information tool.${NC} $(get_app_status fastfetch)"
                echo -e "6) glances ${YELLOW} - Cross-platform monitoring tool.${NC} $(get_app_status glances)"
                echo -e "7) Htop ${YELLOW} - Interactive process viewer.${NC} $(get_app_status htop)"
                echo -e "8) neofetch ${YELLOW} - Display system information in terminal.${NC} $(get_app_status neofetch)"
                echo -e "9) nload ${YELLOW} - Network traffic and bandwidth monitor.${NC} $(get_app_status nload)"
                echo -e "10) iftop ${YELLOW} - Display bandwidth usage on an interface.${NC} $(get_app_status iftop)"
                echo -e "11) nmon ${YELLOW} - Performance monitoring tool.${NC} $(get_app_status nmon)"
                echo -e "12) pipes-sh ${YELLOW} - Animated pipes terminal screensaver.${NC} $(get_app_status pipes-sh)"
                echo -e "13) tcpdump ${YELLOW} - Network packet analyzer.${NC} $(get_app_status tcpdump)"
                echo -e "14) tty-clock ${YELLOW} - Simple terminal clock.${NC} $(get_app_status tty-clock)"
                echo -e "15) vnstat ${YELLOW} - Network traffic monitor.${NC} $(get_app_status vnstat)"
                echo -e "16) screenfetch ${YELLOW} - Display system information with ASCII art.${NC} $(get_app_status screenfetch)"
                echo "17) Install All"
                echo "18) None"
                read -p "Option [1-18]: " -a options

                # Install the selected terminal applications
                for option in "${options[@]}"; do
                    case $option in
                        1) # atop
                            echo "Installing atop..."
                            nala install -y atop || { echo "Error installing atop"; exit 1; }
                            ;;
                        2) # bmon
                            echo "Installing bmon..."
                            nala install -y bmon || { echo "Error installing bmon"; exit 1; }
                            ;;
                        3) # cmatrix
                            echo "Installing cmatrix..."
                            nala install -y cmatrix || { echo "Error installing cmatrix"; exit 1; }
                            ;;
                        4) # DUF
                            echo "Installing DUF..."
                            nala install -y duf || { echo "Error installing DUF"; exit 1; }
                            ;;
                        5) #Fasfetch
# Obtener la arquitectura del sistema
ARCH=$(dpkg --print-architecture)
echo "Arquitectura del sistema: $ARCH"

# Obtener la última versión de Fastfetch
latest_release=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest)

# Verificar si la llamada a la API fue exitosa
if [ $? -ne 0 ]; then
    echo "Error al obtener la última versión de Fastfetch."
    exit 1
fi

# Extraer la URL del archivo .deb correspondiente a la arquitectura
deb_url=$(echo "$latest_release" | jq -r ".assets[] | select(.name | test(\"$ARCH\")) | select(.name | endswith(\".deb\")) | .browser_download_url" | head -n 1)

# Verificar si se encontró la URL
if [ -z "$deb_url" ]; then
    echo "No se encontró un paquete .deb para la arquitectura $ARCH."
    exit 1
fi

# Descargar el archivo .deb
echo "Descargando $deb_url..."
wget -q --show-progress "$deb_url" -O fastfetch_latest.deb

# Verificar si la descarga fue exitosa
if [ ! -f fastfetch_latest.deb ]; then
    echo "Error: No se pudo descargar el archivo .deb."
    exit 1
fi

# Instalar el paquete
echo "Instalando fastfetch..."
sudo dpkg -i fastfetch_latest.deb

# Resolver dependencias si es necesario
sudo apt-get install -f

# Limpiar el archivo descargado
rm fastfetch_latest.deb

echo "Fastfetch se ha instalado correctamente."
;;
                        6) # glances
                            echo "Installing glances..."
                            nala install -y glances || { echo "Error installing glances"; exit 1; }
                            ;;
                        7) # Htop
                            echo "Installing Htop..."
                            nala install -y htop || { echo "Error installing Htop"; exit 1; }
                            ;;
                        8) # neofetch
                            echo "Installing neofetch..."
                            nala install -y neofetch || { echo "Error installing neofetch"; exit 1; }
                            ;;
                        9) # nload
                            echo "Installing nload..."
                            nala install -y nload || { echo "Error installing nload"; exit 1; }
                            ;;
                        10) # iftop
                            echo "Installing iftop..."
                            nala install -y iftop || { echo "Error installing iftop"; exit 1; }
                            ;;
                        11) # nmon
                            echo "Installing nmon..."
                            nala install -y nmon || { echo "Error installing nmon"; exit 1; }
                            ;;
                        12) # pipes-sh
                            echo "Installing pipes-sh..."
                            nala install -y pipes-sh || { echo "Error installing pipes-sh"; exit 1; }
                            ;;
                        13) # tcpdump
                            echo "Installing tcpdump..."
                            nala install -y tcpdump || { echo "Error installing tcpdump"; exit 1; }
                            ;;
                        14) # tty-clock
                            echo "Installing tty-clock..."
                            nala install -y tty-clock || { echo "Error installing tty-clock"; exit 1; }
                            ;;
                        15) # vnstat
                            echo "Installing vnstat..."
                            nala install -y vnstat || { echo "Error installing vnstat"; exit 1; }
                            ;;
                        16) # screenfetch
                            echo "Installing screenfetch..."
                            nala install -y screenfetch || { echo "Error installing screenfetch"; exit 1; }
                            ;;
                        17) # Install All
                            echo "Installing all terminal applications..."
                            nala install -y atop bmon cmatrix duf fastfetch glances htop neofetch nload iftop nmon pipes-sh tcpdump tty-clock vnstat screenfetch || { echo "Error installing all applications"; exit 1; }
                            ;;
                        18) # None
                            echo "No terminal application will be installed."
                            ;;
                        *) # Invalid option
                            echo "Invalid option: $option"
                            ;;
                    esac
                done

                echo "Installation completed. Enjoy your terminal applications!"

            elif [ "$main_option" -eq 2 ]; then
                echo "Select the terminal applications you want to uninstall (enter the corresponding numbers, separated by spaces):"
                echo -e "1) atop ${YELLOW} - Advanced system and process monitor.${NC} $(get_app_status atop)"
                echo -e "2) bmon ${YELLOW} - Bandwidth monitor and rate estimator.${NC} $(get_app_status bmon)"
                echo -e "3) cmatrix ${YELLOW} - The Matrix in your terminal.${NC} $(get_app_status cmatrix)"
                echo -e "4) DUF ${YELLOW} - Disk Usage/Free Utility.${NC} $(get_app_status duf)"
                echo -e "5) fastfetch ${YELLOW} - Fast and simple system information tool.${NC} $(get_app_status fastfetch)"
                echo -e "6) glances ${YELLOW} - Cross-platform monitoring tool.${NC} $(get_app_status glances)"
                echo -e "7) Htop ${YELLOW} - Interactive process viewer.${NC} $(get_app_status htop)"
                echo -e "8) neofetch ${YELLOW} - Display system information in terminal.${NC} $(get_app_status neofetch)"
                echo -e "9) nload ${YELLOW} - Network traffic and bandwidth monitor.${NC} $(get_app_status nload)"
                echo -e "10) iftop ${YELLOW} - Display bandwidth usage on an interface.${NC} $(get_app_status iftop)"
                echo -e "11) nmon ${YELLOW} - Performance monitoring tool.${NC} $(get_app_status nmon)"
                echo -e "12) pipes-sh ${YELLOW} - Animated pipes terminal screensaver.${NC} $(get_app_status pipes-sh)"
                echo -e "13) tcpdump ${YELLOW} - Network packet analyzer.${NC} $(get_app_status tcpdump)"
                echo -e "14) tty-clock ${YELLOW} - Simple terminal clock.${NC} $(get_app_status tty-clock)"
                echo -e "15) vnstat ${YELLOW} - Network traffic monitor.${NC} $(get_app_status vnstat)"
                echo -e "16) screenfetch ${YELLOW} - Display system information with ASCII art.${NC} $(get_app_status screenfetch)"
                echo "17) Uninstall All"
                echo "18) None"
                read -p "Option [1-18]: " -a uninstall_options

                # Uninstall the selected terminal applications
                for option in "${uninstall_options[@]}"; do
                    case $option in
                        1) # atop
                            nala remove --purge -y atop || { echo "Error uninstalling atop"; }
                            ;;
                        2) # bmon
                            nala remove --purge -y bmon || { echo "Error uninstalling bmon"; }
                            ;;
                        3) # cmatrix
                            nala remove --purge -y cmatrix || { echo "Error uninstalling cmatrix"; }
                            ;;
                        4) # DUF
                            nala remove --purge -y duf || { echo "Error uninstalling DUF"; }
                            ;;
                        5) # fastfetch
                            nala remove --purge -y fastfetch || { echo "Error uninstalling fastfetch"; }
                            ;;
                        6) # glances
                            nala remove --purge -y glances || { echo "Error uninstalling glances"; }
                            ;;
                        7) # Htop
                            nala remove --purge -y htop || { echo "Error uninstalling Htop"; }
                            ;;
                        8) # neofetch
                            nala remove --purge -y neofetch || { echo "Error uninstalling neofetch"; }
                            ;;
                        9) # nload
                            nala remove --purge -y nload || { echo "Error uninstalling nload"; }
                            ;;
                        10) # iftop
                            nala remove --purge -y iftop || { echo "Error uninstalling iftop"; }
                            ;;
                        11) # nmon
                            nala remove --purge -y nmon || { echo "Error uninstalling nmon"; }
                            ;;
                        12) # pipes-sh
                            nala remove --purge -y pipes-sh || { echo "Error uninstalling pipes-sh"; }
                            ;;
                        13) # tcpdump
                            nala remove --purge -y tcpdump || { echo "Error uninstalling tcpdump"; }
                            ;;
                        14) # tcpdump
                            nala remove --purge -y tty-clock || { echo "Error uninstalling tty-clock"; }
                            ;;
                        15) # vnstat
                            nala remove --purge -y vnstat || { echo "Error uninstalling vnstat"; }
                            ;;
                        16) # screenfetch
                            nala remove --purge -y screenfetch || { echo "Error uninstalling screenfetch"; }
                            ;;
                        17) # Uninstall All
                            echo "Uninstalling all terminal applications..."
                            nala remove --purge -y atop bmon cmatrix duf fastfetch glances htop neofetch nload iftop nmon pipes-sh tcpdump tty-clock vnstat screenfetch || { echo "Error uninstalling all applications"; }
                            ;;
                        18) # None
                            echo "No terminal application will be uninstalled."
                            ;;
                        *) # Invalid option
                            echo "Invalid option: $option"
                            ;;
                    esac
                done

                # Clean orphaned packages
                echo "Cleaning orphaned packages..."
                nala autoremove -y

                # Optionally, remove repositories related to uninstalled applications
                echo "Removing unnecessary repositories..."
                echo "Uninstallation completed."

            elif [ "$main_option" -eq 3 ]; then
                echo "Exiting the terminal application menu."
                return  # Esto saldrá de la función, pero no del script completo
            else
                echo "Invalid option: $main_option"
            fi  # Fin del bloque if
        else
            echo "Invalid option. Please enter a number between 1 and 3."
        fi  # Fin del bloque if
    done
    sudo clear
}

# Function for system tool application installation
install_system_tools() {
    # ANSI color codes
    YELLOW='\033[38;5;178m'  # Only for application descriptions
    WHITE='\033[0;37m'       # For status indicators and errors
    NC='\033[0m'             # No Color

    while true; do
        clear
        echo "=== SYSTEM TOOLS MENU ==="
        echo "Select an option:"
        echo "1) Install system tool applications"
        echo "2) Uninstall system tool applications"
        echo "3) Return to main menu"
        read -p "Option [1-3]: " main_option

        if [[ "$main_option" =~ ^[1-3]$ ]]; then
            if [ "$main_option" -eq 1 ]; then
                clear
                echo "=== INSTALL TOOLS ==="
                echo "Select applications to install (enter numbers, separated by spaces):"
                echo -e "1) BleachBit ${YELLOW}- Clean up your system.${NC} $(get_app_status bleachbit | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')"
                echo -e "2) GNOME Disks ${YELLOW}- Disk utility for managing disks.${NC} $(get_app_status gnome-disk-utility | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')"
                echo -e "3) GParted ${YELLOW}- Partition editor.${NC} $(get_app_status gparted | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')"
                echo -e "4) Hardinfo ${YELLOW}- System information tool.${NC} $(get_app_status hardinfo* | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')"
                echo -e "5) Stacer ${YELLOW}- System optimizer.${NC} $(get_app_status stacer | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')"
                echo -e "6) Synaptic ${YELLOW}- Graphical package manager.${NC} $(get_app_status synaptic | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')"
                echo -e "7) Splitcat ${YELLOW}- Split and concatenate files.${NC} $(get_app_status splitcat | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')"
                echo "8) Install All"
                echo "9) None"
                read -p "Option [1-9]: " -a options

                for option in "${options[@]}"; do
                    case $option in
                        1) # BleachBit
                            echo -e "${WHITE}Installing BleachBit...${NC}"
                            nala install -y bleachbit || { echo -e "${WHITE}Installation failed${NC}"; exit 1; }
                            ;;
                        2) # GNOME Disks
                            echo -e "${WHITE}Installing GNOME Disks...${NC}"
                            nala install -y gnome-disk-utility || { echo -e "${WHITE}Installation failed${NC}"; exit 1; }
                            ;;
                        3) # GParted
                            echo -e "${WHITE}Installing GParted...${NC}"
                            nala install -y gparted || { echo -e "${WHITE}Installation failed${NC}"; exit 1; }
                            ;;
                        4) # Hardinfo
                            echo -e "${WHITE}Installing Hardinfo...${NC}"
                            nala install -y hardinfo || { echo -e "${WHITE}Installation failed${NC}"; exit 1; }
                            ;;
                        5) # Stacer
                            echo -e "${WHITE}Installing Stacer...${NC}"
                            nala install -y stacer || { echo -e "${WHITE}Installation failed${NC}"; exit 1; }
                            ;;
                        6) # Synaptic
                            echo -e "${WHITE}Installing Synaptic...${NC}"
                            nala install -y synaptic || { echo -e "${WHITE}Installation failed${NC}"; exit 1; }
                            ;;
                        7) # splitcat
                            echo -e "${WHITE}Installing splitcat...${NC}"
                            sudo nala install -y gir1.2-ayatanaappindicator3-0.1
                            wget http://ftp.es.debian.org/debian/pool/main/liba/libappindicator/gir1.2-appindicator3-0.1_0.4.92-7_amd64.deb
                            sudo dpkg -i gir1.2-appindicator3-0.1_0.4.92-7_amd64.deb
                            wget https://github.com/vogonwann/splitcat/releases/download/v0.1.16/splitcat-linux-x64.deb || { echo -e "${WHITE}Download failed${NC}"; exit 1; }
                            sudo dpkg -i splitcat-linux-x64.deb
                            sudo rm -r splitcat-linux-x64.deb
                            ;;
                        8) # Install All
                            echo -e "${WHITE}Installing all applications...${NC}"
                            nala install -y bleachbit gnome-disk-utility gparted hardinfo stacer synaptic 
                            wget https://github.com/vogonwann/splitcat/releases/download/v0.1.16/splitcat-linux-x64.deb 
                            sudo dpkg -i splitcat-linux-x64.deb
                            sudo rm -r splitcat-linux-x64.deb
                            ;;
                        9) # None
                            echo "Skipping installation."
                            ;;
                        *) 
                            echo "Invalid option: $option"
                            ;;
                    esac
                done

                echo "Installation completed."
                read -p "Press [Enter] to continue..."

            elif [ "$main_option" -eq 2 ]; then
                clear
                echo "=== UNINSTALL TOOLS ==="
                echo "Select applications to uninstall (enter numbers, separated by spaces):"
                echo -e "1) BleachBit ${YELLOW}- Clean up your system.${NC} $(get_app_status bleachbit | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')"
                echo -e "2) GNOME Disks ${YELLOW}- Disk utility for managing disks.${NC} $(get_app_status gnome-disk-utility | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')"
                echo -e "3) GParted ${YELLOW}- Partition editor.${NC} $(get_app_status gparted | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')"
                echo -e "4) Hardinfo ${YELLOW}- System information tool.${NC} $(get_app_status hardinfo | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')"
                echo -e "5) Stacer ${YELLOW}- System optimizer.${NC} $(get_app_status stacer | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')"
                echo -e "6) Synaptic ${YELLOW}- Graphical package manager.${NC} $(get_app_status synaptic | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')"
                echo -e "7) Splitcat ${YELLOW}- Split and concatenate files.${NC} $(get_app_status splitcat | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')"
                echo "8) Uninstall All"
                echo "9) None"
                read -p "Option [1-9]: " -a uninstall_options

                for option in "${uninstall_options[@]}"; do
                    case $option in
                        1) nala remove --purge -y bleachbit || { echo -e "${WHITE}Uninstall failed${NC}"; } ;;
                        2) nala remove --purge -y gnome-disk-utility || { echo -e "${WHITE}Uninstall failed${NC}"; } ;;
                        3) nala remove --purge -y gparted || { echo -e "${WHITE}Uninstall failed${NC}"; } ;;
                        4) nala remove --purge -y hardinfo || { echo -e "${WHITE}Uninstall failed${NC}"; } ;;
                        5) nala remove --purge -y stacer || { echo -e "${WHITE}Uninstall failed${NC}"; } ;;
                        6) nala remove --purge -y synaptic || { echo -e "${WHITE}Uninstall failed${NC}"; } ;;
                        7) nala remove --purge -y splitcat || { echo -e "${WHITE}Uninstall failed${NC}"; } ;;
                        8) 
                            echo -e "${WHITE}Uninstalling all applications...${NC}"
                            nala remove --purge -y bleachbit gnome-disk-utility gparted hardinfo stacer synaptic splitcat || { echo -e "${WHITE}Uninstall failed${NC}"; }
                            ;;
                        9) echo "Skipping uninstallation." ;;
                        *) echo "Invalid option: $option" ;;
                    esac
                done

                echo -e "${WHITE}Cleaning orphaned packages...${NC}"
                nala autoremove -y
                echo "Cleanup completed."
                read -p "Press [Enter] to continue..."

            elif [ "$main_option" -eq 3 ]; then
                clear
                echo "Returning to main menu..."
                return 0
            fi
        else
            echo "Invalid option. Please enter 1-3."
            sleep 2
        fi
    done
}

# Function for privacy and security application installation
install_privacy_security_apps() {
    # ANSI color codes
    YELLOW='\033[38;5;178m'
    NC='\033[0m' # No Color

    while true; do
        echo "Select an option:"
        echo "1) Install privacy and security applications"
        echo "2) Uninstall privacy and security applications"
        echo "3) Exit"
        read -p "Option [1-3]: " main_option

        if [[ "$main_option" =~ ^[1-3]$ ]]; then
            if [ "$main_option" -eq 1 ]; then
                echo "Select the privacy and security applications you want to install (enter the corresponding numbers, separated by spaces):"
                echo -e "1) Aircrack-ng ${YELLOW} - Wireless security auditing tool.${NC} $(get_app_status aircrack-ng)"
                echo -e "2) BeEF ${YELLOW} - Browser Exploitation Framework.${NC} $(get_app_status beef)"
                echo -e "3) BleachBit ${YELLOW} - Privacy and disk space cleaner.${NC} $(get_app_status bleachbit)"
                echo -e "4) Cewl ${YELLOW} - Custom word list generator.${NC} $(get_app_status cewl)"
                echo -e "5) ClamTk ${YELLOW} - GUI for ClamAV antivirus.${NC} $(get_app_status clamtk)"
                echo -e "6) Cryptsetup ${YELLOW} - Disk encryption tool.${NC} $(get_app_status cryptsetup)"
                echo -e "7) Ettercap ${YELLOW} - Network sniffer/interceptor/logger.${NC} $(get_app_status ettercap-graphical)"
                echo -e "8) Firejail ${YELLOW} - Sandbox program for Linux.${NC} $(get_app_status firejail)"
                echo -e "9) Gobuster ${YELLOW} - Directory/file brute-forcer.${NC} $(get_app_status gobuster)"
                echo -e "10) GnuPG ${YELLOW} - Encryption and signing tool.${NC} $(get_app_status gnupg)"
                echo -e "11) Gufw Firewall ${YELLOW} - GUI for UFW firewall.${NC} $(get_app_status gufw)"
                echo -e "12) Hydra ${YELLOW} - Password cracking tool.${NC} $(get_app_status hydra)"
                echo -e "13) John the Ripper ${YELLOW} - Password cracking software.${NC} $(get_app_status john)"
                echo -e "14) KeePassXC ${YELLOW} - Password manager.${NC} $(get_app_status keepassxc)"
                echo -e "15) Kleopatra ${YELLOW} - Certificate manager and GUI for GnuPG.${NC} $(get_app_status kleopatra)"
                echo -e "16) Kismet ${YELLOW} - Wireless network detector.${NC} $(get_app_status kismet)"
                echo -e "17) Lynis ${YELLOW} - Security auditing tool.${NC} $(get_app_status lynis)"
                echo -e "18) Metadata Cleaner ${YELLOW} - Remove metadata from files.${NC} $(get_app_status metadata-cleaner)"
                echo -e "19) Nmap ${YELLOW} - Network exploration tool.${NC} $(get_app_status nmap)"
                echo -e "20) Nikto ${YELLOW} - Web server scanner.${NC} $(get_app_status nikto)"
                echo -e "21) OpenVPN ${YELLOW} - VPN solution.${NC} $(get_app_status openvpn)"
                echo -e "22) OnionShare ${YELLOW} - Share files securely and anonymously.${NC} $(get_app_status onionshare)"
                echo -e "23) Riseup VPN ${YELLOW} - Privacy-focused VPN service.${NC} $(get_app_status riseup-vpn)"
                echo -e "24) rkhunter ${YELLOW} - Rootkit scanner.${NC} $(get_app_status rkhunter)"
                echo -e "25) Recon-ng ${YELLOW} - Web reconnaissance framework.${NC} $(get_app_status recon-ng)"
                echo -e "26) Social-Engineer Toolkit (SET) ${YELLOW} - Penetration testing framework for social engineering.${NC} $(get_app_status set)"
                echo -e "27) Suricata ${YELLOW} - Network threat detection engine.${NC} $(get_app_status suricata)"
                echo -e "28) Syncthing ${YELLOW} - Continuous file synchronization.${NC} $(get_app_status syncthing)"
                echo -e "29) Tailscale ${YELLOW} - Zero-config VPN service.${NC} $(get_app_status tailscale)"
                echo -e "30) Tutanota ${YELLOW} - Encrypted email service.${NC} $(get_app_status tutanota)"
                echo -e "31) VeraCrypt ${YELLOW} - Disk encryption software.${NC} $(get_app_status veracrypt)"
                echo -e "32) Sirikali ${YELLOW} - GUI for managing encrypted volumes.${NC} $(get_app_status sirikali)"
                echo -e "33) Wifite ${YELLOW} - Automated wireless attack tool.${NC} $(get_app_status wifite)"
                echo -e "34) WireGuard ${YELLOW} - Modern VPN protocol.${NC} $(get_app_status wireguard)"
                echo -e "35) Wireshark ${YELLOW} - Network protocol analyzer.${NC} $(get_app_status wireshark)"
                echo -e "36) sqlmap ${YELLOW} - Automatic SQL injection tool.${NC} $(get_app_status sqlmap)"
                echo "37) None"
                read -p "Option [1-37]: " -a options

                # Install the selected privacy and security applications
                for option in "${options[@]}"; do
                    case $option in
                        1) # Aircrack-ng
                            echo "Installing Aircrack-ng..."
                            nala install -y aircrack-ng || { echo "Error installing Aircrack-ng"; exit 1; }
                            ;;
                        2) # BeEF
                            echo "Installing BeEF..."
                            nala install -y beef || { echo "Error installing BeEF"; exit 1; }
                            ;;
                        3) # BleachBit
                            echo "Installing BleachBit..."
                            nala install -y bleachbit || { echo "Error installing BleachBit"; exit 1; }
                            ;;
                        4) # Cewl
                            echo "Installing Cewl..."
                            nala install -y cewl || { echo "Error installing Cewl"; exit 1; }
                            ;;
                        5) # ClamTk
                            echo "Installing ClamTk..."
                            nala install -y clamtk || { echo "Error installing ClamTk"; exit 1; }
                            ;;
                        6) # Cryptsetup
                            echo "Installing Cryptsetup..."
                            nala install -y cryptsetup || { echo "Error installing Cryptsetup"; exit 1; }
                            ;;
                        7) # Ettercap
                            echo "Installing Ettercap..."
                            nala install -y ettercap-graphical|| { echo "Error installing Ettercap"; exit 1; }
                            ;;
                        8) # Firejail
                            echo "Installing Firejail..."
                            nala install -y firejail || { echo "Error installing Firejail"; exit 1; }
                            ;;
                        9) # Gobuster
                            echo "Installing Gobuster..."
                            nala install -y gobuster || { echo "Error installing Gobuster"; exit 1; }
                            ;;
                        10) # GnuPG
                            echo "Installing GnuPG..."
                            nala install -y gnupg || { echo "Error installing GnuPG"; exit 1; }
                            ;;
                        11) # Gufw Firewall
                            echo "Installing Gufw Firewall..."
                            nala install -y gufw || { echo "Error installing Gufw Firewall"; exit 1; }
                            ;;
                        12) # Hydra
                            echo "Installing Hydra..."
                            nala install -y hydra || { echo "Error installing Hydra"; exit 1; }
                            ;;
                        13) # John the Ripper
                            echo "Installing John the Ripper..."
                            nala install -y john || { echo "Error installing John the Ripper"; exit 1; }
                            ;;
                        14) # KeePassXC
                            echo "Installing KeePassXC..."
                            nala install -y keepassxc || { echo "Error installing KeePassXC"; exit 1; }
                            ;;
                        15) # Kleopatra
                            echo "Installing Kleopatra..."
                            nala install -y kleopatra || { echo "Error installing Kleopatra"; exit 1; }
                            ;;
                        16) # Kismet
                            echo "Installing Kismet..."
                            wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key --quiet | gpg --dearmor | sudo tee /usr/share/keyrings/kismet-archive-keyring.gpg >/dev/null
                            echo 'deb [signed-by=/usr/share/keyrings/kismet-archive-keyring.gpg] https://www.kismetwireless.net/repos/apt/release/bookworm bookworm main' | sudo tee /etc/apt/sources.list.d/kismet.list >/dev/null
                            sudo nala update
                            sudo nala install kismet || { echo "Error installing Kismet"; exit 1; }
                            ;;
                        17) # Lynis
                            echo "Installing Lynis..."
                            nala install -y lynis || { echo "Error installing Lynis"; exit 1; }
                            ;;
                        18) # Metadata Cleaner
                            echo "Installing Metadata Cleaner..."
                            nala install -y metadata-cleaner || { echo "Error installing Metadata Cleaner"; exit 1; }
                            ;;
                        19) # Nmap
                            echo "Installing Nmap..."
                            nala install -y nmap || { echo "Error installing Nmap"; exit 1; }
                            ;;
                        20) # Nikto
                            echo "Installing Nikto..."
                            nala install -y nikto || { echo "Error installing Nikto"; exit 1; }
                            ;;
                        21) # OpenVPN
                            echo "Installing OpenVPN..."
                            nala install -y openvpn || { echo "Error installing OpenVPN"; exit 1; }
                            ;;
                        22) # OnionShare
                            echo "Installing OnionShare..."
                            nala install -y onionshare || { echo "Error installing OnionShare"; exit 1; }
                            ;;
                        23) # Riseup VPN
                            echo "Installing Riseup VPN..."
                            nala install -y riseup-vpn || { echo "Error installing Riseup VPN"; exit 1; }
                            ;;
                        24) # rkhunter
                            echo "Installing rkhunter..."
                            nala install -y rkhunter || { echo "Error installing rkhunter"; exit 1; }
                            ;;
                        25) # Recon-ng
                            echo "Installing Recon-ng..."
                            nala install -y recon-ng || { echo "Error installing Recon-ng"; exit 1; }
                            ;;
                        26) # Social-Engineer Toolkit (SET)
                            echo "Installing Social-Engineer Toolkit (SET)..."
                            nala install -y set || { echo "Error installing Social-Engineer Toolkit (SET)"; exit 1; }
                            ;;
                        27) # Suricata
                            echo "Installing Suricata..."
                            nala install -y suricata || { echo "Error installing Suricata"; exit 1; }
                            ;;
                        28) # Syncthing
                            echo "Installing Syncthing..."
                            nala install -y syncthing || { echo "Error installing Syncthing"; exit 1; }
                            ;;
                        29) # Tailscale
                            echo "Installing Tailscale..."
                            nala install -y tailscale || { echo "Error installing Tailscale"; exit 1; }
                            ;;
                        30) # VeraCrypt
                            echo "Installing VeraCrypt..."
                            nala install -y veracrypt || { echo "Error installing VeraCrypt"; exit 1; }
                            ;;
                        31) # Sirikali
                            echo "Installing Sirikali..."
                            nala install -y sirikali || { echo "Error installing Sirikali"; exit 1; }
                            ;;
                        32) # Wifite
                            echo "Installing Wifite..."
                            nala install -y wifite || { echo "Error installing Wifite"; exit 1; }
                            ;;
                        33) # WireGuard
                            echo "Installing WireGuard..."
                            nala install -y wireguard || { echo "Error installing WireGuard"; exit 1; }
                            ;;
                        34) # Wireshark
                            echo "Installing Wireshark..."
                            nala install -y wireshark || { echo "Error installing Wireshark"; exit 1; }
                            ;;
                        35) # sqlmap
                            echo "Installing sqlmap..."
                            nala install -y sqlmap || { echo "Error installing sqlmap"; exit 1; }
                            ;;
                        36) # None
                            echo "No privacy and security application will be installed."
                            ;;
                        *) # Invalid option
                            echo "Invalid option: $option"
                            ;;
                    esac
                done

                echo "Installation completed. Enjoy your privacy and security applications!"

            elif [ "$main_option" -eq 2 ]; then
                echo "Select the privacy and security applications you want to install (enter the corresponding numbers, separated by spaces):"
                echo -e "1) Aircrack-ng ${YELLOW} - Wireless security auditing tool.${NC} $(get_app_status aircrack-ng)"
                echo -e "2) BeEF ${YELLOW} - Browser Exploitation Framework.${NC} $(get_app_status beef)"
                echo -e "3) BleachBit ${YELLOW} - Privacy and disk space cleaner.${NC} $(get_app_status bleachbit)"
                echo -e "4) Cewl ${YELLOW} - Custom word list generator.${NC} $(get_app_status cewl)"
                echo -e "5) ClamTk ${YELLOW} - GUI for ClamAV antivirus.${NC} $(get_app_status clamtk)"
                echo -e "6) Cryptsetup ${YELLOW} - Disk encryption tool.${NC} $(get_app_status cryptsetup)"
                echo -e "7) Ettercap ${YELLOW} - Network sniffer/interceptor/logger.${NC} $(get_app_status ettercap-graphical)"
                echo -e "8) Firejail ${YELLOW} - Sandbox program for Linux.${NC} $(get_app_status firejail)"
                echo -e "9) Gobuster ${YELLOW} - Directory/file brute-forcer.${NC} $(get_app_status gobuster)"
                echo -e "10) GnuPG ${YELLOW} - Encryption and signing tool.${NC} $(get_app_status gnupg)"
                echo -e "11) Gufw Firewall ${YELLOW} - GUI for UFW firewall.${NC} $(get_app_status gufw)"
                echo -e "12) Hydra ${YELLOW} - Password cracking tool.${NC} $(get_app_status hydra)"
                echo -e "13) John the Ripper ${YELLOW} - Password cracking software.${NC} $(get_app_status john)"
                echo -e "14) KeePassXC ${YELLOW} - Password manager.${NC} $(get_app_status keepassxc)"
                echo -e "15) Kleopatra ${YELLOW} - Certificate manager and GUI for GnuPG.${NC} $(get_app_status kleopatra)"
                echo -e "16) Kismet ${YELLOW} - Wireless network detector.${NC} $(get_app_status kismet)"
                echo -e "17) Lynis ${YELLOW} - Security auditing tool.${NC} $(get_app_status lynis)"
                echo -e "18) Metadata Cleaner ${YELLOW} - Remove metadata from files.${NC} $(get_app_status metadata-cleaner)"
                echo -e "19) Nmap ${YELLOW} - Network exploration tool.${NC} $(get_app_status nmap)"
                echo -e "20) Nikto ${YELLOW} - Web server scanner.${NC} $(get_app_status nikto)"
                echo -e "21) OpenVPN ${YELLOW} - VPN solution.${NC} $(get_app_status openvpn)"
                echo -e "22) OnionShare ${YELLOW} - Share files securely and anonymously.${NC} $(get_app_status onionshare)"
                echo -e "23) Riseup VPN ${YELLOW} - Privacy-focused VPN service.${NC} $(get_app_status riseup-vpn)"
                echo -e "24) rkhunter ${YELLOW} - Rootkit scanner.${NC} $(get_app_status rkhunter)"
                echo -e "25) Recon-ng ${YELLOW} - Web reconnaissance framework.${NC} $(get_app_status recon-ng)"
                echo -e "26) Social-Engineer Toolkit (SET) ${YELLOW} - Penetration testing framework for social engineering.${NC} $(get_app_status set)"
                echo -e "27) Suricata ${YELLOW} - Network threat detection engine.${NC} $(get_app_status suricata)"
                echo -e "28) Syncthing ${YELLOW} - Continuous file synchronization.${NC} $(get_app_status syncthing)"
                echo -e "29) Tailscale ${YELLOW} - Zero-config VPN service.${NC} $(get_app_status tailscale)"
                echo -e "30) VeraCrypt ${YELLOW} - Disk encryption software.${NC} $(get_app_status veracrypt)"
                echo -e "31) Sirikali ${YELLOW} - GUI for managing encrypted volumes.${NC} $(get_app_status sirikali)"
                echo -e "32) Wifite ${YELLOW} - Automated wireless attack tool.${NC} $(get_app_status wifite)"
                echo -e "33) WireGuard ${YELLOW} - Modern VPN protocol.${NC} $(get_app_status wireguard)"
                echo -e "34) Wireshark ${YELLOW} - Network protocol analyzer.${NC} $(get_app_status wireshark)"
                echo -e "35) sqlmap ${YELLOW} - Automatic SQL injection tool.${NC} $(get_app_status sqlmap)"
                echo "36) None"
                read -p "Option [1-36]: " -a options

                # Uninstall the selected privacy and security applications
                for option in "${uninstall_options[@]}"; do
                    case $option in
                        1) # Aircrack-ng
                            nala remove --purge -y aircrack-ng || { echo "Error uninstalling Aircrack-ng"; }
                            ;;
                        2) # BeEF
                            nala remove --purge -y beef || { echo "Error uninstalling BeEF"; }
                            ;;
                        3) # BleachBit
                            nala remove --purge -y bleachbit || { echo "Error uninstalling BleachBit"; }
                            ;;
                        4) # Bitwarden
                            nala remove --purge -y bitwarden || { echo "Error uninstalling Bitwarden"; }
                            ;;
                        5) # Cewl
                            nala remove --purge -y cewl || { echo "Error uninstalling Cewl"; }
                            ;;
                        6) # ClamTk
                            nala remove --purge -y clamtk || { echo "Error uninstalling ClamTk"; }
                            ;;
                        7) # Cryptsetup
                            nala remove --purge -y cryptsetup || { echo "Error uninstalling Cryptsetup"; }
                            ;;
                        8) # Ettercap
                            nala remove --purge -y ettercap-graphical || { echo "Error uninstalling Ettercap"; }
                            ;;
                        9) # Firejail
                            nala remove --purge -y firejail || { echo "Error uninstalling Firejail"; }
                            ;;
                        10) # Gobuster
                            nala remove --purge -y gobuster || { echo "Error uninstalling Gobuster"; }
                            ;;
                        11) # GnuPG
                            nala remove --purge -y gnupg || { echo "Error uninstalling GnuPG"; }
                            ;;
                        12) # Gufw Firewall
                            nala remove --purge -y gufw || { echo "Error uninstalling Gufw Firewall"; }
                            ;;
                        13) # Hydra
                            nala remove --purge -y hydra || { echo "Error uninstalling Hydra"; }
                            ;;
                        14) # John the Ripper
                            nala remove --purge -y john || { echo "Error uninstalling John the Ripper"; }
                            ;;
                        15) # KeePassXC
                            nala remove --purge -y keepassxc || { echo "Error uninstalling KeePassXC"; }
                            ;;
                        16) # Kleopatra
                            nala remove --purge -y kleopatra || { echo "Error uninstalling Kleopatra"; }
                            ;;
                        17) # Kismet
                            nala remove --purge -y kismet || { echo "Error uninstalling Kismet"; }
                            ;;
                        18) # Lynis
                            nala remove --purge -y lynis || { echo "Error uninstalling Lynis"; }
                            ;;
                        19) # Metadata Cleaner
                            nala remove --purge -y metadata-cleaner || { echo "Error uninstalling Metadata Cleaner"; }
                            ;;
                        20) # Nmap
                            nala remove --purge -y nmap || { echo "Error uninstalling Nmap"; }
                            ;;
                        21) # Nikto
                            nala remove --purge -y nikto || { echo "Error uninstalling Nikto"; }
                            ;;
                        22) # OpenVPN
                            nala remove --purge -y openvpn || { echo "Error uninstalling OpenVPN"; }
                            ;;
                        23) # OnionShare
                            nala remove --purge -y onionshare || { echo "Error uninstalling OnionShare"; }
                            ;;
                        24) # Riseup VPN
                            nala remove --purge -y riseup-vpn || { echo "Error uninstalling Riseup VPN"; }
                            ;;
                        25) # rkhunter
                            nala remove --purge -y rkhunter || { echo "Error uninstalling rkhunter"; }
                            ;;
                        26) # Recon-ng
                            nala remove --purge -y recon-ng || { echo "Error uninstalling Recon-ng"; }
                            ;;
                        27) # Social-Engineer Toolkit (SET)
                            nala remove --purge -y set || { echo "Error uninstalling Social-Engineer Toolkit (SET)"; }
                            ;;
                        28) # Suricata
                            nala remove --purge -y suricata || { echo "Error uninstalling Suricata"; }
                            ;;
                        29) # Syncthing
                            nala remove --purge -y syncthing || { echo "Error uninstalling Syncthing"; }
                            ;;
                        30) # Tailscale
                            nala remove --purge -y tailscale || { echo "Error uninstalling Tailscale"; }
                            ;;
                        31) # VeraCrypt
                            nala remove --purge -y veracrypt || { echo "Error uninstalling VeraCrypt"; }
                            ;;
                        32) # Sirikali
                            nala remove --purge -y sirikali || { echo "Error uninstalling Sirikali"; }
                            ;;
                        33) # Wifite
                            nala remove --purge -y wifite || { echo "Error uninstalling Wifite"; }
                            ;;
                        34) # WireGuard
                            nala remove --purge -y wireguard || { echo "Error uninstalling WireGuard"; }
                            ;;
                        35) # Wireshark
                            nala remove --purge -y wireshark || { echo "Error uninstalling Wireshark"; }
                            ;;
                        36) # sqlmap
                            nala remove --purge -y sqlmap || { echo "Error uninstalling sqlmap"; }
                            ;;
                        37) # None
                            echo "No privacy and security application will be uninstalled."
                            ;;
                        *) # Invalid option
                            echo "Invalid option: $option"
                            ;;
                    esac
                done

                # Clean orphaned packages
                echo "Cleaning orphaned packages..."
                nala autoremove -y

                # Optionally, remove repositories related to uninstalled applications
                echo "Removing unnecessary repositories..."
                echo "Uninstallation completed."

            elif [ "$main_option" -eq 3 ]; then
                echo "Exiting the privacy and security application menu."
                return  # Esto saldrá de la función, pero no del script completo
            else
                echo "Invalid option: $main_option"
            fi  # Fin del bloque if
        else
            echo "Invalid option. Please enter a number between 1 and 3."
        fi  # Fin del bloque if
          sudo clear  
    done
}

# Main menu
while true; do
# Definimos colores
YELLOW='\033[1;33m'
RESET='\033[0m'

# Función para imprimir el título "ROOTDEB" en grande
print_title() {
    echo -e "${YELLOW}"
    echo "██████╗ ██╗ ██████╗ ████████╗██████╗ ███████╗██████╗" 
    echo "██╔══██╗██║██╔═══██╗╚══██╔══╝██╔══██╗██╔════╝██╔══██╗"
    echo "██████╔╝██║██║   ██║   ██║   ██║  ██║█████╗  ██████╔╝"
    echo "██╔══██╗██║██║   ██║   ██║   ██║  ██║██╔══╝  ██╔══██╗"
    echo "██║  ██║██║╚██████╔╝   ██║   ██████╔╝███████╗██████╔╝"
    echo "╚═╝  ╚═╝╚═╝ ╚═════╝    ╚═╝   ╚═════╝ ╚══════╝╚═════╝"
    echo -e "${RESET}"
}
                   
# Imprimir el título
print_title

    echo "Select an option:"
    echo "0) Add additional Debian repositories"
    echo "1) Installing Desktop Environments"
    echo "2) Update Firmware"
    echo "3) CPU & GPU Configuration"
    echo "4) Web Browsers"
    echo "5) Image Applications"
    echo "6) Messaging Applications"
    echo "7) Music Applications"
    echo "8) Video Applications"
    echo "9) Multimedia Applications"
    echo "10) Privacy and Security Applications"
    echo "11) Security Auditing and Testing Applications"
    echo "12) Download Manager and BitTorrent Client Installation"
    echo "13) Energy Management Tool Applications"
    echo "14) Backup Applications"
    echo "15) Office Applications"
    echo "16) Text Editors"
    echo "17) Development Applications"
    echo "18) Terminal Applications"    
    echo "19) System Tools"
    echo "20) Privacy and Security Applications"
    echo "21) Exit"
    read -p "Option [0-21]: " menu_option

    case $menu_option in
        0)  # Add additional Debian repositories
            manage_repositories
            ;;
        1)  # Desktop Enviromment
            install_minimal_desktop_envs
            ;;
        2)  # Update Firmware
            update_firmware
            ;;
        3)  # CPU & GPU
            manage_installations
            ;;
        4)  # Web Browsers
            install_browsers
            ;;
        5)  # Image Apps
            manage_image_apps
            ;;
        6)  # Messaging Applications
            install_messaging_apps
            ;;
        7) # Music Applications  
            install_music_apps
            ;;
        8) # Video Applications  
            install_video_apps
            ;;  
        9)  # Sound & Video Applications
            install_multimedia_apps
            ;;
        10)  # Privacy and Security Applications
            install_security_privacy_apps
            ;;
        11)  # Penetration Testing Applications
            install_audit_security_apps
            ;;
        12)  # Download Manager and BitTorrent Client Installation
            install_download_apps
            ;;
        13)  # Energy Management Tool
            manage_energy_tools_menu
            ;;
        14) #Backup Applications    
            install_backup_apps
            ;;   
        15) #Office Applications
            manage_pdf_office_apps
            ;;     
        16) #Text Editors
            install_development_apps
            ;;           
        17) # Development Applications
            install_development_apps
            ;;
        18) #Termianl Applications
            install_terminal_apps
            ;;
        19) #System Tools
            install_system_tools
            ;;       
        20) #Privacy and Security Applications
            install_privacy_security_apps
            ;;                       
        21)  # Exit
            echo "Exiting the script. Goodbye!"
            exit 0
            ;;
        *)  # Invalid option
            echo "Invalid option. Please choose an option between 0 and 21."
            ;;
    esac
done
