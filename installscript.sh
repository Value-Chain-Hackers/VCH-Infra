#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi

# Update system and install prerequisites
echo "Updating system and installing prerequisites..."
dnf update -y
dnf install -y kdialog dnf-plugins-core flatpak

# Add Flathub repository for Flatpak
echo "Adding Flathub repository for Flatpak..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Notify user about the script's purpose
kdialog --msgbox "Setup script for Fedora KDE. Checking software installations."

# Define software list with proper package names or notes for manual handling
declare -A SOFTWARE_MAP=(
    ["LabPlot"]="labplot"
    ["Cantor"]="cantor"
    ["KStars"]="kstars"
    ["RKWard"]="rkward"
    ["Kile"]="kile"
    ["KmPlot"]="kmplot"
    ["Kalzium"]="kalzium"
    ["Step"]="step"
    ["Rocs"]="rocs"
    ["Quarto"]="flatpak install --noninteractive flathub io.quarto.Quarto"
    ["R"]="dnf install -y R"
    ["N8N"]="curl -fsSL https://docs.n8n.io/cli/install.sh | bash" # Requires npm/node.js
    ["Mattermost"]="flatpak install --noninteractive flathub com.mattermost.Desktop"
    ["Focalboard"]="flatpak install --noninteractive flathub io.focalboard.Focalboard"
    ["AppFlowy"]="Manual install required. Check https://github.com/AppFlowy-IO/appflowy"
    ["Logseq"]="flatpak install --noninteractive flathub com.logseq.Logseq"
    ["Chainforge"]="Manual install required. Check https://github.com/Chainforge/chainforge"
    ["GitHub Desktop"]="flatpak install --noninteractive flathub io.github.shiftey.Desktop"
    ["JupyterHub"]="pip install jupyterhub" # Requires Python and pip
    ["Netdata"]="bash <(curl -Ss https://my-netdata.io/kickstart.sh)"
    ["Docker"]="dnf install -y docker && systemctl enable --now docker"
    ["Prometheus"]="Manual install required. Check https://prometheus.io/docs/introduction/getting_started/"
    ["Grafana"]="dnf install -y grafana && systemctl enable --now grafana-server"
    ["Nextcloud"]="dnf install -y nextcloud"
    ["BorgBackup"]="dnf install -y borgbackup"
)

# Build a checklist for kdialog
CHECKLIST=()
for software in "${!SOFTWARE_MAP[@]}"; do
    if ! rpm -q "${SOFTWARE_MAP[$software]}" &>/dev/null && [[ ! "${SOFTWARE_MAP[$software]}" =~ "flatpak" ]]; then
        CHECKLIST+=("$software" "Not installed" "off") # Default to unchecked
    else
        CHECKLIST+=("$software" "Installed" "on") # Default to checked
    fi
done

# Display a checkbox dialog for user selection
SELECTED=$(kdialog --checklist "Select software to install" "${CHECKLIST[@]}" --separator " ")

# If the user cancels, exit the script
if [[ $? -ne 0 ]]; then
    echo "Installation canceled."
    exit 0
fi

# Install selected software
for software in $SELECTED; do
    software=$(echo $software | tr -d '"') # Remove quotes from kdialog output
    if [[ ! -z "$software" ]]; then
        echo "Installing $software..."
        eval "${SOFTWARE_MAP[$software]}"
    fi
done

# Completion message
kdialog --msgbox "Software installation completed!"


