#!/bin/bash

# THIS SCRIPT GENERATES A OPENWRT IMAGE GIVEN THE CONFIGURATION
#
# For more info: https://github.com/okibcn/OpenWrt-R6020

## SET BUILD CONFIGURATION
# RELEASE can be "snapshots" or a release version i.e. "21.02.1"
# i.e. from openwrt-21.02.1-ramips-mt76x8-netgear_r6020-squashfs-factory

# NETGEAR R6020
RELEASE="21.02.2"
TARGET="ramips"
ARCH="mt76x8"
PROFILE="netgear_r6020"
CUSTOM_PACKAGES="nano-full htop iperf3 luci wpad-mesh-wolfssl -wpad-basic-wolfssl luci-app-vnstat2 luci-app-nlbwmon"

# NETGEAR R7800
# RELEASE="snapshots"
# TARGET="ipq806x"
# ARCH="generic"
# PROFILE="netgear_r7800"
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES -kmod-ath10k-ct -ath10k-firmware-qca9984-ct kmod-ath10k ath10k-firmware-qca9984"
# CUSTOM_PACKAGES="nano-plus htop ncdu iperf3 irqbalance auc -kmod-ath10k-ct -ath10k-firmware-qca9984-ct kmod-ath10k ath10k-firmware-qca9984 -wpad-basic-wolfssl wpad-wolfssl openvpn-wolfssl luci-ssl luci luci-compat luci-mod-dashboard luci-app-attendedsysupgrade luci-theme-argon luci-app-argon-config luci-lib-ipkg luci-app-ttyd luci-app-statistics collectd-mod-conntrack collectd-mod-cpu collectd-mod-cpufreq collectd-mod-dhcpleases collectd-mod-entropy collectd-mod-exec collectd-mod-interface collectd-mod-iwinfo collectd-mod-load collectd-mod-memory collectd-mod-network collectd-mod-ping collectd-mod-rrdtool collectd-mod-sqm collectd-mod-thermal collectd-mod-uptime collectd-mod-wireless"

# LINKSYS E8450
# RELEASE="snapshots"
# TARGET="mediatek"
# ARCH="mt7622"
# PROFILE="linksys_e8450-ubi"

# CUSTOM_PACKAGES="nano-plus htop ncdu iperf3 irqbalance auc ca-certificates"
# # CUSTOM_PACKAGES="$CUSTOM_PACKAGES -wpad-basic-wolfssl wpad-wolfssl openvpn-wolfssl luci-ssl"
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES -wpad-basic-wolfssl -libustream-wolfssl -px5g-wolfssl wpad-openssl libustream-openssl luci-ssl-openssl"
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci luci-compat luci-mod-dashboard luci-app-attendedsysupgrade luci-app-vnstat2 luci-app-nlbwmon luci-app-adblock luci-app-banip luci-app-bcp38 luci-app-commands luci-app-ddns ddns-scripts-noip luci-app-openvpn -luci-ssl-openssl luci-app-sqm luci-app-wireguard luci-app-upnp luci-app-uhttpd"
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-statistics collectd-mod-conntrack collectd-mod-cpu collectd-mod-cpufreq collectd-mod-dhcpleases collectd-mod-entropy collectd-mod-exec collectd-mod-interface collectd-mod-iwinfo collectd-mod-load collectd-mod-memory collectd-mod-network collectd-mod-ping collectd-mod-rrdtool collectd-mod-sqm collectd-mod-thermal collectd-mod-uptime collectd-mod-wireless"
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES blockd cryptsetup e2fsprogs f2fs-tools kmod-fs-exfat kmod-fs-ext4 kmod-fs-f2fs kmod-fs-hfs kmod-fs-hfsplus kmod-fs-msdos kmod-fs-nfs kmod-fs-nfs-common kmod-fs-nfs-v3 kmod-fs-nfs-v4 kmod-fs-vfat kmod-nls-base kmod-nls-cp1250 kmod-nls-cp437 kmod-nls-cp850 kmod-nls-iso8859-1 kmod-nls-iso8859-15 kmod-nls-utf8 kmod-usb-storage kmod-usb-storage-uas libblkid ntfs-3g nfs-utils"
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES ip6tables-mod-nat 6in4 6rd 6to4 ip6tables-nft"



if [ "$RELEASE" = "snapshots" ]; then
	MANIFEST="https://downloads.openwrt.org/snapshots/targets/$TARGET/$ARCH/openwrt-$TARGET-$ARCH.manifest"
	IMAGEBUILDER="https://downloads.openwrt.org/snapshots/targets/$TARGET/$ARCH/openwrt-imagebuilder-$TARGET-$ARCH.Linux-x86_64.tar.xz"
else
	MANIFEST="https://downloads.openwrt.org/releases/$RELEASE/targets/$TARGET/$ARCH/openwrt-$RELEASE-$TARGET-$ARCH.manifest"
	IMAGEBUILDER="https://downloads.openwrt.org/releases/$RELEASE/targets/$TARGET/$ARCH/openwrt-imagebuilder-$RELEASE-$TARGET-$ARCH.Linux-x86_64.tar.xz"
fi	
STD_PACKAGES=$( wget $MANIFEST -O - | awk '{print $1}' | sort | tr '\n' ' ' )



## INSTALLS BUILD TOOLS
# sudo rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /opt/ghc
# sudo -E apt-get -qq update
# sudo -E apt-get -qq upgrade -y
# sudo -E apt-get -qq install p7zip-full build-essential libncurses5-dev libncursesw5-dev zlib1g-dev gawk git gettext libssl-dev xsltproc rsync wget unzip python
# sudo -E apt-get -qq autoremove --purge
# sudo -E apt-get -qq clean


## CREATES OPENWRT BUILD ENVIRONMENT FOR THE TARGET AND ARCHITECTURE
myfolder=~/kk/myopenwrt/ow.$PROFILE
mkdir -p $myfolder
cd $myfolder
wget $IMAGEBUILDER -O - | tar xJf - --strip-components=1;


## ADDS LOCAL PACKAGES AND FILES SUPPORT
cd $myfolder
make clean
# ensures the local package folder is enabled in repo config file
grep -q "src imagebuilder file:packages" repositories.conf || echo "src imagebuilder file:packages" >> repositories.conf

mkdir -p packages
cp ../nano-full*.ipk packages
# URL=$(wget -q https://api.github.com/repos/jerrykuku/luci-theme-argon/releases/latest -O - | awk -F \" -v RS="," '/browser_download_url/ && /argon_/ {print $(NF-1)}')
# wget $URL -O packages/$(basename "$URL")
# URL=$(wget -q https://api.github.com/repos/jerrykuku/luci-theme-argon/releases/latest -O - | awk -F \" -v RS="," '/browser_download_url/ && /config_/ {print $(NF-1)}')
# wget $URL -O packages/$(basename "$URL")

mkdir -p files

# echo #
# echo #    INSTALLS MICRO EDITOR
# echo #
# OpenARCH=$( awk -F \" '/CONFIG_ARCH=/ {print $2}' .config )
# [ $OpenARCH = arm ]       && GOARCH=arm
# [ $OpenARCH = aarch64 ]   && GOARCH=arm64
# [ $OpenARCH = i386 ]      && GOARCH=386
# [ $OpenARCH = mips ]      && GOARCH=mips
# [ $OpenARCH = mipsel ]    && GOARCH=mipsle
# [ $OpenARCH = mips64 ]    && GOARCH=mips64
# [ $OpenARCH = mips64el ]  && GOARCH=mips64le
# [ $OpenARCH = x86_64 ]    && GOARCH=amd64
# [ $OpenARCH = powerpc64 ] && GOARCH=ppc64
# echo "OpenWrt arch Id: $OpenARCH = GO arch Id: $GOARCH"
# if [ -n $GOARCH ]; then
#     rm -rf micro
#     export GOARCH
#     echo "GO ARCH: $GOARCH"
#     git clone https://github.com/zyedidia/micro micro
#     cd micro
#         go version
#         echo "Building code for linux $GOARCH"
#         make
#         mkdir -p ../files/usr/bin 
#         # ! which upx > /dev/null && sudo -E apt-get -qq install upx
#         # upx --lzma --best micro -o ../files/usr/bin/micro 
#         cp micro ../files/usr/bin/micro
#     cd ..
#     sed -i '/export EDITOR*/c\export EDITOR=micro' files/root/.profile
# fi



## ADDS ADDITIONAL CUSTOM IPK
# Download latest iptmon ipk release from github:
# URL=$(wget -q https://api.github.com/repos/oofnikj/iptmon/releases/latest -O - | awk -F \" -v RS="," '/browser_download_url/ {print $(NF-1)}')
# wget $URL -O packages/$(basename "$URL")


# ADD CUSTOM FILES
cp -r ../files files

## BUILD THE FIRMWARE
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
make image PROFILE=$PROFILE PACKAGES="$CUSTOM_PACKAGES" FILES=./files/ EXTRA_IMAGE_NAME="$(date +"%Y.%m.%d-%H%M")"

manifest=$( find "$PWD/bin" -name "*manifest" )
FINAL_PACKAGES=$( cat $manifest | awk '{print $1}' | sort | tr '\n' ' ' )
# echo -e `wc -w <<< $EXT_PACKAGES` " EXTERNAL PACKAGES: \n$EXT_PACKAGES \n"
echo -e `wc -w <<< $CUSTOM_PACKAGES` " CUSTOM PACKAGES:\n$CUSTOM_PACKAGES \n"
echo -e `wc -w <<< $STD_PACKAGES` " STANDARD MANIFEST: \n$STD_PACKAGES \n"
echo -e `wc -w <<< $FINAL_PACKAGES` " FINAL MANIFEST:  \n$FINAL_PACKAGES \n"
echo -e "OUTPUT FOLDER:\n" `dirname $manifest` "\n"
echo -e "OUTPUT FILES:"
ls -als `dirname $manifest` 
# ls -als `dirname $manifest` | awk '{print}'
# cp `dirname $manifest`/*bin ~/wdesktop
