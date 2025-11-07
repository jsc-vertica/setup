#!/bin/bash

UBUNTU_RELEASE_VERSION='24.04'

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_green() { echo -e "${GREEN}$*${NC}"; }
print_yellow() { echo -e "${YELLOW}$*${NC}"; }
print_red() { echo -e "${RED}$*${NC}"; }

if [ 1 = 2 ]; then

print_green "----- install 1password start -----"
sudo apt install curl gpg -y

curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor -o /usr/share/keyrings/1password-archive-keyring.gpg

echo 'deb [signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list

sudo mkdir -p /etc/debsig/policies/1password.com/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/1password.com/1password.pol

sudo mkdir -p /usr/share/debsig/keyrings/1password.com
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor -o /usr/share/debsig/keyrings/1password.com/1password.gpg

sudo apt update
sudo apt install 1password -y

print_green "----- install 1password end -----"

print_green "----- install rider start -----"

sudo bash /home/jsc/install-rider.sh

print_green "----- install rider end -----"

print_green "----- install git start -----"

sudo apt install git -y

print_green "-----  install git end -----"

print_green "----- setup github ssh key start -----"

ssh-keygen -t ed25519 -C "github jsc-vertica"

eval "$(ssh-agent -s)"

ssh-add ~/.ssh/id_ed25519

cat ~/.ssh/id_ed25519.pub

print_yellow "Press any key to continue"

read

print_green "----- setup github ssh key end -----"

print_green "-----  install .net 8 sdk start -----"

sudo apt-get install -q -y dotnet-sdk-8.0

dotnet --info

print_green "-----  install .net 8 sdk end -----"

print_green "----- install sway start -----"

# https://github.com/swaywm/sway/wiki

sudo apt-get install sway

mkdir -p ~/.config/sway

cp /etc/sway/config ~/.config/sway/

# idle detection for sway
sudo apt install swayidle

# https://github.com/swaywm/swaylock/tree/master
# lock screen for sway
sudo apt-get install swaylock

print_green "----- install sway end -----"

print_green "----- install application launcher fuzzel start -----"

sudo apt-get install fuzzel

print_green "----- install application launcher fuzzel end  -----"

print_green "----- install chezmoi start -----"

sudo bash /home/jsc/install-chezmoi.sh

print_green "----- install chezmoi end -----"

print_green "----- install azure CLI start -----"

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

print_green "----- install azure CLI end -----"

print_green "----- install alacritty terminal emulator start -----"

sudo apt install alacritty

print_green "----- install alacritty terminal emulator end -----"

print_green "----- install docker start -----"
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo docker run hello-world

print_green "----- install docker end -----"

print_green "----- install sqlcmd start -----"

curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/$UBUNTU_RELEASE_VERSION/prod.list)"
apt-get update
apt-get install sqlcmd

print_green "----- install sqlcmd end -----"

print_green "----- install lsd start -----"
sudo apt install -y lsd
print_green "----- install lsd end -----"

print_green "----- install terraform start -----"
TERRAFORM_VERSION="1.9.5"

if command -v terraform &> /dev/null; then
    INSTALLED_VERSION=$(terraform version -json 2>/dev/null | grep -o '"version":"v\?[^"]*' | cut -d'"' -f4 | sed 's/^v//')
    echo "Terraform $INSTALLED_VERSION is already installed."
else
    echo "Installing Terraform $TERRAFORM_VERSION..."
    wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    unzip -q terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    echo "Terraform $TERRAFORM_VERSION installed."
fi
print_green "----- install terraform end -----"

print_green "----- install Chromium for Microsoft Teams and Outlook start -----"

sudo apt install -y chromium-browser

cat > ~/.local/share/applications/teams-web.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Microsoft Teams
Comment=Open Teams in Chromium app mode
Exec=chromium-browser --app="https://teams.microsoft.com"
Icon=teams
Terminal=false
Categories=Network;Chat;VideoConference;
StartupWMClass=teams.microsoft.com
EOF
chmod +x ~/.local/share/applications/teams-web.desktop

cat > ~/.local/share/applications/outlook-web.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Outlook Web App
Comment=Open Outlook in Chromium app mode
Exec=chromium-browser --app="https://outlook.office.com"
Icon=mail-client
Terminal=false
Categories=Network;Email;
StartupWMClass=outlook.office.com
EOF
chmod +x ~/.local/share/applications/outlook-web.desktop
print_green "----- install Chromium for Microsoft Teams and Outlook end -----"

print_green "----- install libreoffice start -----"
sudo apt install -y libreoffice
print_green "----- install libreoffice end -----"

fi

print_green "SETUP COMPLETED."

# TODO
# mako for notifications


