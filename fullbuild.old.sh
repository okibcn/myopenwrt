#!/bin/bash



###################################
#                                 #
#  DEVICE PROFILES                #
#                                 #
###################################

config_E8450() {
    PROFILE=linksys_e8450-ubi
    RELEASE=snapshots
    TARGET=mediatek
    ARCH=mt7622
    DIFF_CONFIG=E8450.config
    DIFF_PACKAGES="mc nano-plus htop ncdu iperf3 irqbalance auc ca-certificates ca-buldle -wpad-basic-wolfssl -libustream-wolfssl -px5g-wolfssl wpad-openssl libustream-openssl luci-ssl-openssl luci luci-compat luci-mod-dashboard luci-app-attendedsysupgrade luci-app-vnstat2 luci-app-nlbwmon luci-app-adblock luci-app-banip luci-app-bcp38 luci-app-commands luci-app-ddns ddns-scripts-noip luci-app-openvpn luci-ssl-openssl luci-app-sqm luci-app-wireguard luci-app-upnp luci-app-uhttpd luci-app-statistics collectd-mod-conntrack collectd-mod-cpu collectd-mod-cpufreq collectd-mod-dhcpleases collectd-mod-entropy collectd-mod-exec collectd-mod-interface collectd-mod-iwinfo collectd-mod-load collectd-mod-memory collectd-mod-network collectd-mod-ping collectd-mod-rrdtool collectd-mod-sqm collectd-mod-thermal collectd-mod-uptime collectd-mod-wireless blockd cryptsetup e2fsprogs f2fs-tools kmod-fs-exfat kmod-fs-ext4 kmod-fs-f2fs kmod-fs-hfs kmod-fs-hfsplus kmod-fs-msdos kmod-fs-nfs kmod-fs-nfs-common kmod-fs-nfs-v3 kmod-fs-nfs-v4 kmod-fs-vfat kmod-nls-base kmod-nls-cp1250 kmod-nls-cp437 kmod-nls-cp850 kmod-nls-iso8859-1 kmod-nls-iso8859-15 kmod-nls-utf8 kmod-usb-storage kmod-usb-storage-uas libblkid ntfs-3g nfs-utils ip6tables-mod-nat 6in4 6rd 6to4 ip6tables-nft luci-theme-argon luci-app-argon-config luci-lib-ipkg luci-app-ttyd"
    REPO=
    BRANCH=
}

config_R6020() {
    PROFILE="netgear_r6020"
    RELEASE="snapshots"
    TARGET="ramips"
    ARCH="mt76x8"
    DIFF_PACKAGES="nano-plus htop iperf3 luci wpad-mesh-wolfssl -wpad-basic-wolfssl luci-app-vnstat2 luci-app-nlbwmon"
    DIFF_CONFIG=
    REPO=
    BRANCH=
}

config_R7800() {
    PROFILE="netgear_r7800"
    RELEASE="snapshots"
    TARGET="ipq806x"
    ARCH="generic"
    DIFF_CONFIG="R7800.config"
    DIFF_PACKAGES="mc nano-plus htop ncdu iperf3 irqbalance auc ca-certificates -wpad-basic-wolfssl -libustream-wolfssl -px5g-wolfssl wpad-openssl libustream-openssl luci-ssl-openssl luci luci-compat luci-mod-dashboard luci-app-attendedsysupgrade luci-app-vnstat2 luci-app-nlbwmon luci-app-adblock luci-app-banip luci-app-bcp38 luci-app-commands luci-app-ddns ddns-scripts-noip luci-app-openvpn -luci-ssl-openssl luci-app-sqm luci-app-wireguard luci-app-upnp luci-app-uhttpd luci-app-statistics collectd-mod-conntrack collectd-mod-cpu collectd-mod-cpufreq collectd-mod-dhcpleases collectd-mod-entropy collectd-mod-exec collectd-mod-interface collectd-mod-iwinfo collectd-mod-load collectd-mod-memory collectd-mod-network collectd-mod-ping collectd-mod-rrdtool collectd-mod-sqm collectd-mod-thermal collectd-mod-uptime collectd-mod-wireless blockd cryptsetup e2fsprogs f2fs-tools kmod-fs-exfat kmod-fs-ext4 kmod-fs-f2fs kmod-fs-hfs kmod-fs-hfsplus kmod-fs-msdos kmod-fs-nfs kmod-fs-nfs-common kmod-fs-nfs-v3 kmod-fs-nfs-v4 kmod-fs-vfat kmod-nls-base kmod-nls-cp1250 kmod-nls-cp437 kmod-nls-cp850 kmod-nls-iso8859-1 kmod-nls-iso8859-15 kmod-nls-utf8 kmod-usb-storage kmod-usb-storage-uas libblkid ntfs-3g nfs-utils ip6tables-mod-nat 6in4 6rd 6to4 ip6tables-nft luci-theme-argon luci-app-argon-config luci-lib-ipkg luci-app-ttyd"
    REPO=
    BRANCH=
}

config_R7800NSS() {
    PROFILE="netgear_r7800"
    RELEASE="snapshots"
    TARGET="ipq806x"
    ARCH="generic"
    DIFF_PACKAGES="nano-plus htop ncdu iperf3 irqbalance auc luci luci-compat luci-mod-dashboard luci-app-attendedsysupgrade luci-theme-argon luci-app-argon-config luci-lib-ipkg luci-app-ttyd luci-app-vnstat2 luci-app-nlbwmon"
    REPO="https://github.com/ACwifidude/openwrt"
    BRANCH="kernel5.10-nss-qsdk11.0"
    DIFF_CONFIG="R7800NSS-ACwifidude.config"
}

###################################
#                                 #
#  ENVIRONMENT SETUP              #
#                                 #
###################################

install_OSTools() {
    echo "========================="
    echo "ENVIRONMENT SETUP"
    echo "========================="

    sudo rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /opt/ghc
    sudo -E apt-get -qq update
    sudo -E apt-get -qq upgrade -y
    sudo -E apt-get -qq install -y bzip2 diff find flex gawk gcc-6+ getopt grep libc-dev libz-dev make4.1+ perl python3.6+ rsync subversion unzip which
    sudo -E apt-get -qq autoremove --purge
    sudo -E apt-get -qq clean
}

###################################
#                                 #
#  DOWNLOAD OPENWRT               #
#                                 #
###################################

dl_Openwrt() {
    echo "========================="
    echo "DOWNLOAD OPENWRT"
    echo "========================="
    rm -rf $DIR
    [ -z $REPO ] && REPO=https://github.com/openwrt/openwrt
    [ -z $BRANCH ] && BRANCH=master
    echo "#"
    echo "#     Downloading  OpenWrt from $REPO using branch $BRANCH"
    echo "#"
    git clone --branch $BRANCH $REPO $DIR
    cd $DIR
    RELEASE=$(./scripts/getver.sh)
    echo "OpenWrt SNAPSHOT "$(./scripts/getver.sh)
    
    # APPLY EARLY PATCH TO MT76 KERNEL DRIVER
    sed -i "s/PKG_SOURCE_DATE:=2022-02-15/PKG_SOURCE_DATE:=2022-02-24/g" package/kernel/mt76/Makefile
    sed -i "s/PKG_SOURCE_VERSION:=c67df0d3130a51d79b558f0329c2ca289c73b16e/PKG_SOURCE_VERSION:=64c74dc93f68566cd2c199d2951482ee55ca8b9a/g" package/kernel/mt76/Makefile
    sed -i "s/PKG_MIRROR_HASH:=57526f62adc1c1cc2c594ff23b883314ad83df8cdfab54c9e3503a8ec4c3a33f/PKG_MIRROR_HASH:=5b3d60047ff9ee97e091b7a2cd20778d1eea61e9210ad19944f2b942a3c16d90/g" package/kernel/mt76/Makefile
    
    # APPLY PATCH TO NANO ADDING SUPPORT FOR SYNTAX HIGHLIGHTNING (adds 360Kb to image)
    sed -i "s/--disable-color/--enable-color/g" feeds/packages/utils/nano/Makefile

    cd ..
}

###################################
#                                 #
#  ADD CUSTOM FEEDS               #
#                                 #
###################################

dl_Feeds() {
    echo "========================="
    echo "ADD CUSTOM FEEDS"
    echo "========================="
    # # Info at https://openwrt.org/docs/guide-developer/feeds
    # # Uncomment a feed source
    # sed -i 's/^#\(.*targets\)/\1/' feeds.conf
    # # Add a feed source
    # sed -i "/iptmon/d" feeds.conf
    # echo src-link iptmon /home/build/iptmon >> feeds.conf
}

###################################
#                                 #
#  INSTALL FEEDS                  #
#                                 #
###################################

install_Feeds() {
    echo "========================="
    echo "INSTALL FEEDS"
    echo "========================="
    cd $DIR
    # Read feed data
    ./scripts/feeds update -a
    # Download Packages from feeds
    ./scripts/feeds install -a
    cd ..
}

###################################
#                                 #
#  ADDING EXTRA PACKAGES          #
#                                 #
###################################

dl_ExtraPkg() {
    echo "========================="
    echo "ADD EXTRA PACKAGES"
    echo "========================="
    git clone -b master https://github.com/jerrykuku/luci-theme-argon $DIR/package/luci-theme-argon
    git clone -b master https://github.com/jerrykuku/luci-app-argon-config $DIR/package/luci-app-argon-config
    # fixes missing dependency
    sed -i "/LUCI_DEPENDS:=+luci-compat/c\LUCI_DEPENDS:=+luci-compat +luci-lib-ipkg" $DIR/package/luci-app-argon-config/Makefile
}

###################################
#                                 #
#  CUSTOMIZE CONFIG               #
#                                 #
###################################

customize_Config() {
    echo "========================="
    echo "CUSTOMIZE CONFIG"
    echo "========================="
    if [ -z $TARGET ]; then
        deviceline=$(awk '/menuconfig TARGET/ && /DEVICE/&&/'$PROFILE'/ {print}' $DIR/tmp/.config-target.in | sort -u)
        if [ $(wc -l <<<$deviceline) -gt 1 ]; then
            echo $PROFILE" is applicable to more than one device, please add target architecture:"
            awk -F "_DEVICE_" '{print "TARGET_SUBTARGET: "$2" PROFILE: "$3}' <<<$deviceline
            exit 1
        fi
        PROFILE=$(awk -F "_DEVICE_" '{print $3}' <<<$deviceline)
        TARGET=$(awk -F "_" '{print $3}' <<<$deviceline)
        ARCH=$(awk -F "_DEVICE_" '{print $2}' <<<$deviceline | awk -F "_" '{print $2}')
    fi
    echo "Device PROFILE: $PROFILE"
    echo "Device TARGET: $TARGET"
    echo "Device ARCHITECTURE: $ARCH"
    cp ./$DIFF_CONFIG $DIR/.config
    echo "==============="
    echo "BASE CONFIG:"
    echo "==============="
    cat $DIR/.config
    echo " " >>$DIR/.config
    echo "#" >>$DIR/.config
    echo "# DEVICE INFO" >>$DIR/.config
    echo "#" >>$DIR/.config
    awk -i inplace '!/CONFIG_TARGET/ || !/=y/ {print}' $DIR/.config
    echo "CONFIG_TARGET_$TARGET=y" >>$DIR/.config
    if [ -z $ARCH ]; then
        echo "CONFIG_TARGET_"$TARGET"_DEVICE_$PROFILE=y" >>$DIR/.config
    else
        echo "CONFIG_TARGET_"$TARGET"_$ARCH=y" >>$DIR/.config
        echo "CONFIG_TARGET_"$TARGET"_"$ARCH"_DEVICE_$PROFILE=y" >>$DIR/.config
    fi
    echo "================="
    echo "ADD DIFF PACKAGES"
    echo "================="
    echo "Adding Packages: $DIFF_PACKAGES"
    echo "#" >>$DIR/.config
    echo "# CUSTOM PACKAGE SET" >>$DIR/.config
    echo "#" >>$DIR/.config
    array=($(echo $DIFF_PACKAGES | tr ' ' '\n'))
    for i in ${array[@]}; do
        if [[ ${i:0:1} == "-" ]]; then
            sed -i "/CONFIG_PACKAGE_"${i:1}"/d" $DIR/.config
            echo "# CONFIG_PACKAGE_${i:1} is not set" >>$DIR/.config
        else
            sed -i "/CONFIG_PACKAGE_"$i"/d" $DIR/.config
            echo "CONFIG_PACKAGE_$i=y" >>$DIR/.config
        fi
    done
    cp $DIR/.config $DIR/diff.config
    echo "=================="
    echo "FINAL DIFF CONFIG:"
    echo "=================="
    cat $DIR/.config
}

###################################
#                                 #
#  DIFF TO FULL CONFIG            #
#                                 #
###################################

process_Config() {
    echo "========================="
    echo "DIFF TO FULL CONFIG"
    echo "========================="
    cd $DIR
    make defconfig
    cd ..
}

###################################
#                                 #
#  DOWNLOAD SOURCES               #
#                                 #
###################################

dl_Sources() {
    echo "========================="
    echo "DOWNLOAD SOURCES"
    echo "========================="
    cd $DIR
    make download -j
    cd ..
}

###################################
#                                 #
#  APPLY CODE PATCHES             #
#                                 #
###################################

patch_Source() {
    echo "========================="
    echo "APPLY CODE PATCHES"
    echo "========================="

    # place here any code patch
}

###################################
#                                 #
#  APPLY FILES PATCHES            #
#                                 #
###################################

patch_Files() {
    echo "========================="
    echo "PATCH FILES"
    echo "========================="
    cd $DIR
    mkdir -p files
    cp -r ../files .

    # OpenWrt Kernel name in bin/targets/*/*/*/  ->  arm aarch64 powerpc mips64 mipsel x86_64 i386
    # Possible go architectures: 386,amd64,arm,arm64,ppc64,ppc64le,mips,mipsle,mips64 and mips64le
    OpenARCH=$( awk -F \" '/CONFIG_ARCH=/ {print $2}' .config )
    [ $OpenARCH = arm ]       && GOARCH=arm
    [ $OpenARCH = aarch64 ]   && GOARCH=arm64
    [ $OpenARCH = i386 ]      && GOARCH=386
    [ $OpenARCH = mips ]      && GOARCH=mips
    [ $OpenARCH = mipsel ]    && GOARCH=mipsle
    [ $OpenARCH = mips64 ]    && GOARCH=mips64
    [ $OpenARCH = mips64el ]  && GOARCH=mips64le
    [ $OpenARCH = x86_64 ]    && GOARCH=amd64
    [ $OpenARCH = powerpc64 ] && GOARCH=ppc64
    echo "OpenWrt arch Id: $OpenARCH = GO arch Id: $GOARCH"
    if [ -n $GOARCH ]; then
        rm -rf micro
        export GOARCH
        echo "GO ARCH: $GOARCH"
        git clone https://github.com/zyedidia/micro micro
        cd micro
        go version
        echo "Building code for linux $GOARCH"
        make
        mkdir -p ../files/usr/bin 
        # ! which upx > /dev/null && sudo -E apt-get -qq install upx
        # upx --lzma --best micro -o ../files/usr/bin/micro 
        cp micro ../files/usr/bin/micro
        cd ..
        sed -i '/export EDITOR*/c\export EDITOR=micro' files/root/.profile
    fi

    #     mkdir -p files/etc/config
    #     mkdir -p ./files/root
    #     tee ./files/root/.profile << EOF
    # export EDITOR=nano
    # export PAGER=less
    # alias ..='cd ..'
    # alias cd..='cd ..'
    # alias ...='cd ../../../'
    # alias .4='cd ../../../../'
    # alias .5='cd ../../../../..'
    # alias d='ls -CFA --color=auto'
    # alias cls='clear'
    # alias l='ls -CFA --color=auto'
    # alias ll='ls -alsF --color=auto'
    # alias egrep='egrep --color=auto'
    # alias fgrep='fgrep --color=auto'
    # alias grep='grep --color=auto'
    # alias md='mkdir'
    # alias now='date +"%T"'
    # alias today='date +"%Y.%m.%d"'
    # alias path='echo -e \${PATH//:/\\\\n}'
    # alias du1='du -hd 1'
    # alias meminfo='free -m -l -t'
    # alias cpuinfo='cat /proc/cpuinfo'
    # alias cpv='rsync -ah --info=progress2'
    # alias ver='cat /etc/os-release ; uname -a'
    # alias chexe='chmod +x'
    # alias i='opkg install'
    # alias up='opkg update'
    # alias manifest="opkg list-installed |awk '{print \\\$1}' |sort"
    # alias bw='while true ; do clear ; nlbw -c show -g mac -o -rx_bytes; sleep 5; done'
    # EOF

    #     mkdir -p ./files/etc/init.d
    #     tee ./files/etc/init.d/iperf3 << EOF
    # #!/bin/sh /etc/rc.common
    # USE_PROCD=1
    # START=91
    # STOP=01
    # start_service() {
    #     procd_open_instance
    #     procd_set_param command /usr/bin/iperf3 -s -p 5201
    #     procd_set_param stdout 1
    #     procd_set_param stderr 1
    #     procd_close_instance
    # }
    # EOF
    #     chmod +x ./files/etc/init.d/iperf3

    #     mkdir -p ./files/etc/init.d
    #     tee ./files/etc/init.d/irqbalance << EOF
    # #!/bin/sh /etc/rc.common
    # USE_PROCD=1
    # START=91
    # STOP=01
    # start_service() {
    #     procd_open_instance
    #     procd_set_param command /usr/sbin/irqbalance -f -t 10
    #     procd_set_param stdout 1
    #     procd_set_param stderr 1
    #     procd_close_instance
    # }
    # EOF
    #     chmod +x ./files/etc/init.d/irqbalance
    cd ..
}

###################################
#                                 #
#  BUILD FULL RELEASE             #
#                                 #
###################################
build_Full() {
    echo "========================="
    echo "BUILD FULL RELEASE"
    echo "========================="
    cd $DIR
    make -j$(( $(nproc) * 2 )) || make -j1 || make -j1 V=s
    echo "OpenWrt SNAPSHOT "$(./scripts/getver.sh)
    cd ..
}

###################################
#                                 #
#  FAKE BUILD FULL RELEASE        #
#                                 #
###################################
build_Fake() {
    echo $(nproc)" processors cores available."
    mkdir -p $DIR/bin/targets/family/arch/packages
    cp "./$DIFF_CONFIG" $DIR/diff.config
    echo $DIR/bin/targets/*/*
    cd $DIR/bin/targets/*/*
    dd if=/dev/zero of=config.buildinfo bs=1K count=10
    dd if=/dev/zero of=feeds.buildinfo bs=1K count=10
    dd if=/dev/zero of=version.buildinfo bs=1K count=10
    dd if=/dev/zero of=profiles.json bs=1K count=10
    dd if=/dev/zero of=sha256sums bs=1K count=10
    dd if=/dev/zero of=$DIR-ipq806x-generic-netgear_r7800-initramfs-uImage bs=1K count=10
    dd if=/dev/zero of=$DIR-ipq806x-generic-netgear_r7800-squashfs-factory.img bs=1K count=10
    dd if=/dev/zero of=$DIR-ipq806x-generic-netgear_r7800-squashfs-sysupgrade.bin bs=1K count=10
    dd if=/dev/zero of=$DIR-ipq806x-generic-netgear_r7800.manifest bs=1K count=10
    dd if=/dev/zero of=config.buildinfo bs=1K count=10
    dd if=/dev/zero of=config.buildinfo bs=1K count=10
    dd if=/dev/zero of=config.buildinfo bs=1K count=10
    RELEASE="FAKE"
}

###################################
#                                 #
#  MAIN CODE                      #
#                                 #
###################################

configs="default E8450 R7800 R7800NSS R6020"
! [ -z $1 ] && if grep -q "$1" <<<"$configs"; then
    [ "$1" = "default" ] && CFG=E8450 || CFG=$1
    config_$CFG
    #install_OSTools
    export DIR="ow.$CFG"
    export CFG
    dl_Openwrt
    dl_Feeds
    install_Feeds
    dl_ExtraPkg
    customize_Config
    process_Config
    patch_Files
    dl_Sources
    patch_Source
    build_Full
    # build_Fake
    echo "PROFILE=$PROFILE" >>$GITHUB_ENV
    echo "TARGET=$TARGET" >>$GITHUB_ENV
    echo "ARCH=$ARCH" >>$GITHUB_ENV
    echo "RELEASE=$RELEASE" >>$GITHUB_ENV
    echo "DIFF_PACKAGES=$DIFF_PACKAGES" >>$GITHUB_ENV
    echo "DIFF_CONFIG=$DIFF_CONFIG" >>$GITHUB_ENV
fi
exit 0
