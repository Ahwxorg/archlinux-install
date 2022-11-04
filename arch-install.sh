# Credit to Bugswriter (https://bugswriter.com)

#part1
echo "Welcome to Ahwx' arch installer script"
read -p "Continue? [y/n]" continueanswer
if [[ $continueanswer != y ]] ; then
  exit
fi
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
lsblk
echo "Enter the drive to install Arch Linux onto (make sure to make EFI partition as well): "
read drive
cfdisk $drive 
echo "Enter the Arch Linux root partition: "
read partition
mkfs.ext4 $partition 
read -p "Did you also create efi partition? [y/n]" answer
if [[ $answer = y ]] ; then
  echo "Enter EFI partition: "
  read efipartition
  mkfs.vfat -F 32 $efipartition
fi
mount $partition /mnt 
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit 

#part2
pacman -S --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P
echo "Enter password for root user"
passwd
pacman --noconfirm -S grub efibootmgr os-prober
echo "Enter EFI partition: " 
read efipartition
mkdir /boot/efi
mount $efipartition /boot/efi 
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
sed -i 's/quiet/pci=noaer/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --noconfirm xorg-server xorg-xinit xorg-xkill xorg-xsetroot xorg-xbacklight xorg-xprop noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono ttf-joypixels ttf-font-awesome sxiv mpv zathura zathura-pdf-mupdf ffmpeg imagemagick fzf man-db xwallpaper python-pywal unclutter xclip maim zip unzip p7zip xdotool papirus-icon-theme brightnessctl dosfstools ntfs-3g git sxhkd zsh pipewire pipewire-pulse arc-gtk-theme rsync dash xcompmgr libnotify dunst slock jq aria2 dhcpcd networkmanager wpa_supplicant rsync pamixer mpd ncmpcpp zsh-syntax-highlighting xdg-user-dirs libconfig

systemctl enable NetworkManager.service 

echo "Enter username:"
read username
echo "permit persist :wheel" >> /etc/doas.conf
echo "permit nopass root" >> /etc/doas.conf
echo "permit persist $username" >> /etc/doas.conf
useradd -m -G wheel -s /bin/zsh $username
echo "Enter password for your user account"
passwd $username
echo "Pre-installation finished. Please reboot into the drive now."
read -p "Do you want to reboot? [y/n]" answer
if [[ $answer = y ]] ; then
  reboot now
fi

git clone --depth=1 https://github.com/Ahwxorg/dwm.git ~/.local/src/dwm
sudo make -C ~/.local/src/dwm install

git clone --depth=1 https://github.com/Ahwxorg/pt.git ~/.local/src/st
sudo make -C ~/.local/src/st install

git clone --depth=1 https://github.com/Ahwxorg/dmenu.git ~/.local/src/dmenu
sudo make -C ~/.local/src/dmenu install

git clone --depth=1 https://github.com/Ahwxorg/dwmblocks.git ~/.local/src/dwmblocks
sudo make -C ~/.local/src/dwmblocks install

git clone https://aur.archlinux.org/yay-git.git
cd yay
makepkg -si
cd
yay -S libxft-bgra-git yt-dlp-drop-in
mkdir down dox pix dev

ln -s ~/.config/x11/xinitrc .xinitrc
ln -s ~/.config/shell/profile .zprofile
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/Ahwxorg/dotfiles
cd dotfiles
mv * ~/
mv .* ~/

exit
