# vmware-share-mounter

<img width="616" height="416" alt="image" src="https://github.com/user-attachments/assets/a9c74ed1-7801-4497-a700-f50b3850e44f" />

Interactive shell script for mounting VMware shared folders in Ubuntu virtual machines.

## About
This project automates the process of discovering a VMware shared folder, choosing a mount point, and configuring persistent mounts on Ubuntu guests.

## Prerequisites
Ensure `open-vm-tools` is installed on your Ubuntu VM:
```bash
sudo apt update
sudo apt install open-vm-tools open-vm-tools-desktop -y
```

## Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/pouriatabari/vmware-share-mounter.git
   cd vmware-share-mounter
   ```

2. **Make the script executable:**
   ```bash
   chmod +x mount-vmware-share.sh
   ```

3. **Run the script:**
   ```bash
   ./mount-vmware-share.sh
   ```

The script will interactively guide you through selecting the shared folder, setting the mount point, and optionally adding it to `/etc/fstab`.

## Manual Reference
If you prefer to mount manually:
```bash
sudo mount -t fuse.vmhgfs-fuse .host:/SHARE_NAME /mnt/hgfs/SHARE_NAME -o allow_other
```

## License
This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.
