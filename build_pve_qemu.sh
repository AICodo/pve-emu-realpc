#以下三行docker里面运行需要sudo，一共有3个sudo 如果pve里面运行请删除sudo
#!/bin/bash
sudo apt-get install -y libacl1-dev libaio-dev libattr1-dev libcap-ng-dev libcurl4-gnutls-dev libepoxy-dev libfdt-dev libgbm-dev libgnutls28-dev libiscsi-dev libjpeg-dev libnuma-dev libpci-dev libpixman-1-dev libproxmox-backup-qemu0-dev librbd-dev libsdl1.2-dev libseccomp-dev libslirp-dev libspice-protocol-dev libspice-server-dev libsystemd-dev liburing-dev libusb-1.0-0-dev libusbredirparser-dev libvirglrenderer-dev meson python3-sphinx python3-sphinx-rtd-theme quilt xfslibs-dev
ls
df -h
git clone git://git.proxmox.com/git/pve-qemu.git
cd pve-qemu
#git reset --hard 839b53bab89fddb7a7fb3a1d722e05df932cce4e
sudo apt install devscripts -y
yes | sudo mk-build-deps --install
git submodule update --init --recursive
cp ../sedPatch-pve-qemu-kvm7-8-anti-dection.sh qemu/
cd qemu
meson subprojects download
chmod +x sedPatch-pve-qemu-kvm7-8-anti-dection.sh
bash sedPatch-pve-qemu-kvm7-8-anti-dection.sh
cp ../../smbios.h include/hw/firmware/smbios.h
cp ../../smbios.c hw/smbios/smbios.c
cp ../../bootsplash.jpg pc-bios/bootsplash.jpg # modify seabios bootsplash.jpg
sed -i "s/vgabios.bin/vgabios.bin',\n\t'bootsplash.jpg/g" pc-bios/meson.build # modify seabios bootsplash.jpg
sed -i 's/current_machine->boot_config.splash;/"\/usr\/share\/kvm\/bootsplash.jpg";/g' hw/nvram/fw_cfg.c # modify seabios bootsplash.jpg
sed -i 's/!object_dynamic_cast/object_dynamic_cast/g' hw/vfio/igd.c

#bash ../../1plus.sh   		    # 1plus modidy cpu P-core+E-core and more,amd and intel different.

#bash ../../2plus.sh   		    # 2plus modidy acpi and virtIO pciids.

#bash ../../2plus-amd.sh   		# 2plus added modidy only amd more pciids.

#bash ../../3StrongStart.sh 	# 3StrongStart.sh modify moniter q35 and roms.

git diff --submodule=diff > qemu-autoGenPatch.patch
cp qemu-autoGenPatch.patch ../

#bash ../../3StrongEnd.sh 		# 3StrongEnd.sh build roms.

cd ..
make clean
make #改为一次编译
cd qemu/
git checkout .
cd ..

# strong reset project data
rm -Rf qemu/pc-bios
git reset --hard master
git submodule update --init --recursive --force
git checkout .
cd qemu/
git checkout .
git submodule update --init --recursive --force
git checkout .
cd ../..
