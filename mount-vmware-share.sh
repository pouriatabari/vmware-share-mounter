#!/usr/bin/env bash

# vmware-share-mounter
# A simple interactive script to mount VMware shared folders in Ubuntu guests.

set -euo pipefail

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

print_banner() {
    echo -e "${GREEN}"
    cat <<'EOF'
██╗   ██╗███╗   ███╗██╗    ██╗ █████╗ ██████╗ ███████╗
██║   ██║████╗ ████║██║    ██║██╔══██╗██╔══██╗██╔════╝
██║   ██║██╔████╔██║██║ █╗ ██║███████║██████╔╝█████╗
╚██╗ ██╔╝██║╚██╔╝██║██║███╗██║██╔══██║██╔══██╗██╔══╝
 ╚████╔╝ ██║ ╚═╝ ██║╚███╔███╔╝██║  ██║██║  ██║███████╗
  ╚═══╝  ╚═╝     ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝

███████╗██╗  ██╗ █████╗ ██████╗ ███████╗
██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝
███████╗███████║███████║██████╔╝█████╗
╚════██║██╔══██║██╔══██║██╔══██╗██╔══╝
███████║██║  ██║██║  ██║██║  ██║███████╗
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝

███╗   ███╗ ██████╗ ██╗   ██╗███╗   ██╗████████╗███████╗██████╗
████╗ ████║██╔═══██╗██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
██╔████╔██║██║   ██║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝
██║╚██╔╝██║██║   ██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║
╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
EOF
    echo -e "${NC}"
    echo -e "${GREEN}Created by Pouriya Tabari${NC}"
    echo -e "${GREEN}Source: https://github.com/pouriatabari/vmware-share-mounter.git${NC}"
    echo
}

print_banner

# Dependency check
if ! command -v vmware-hgfsclient >/dev/null 2>&1; then
    print_error "vmware-hgfsclient not found. Please install open-vm-tools:"
    echo "  sudo apt update && sudo apt install open-vm-tools open-vm-tools-desktop -y"
    exit 1
fi

print_info "Available VMware shared folders:"
shares="$(vmware-hgfsclient)"
echo "$shares" | sed 's/^/  - /'

# Get share name
read -rp "Enter the share name to mount: " share_name
if [[ -z "$share_name" ]]; then
    print_error "Share name empty."
    exit 1
fi

# Mount point configuration
default_mount="/mnt/hgfs/${share_name}"
read -rp "Enter mount point [default: ${default_mount}]: " mount_point
mount_point="${mount_point:-$default_mount}"

# Create mount point
if [[ ! -d "$mount_point" ]]; then
    print_info "Creating mount point: ${mount_point}"
    sudo mkdir -p "$mount_point"
fi

# Mount
print_info "Mounting .host:/${share_name} to ${mount_point} ..."
sudo mount -t fuse.vmhgfs-fuse ".host:/${share_name}" "$mount_point" -o allow_other
print_info "Success!"

# Fstab configuration
if read -rp "Add to /etc/fstab for auto-mount? [y/N]: " confirm && [[ $confirm == [yY] ]]; then
    uid=$(id -u)
    gid=$(id -g)
    entry=".host:/${share_name} ${mount_point} fuse.vmhgfs-fuse allow_other,defaults,uid=${uid},gid=${gid} 0 0"

    if ! grep -Fq "${share_name}" /etc/fstab; then
        echo "$entry" | sudo tee -a /etc/fstab >/dev/null
        print_info "Added to /etc/fstab."
    else
        print_warn "Entry already exists in /etc/fstab."
    fi
fi
