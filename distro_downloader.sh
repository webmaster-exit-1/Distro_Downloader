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

# Function to list available versions for a selected distro
list_versions() {
  local distro_url=$1
  echo "Fetching available versions from $distro_url..."
  # This is a placeholder. You would need to implement actual logic to fetch versions.
  # For example, you might use `curl` and `grep` to parse the HTML for version links.
  echo "Available versions:"
  echo "1. Version 1"
  echo "2. Version 2"
  echo "3. Version 3"
  echo "Press Enter to select the latest version."
}

# Function to download the selected version
download_version() {
  local distro=$1
  local version=$2
  local url=$3

  if [[ "$version" == "latest" ]]; then
    echo "Downloading the latest version of $distro from $url"
  else
    echo "Downloading $distro version $version from $url"
  fi

  # Placeholder for actual download logic
  # You would use `aria2c` or another tool to download the ISO file
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
    algo=$algo_input
  fi

  echo "Verifying checksum using $algo..."
  # Placeholder for actual checksum verification logic
}

# Check if aria2c is installed
check_aria2_installed

# Main script
echo "Select a distribution to download:"
select distro in "${!distros[@]}"; do
  if [[ -n "$distro" ]]; then
    distro_url=${distros[$distro]}
    list_versions "$distro_url"
    echo "Enter the version number you want to download (or press Enter for the latest version):"
    read -r version_number
    if [[ -z "$version_number" ]]; then
      version_number="latest"
    fi
    download_version "$distro" "$version_number" "$distro_url"
    break
  else
    echo "Invalid selection. Please try again."
  fi
done
