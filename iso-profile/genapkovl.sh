#!/bin/sh
set -e

HOSTNAME="matcha"
TMP=$(mktemp -d)

trap "rm -rf $TMP" EXIT

mkdir -p "$TMP"/etc
mkdir -p "$TMP"/etc/runlevels/default
mkdir -p "$TMP"/etc/runlevels/sysinit
mkdir -p "$TMP"/etc/runlevels/boot

echo "$HOSTNAME" > "$TMP"/etc/hostname

ln -sf /etc/init.d/devfs "$TMP"/etc/runlevels/sysinit/devfs
ln -sf /etc/init.d/dmesg "$TMP"/etc/runlevels/sysinit/dmesg
ln -sf /etc/init.d/mdev "$TMP"/etc/runlevels/sysinit/mdev

ln -sf /etc/init.d/hwclock "$TMP"/etc/runlevels/boot/hwclock
ln -sf /etc/init.d/modules "$TMP"/etc/runlevels/boot/modules
ln -sf /etc/init.d/hostname "$TMP"/etc/runlevels/boot/hostname
ln -sf /etc/init.d/hwdrivers "$TMP"/etc/runlevels/boot/hwdrivers

cat <<'EOF' > "$TMP"/etc/issue
 ,ggg, ,ggg,_,ggg,                                                     
dP""Y8dP""Y88P""Y8b               I8             ,dPYb,                
Yb, `88'  `88'  `88               I8             IP'`Yb                
 `"  88    88    88            88888888          I8  8I                
     88    88    88               I8             I8  8'                
     88    88    88    ,gggg,gg   I8     ,gggg,  I8 dPgg,     ,gggg,gg 
     88    88    88   dP"  "Y8I   I8    dP"  "Yb I8dP" "8I   dP"  "Y8I 
     88    88    88  i8'    ,8I  ,I8,  i8'       I8P    I8  i8'    ,8I 
     88    88    Y8,,d8,   ,d8b,,d88b,,d8,_    _,d8     I8,,d8,   ,d8b,
     88    88    `Y8P"Y8888P"`Y88P""Y8P""Y8888PP88P     `Y8P"Y8888P"`Y8

EOF

cat <<'EOF' > "$TMP"/etc/motd
Welcome to Matcha Linux v26.04!

EOF

tar -C "$TMP" -c . | gzip -9 > "$HOSTNAME.apkovl.tar.gz"
