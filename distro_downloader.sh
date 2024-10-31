#!/bin/bash

# Define the distros and their download links.
declare -A distros=(
  ["Ubuntu"]="https://releases.ubuntu.com/"
  ["Debian"]="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/"
  ["CentOS"]="https://www.centos.org/download/"
  ["RHEL"]="https://access.redhat.com/downloads/"
  ["Deepin"]="https://www.deepin.org/en/download/"
  ["Fedora"]="https://getfedora.org/en/workstation/download/"
  ["Rocky Linux"]="https://rockylinux.org/download"
  ["AlmaLinux"]="https://almalinux.org/download"
  ["openSUSE"]="https://www.opensuse.org/"
  ["MX Linux"]="https://mxlinux.org/download-links/"
  ["Manjaro"]="https://manjaro.org/download/"
  ["Linux Mint"]="https://linuxmint.com/download.php"
  ["Endless OS"]="https://endlessos.com/download/"
  ["Elementary OS"]="https://elementary.io/"
  ["Solus"]="https://getsol.us/download/"
  ["Zorin"]="https://zorin.com/os/download/"
  ["Arch"]="https://archlinux.org/download/"
  ["Kali"]="https://www.kali.org/get-kali/"
  ["Slackware"]="https://www.slackware.com/getslack/"
  ["Gentoo"]="https://www.gentoo.org/downloads/"
  ["NixOS"]="https://nixos.org/download.html"
  ["Lubuntu"]="https://lubuntu.me/downloads/"
  ["Xubuntu"]="https://xubuntu.org/download/"
  ["Kubuntu"]="https://kubuntu.org/getkubuntu/"
  ["Ubuntu MATE"]="https://ubuntu-mate.org/download/"
  ["Ubuntu Budgie"]="https://ubuntubudgie.org/download/"
  ["Ubuntu Studio"]="https://ubuntustudio.org/download/"
  ["Peppermint"]="https://peppermintos.com/"
  ["Parrot OS"]="https://www.parrotsec.org/download/"
  ["Qubes"]="https://www.qubes-os.org/downloads/"
  ["Pop OS"]="https://pop.system76.com/"
  ["Void Linux"]="https://voidlinux.org/download/"
  ["EndeavourOS"]="https://endeavouros.com/latest-release/"
  ["ArchBang"]="https://archbang.org/"
  ["Knoppix"]="http://www.knopper.net/knoppix-mirrors/index-en.html"
  ["Clear Linux"]="https://clearlinux.org/downloads"
  ["Oracle Linux"]="https://www.oracle.com/linux/downloads/"
)

# Define the colors for the menu.
green="\e[32m"
red="\e[31m"
reset="\e[0m"

# Function to check if aria2c is installed
check_aria2_installed() {
  if ! command -v aria2c &> /dev/null; then
    echo -e "${red}aria2c is not installed. Please install aria2c and try again.${reset}"
    exit 1
  fi
}

# Function to download the latest link dynamically using aria2 with error handling and progress bar
download_latest_link() {
  local url=$1
  local file_name
  file_name=$(basename "$url")

  # Use aria2c to download the file
  if aria2c -x 16 -s 16 -o "$file_name" "$url"; then
    echo -e "\n${green}Download completed successfully!${reset}"
  else
    echo -e "\n${red}Download failed! Please check your network connection or the URL.${reset}"
    read -r -p "Do you want to retry? (yes/no): " retry
    if [[ $retry == "yes" ]]; then
      download_latest_link "$url"
    else
      echo -e "${red}Exiting...${reset}"
      exit 1
    fi
  fi
}

# Function to verify checksum with improved output and flexible algorithm
verify_checksum() {
  local file_name=$1
  local checksum_url=$2

  # Detect checksum algorithm based on the checksum file name
  if [[ "$checksum_url" =~ "SHA256SUMS" ]]; then
    algo="sha256sum"
  elif [[ "$checksum_url" =~ "SHA1SUMS" ]]; then
    algo="sha1sum"
  elif [[ "$checksum_url" =~ "MD5SUMS" ]]; then
    algo="md5sum"
  else
    read -r -p "Could not automatically detect checksum algorithm. Please enter the algorithm (sha256, sha1, md5): " algo_input
    if [[ $algo_input == "sha256" ]]; then
      algo="sha256sum"
    elif [[ $algo_input == "sha1" ]]; then
      algo="sha1sum"
    elif [[ $algo_input == "md5" ]]; then
      algo="md5sum"
    else
      echo -e "${red}Invalid algorithm specified. Exiting...${reset}"
      exit 1
    fi
  fi

  local checksum_file
  checksum_file=$(basename "$checksum_url")

  # Download the checksum file
  aria2c -o "$checksum_file" "$checksum_url"

  # Verify the checksum
  if grep "$file_name" "$checksum_file" | $algo -c -; then
    echo -e "${green}Checksum verified successfully!${reset}"
  else
    echo -e "${red}Checksum mismatch! Please re-download the file.${reset}"
    exit 1
  fi
}

# Function to validate version input
validate_version() {
  while true; do
    read -r -p "Enter the version you want to download (e.g., 20.04, 11, 8): " version
    if [[ $version =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
      break
    else
      echo -e "${red}Invalid version format! Please try again.${reset}"
    fi
  done
}

# Function to validate edition input
validate_edition() {
  while true; do
    read -r -p "Do you want the desktop or server edition? (desktop/server): " edition
    if [[ $edition == "desktop" || $edition == "server" ]]; then
      break
    else
      echo -e "${red}Invalid input! Please enter either 'desktop' or 'server'.${reset}"
    fi
  done
}

# Check if aria2c is installed
check_aria2_installed

# Display the menu.
echo -e "${green}Welcome to the Linux Distro Downloader!${reset}"
echo -e "${green}Please select a distro to download:${reset}"

# Loop through the distros and display them in the menu.
i=1
for distro in "${!distros[@]}"; do
  echo -e "${green}$i. $distro${reset}"
  ((i++))
done

# Get the user's choice.
read -r -p "Enter your choice: " choice

# Validate the user's choice.
if [[ $choice -gt ${#distros[@]} || $choice -lt 1 ]]; then
  echo -e "${red}Invalid choice!${reset}"
  exit 1
fi

# Get the selected distro name and URL
selected_distro=$(printf "%s\n" "${!distros[@]}" | sed -n "${choice}p")
selected_url=${distros[$selected_distro]}

# Ask for version and edition with validation
validate_version
validate_edition

# Construct the download URL based on user input
download_url="${selected_url}${version}/${edition}/"

# Display the constructed URL
echo -e "${green}Downloading from: $download_url${reset}"

# Download the latest link dynamically using aria2 with progress bar
download_latest_link "$download_url"

# Ask for checksum verification
read -r -p "Do you want to verify the checksum? (yes/no): " verify

if [[ $verify == "yes" ]]; then
  # Construct the checksum URL
  checksum_url="${download_url}SHA256SUMS"
  verify_checksum "$(basename "$download_url")" "$checksum_url"
fi

# Display a success message.
echo -e "${green}\nDownload complete!${reset}"
echo -e "${green}Please check your Downloads folder.${reset}"
exit 0
