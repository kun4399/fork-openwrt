#!/bin/bash
#========================================================================================================================
# https://github.com/kun4399/fork-openwrt
# Description: DIY script (After updating feeds)
# Target: ImmortalWrt for NORCO EMB-3531 (RK3399)
# Source: https://github.com/retro98boy/openwrt
#========================================================================================================================

# ------------------------------- Main source configuration -------------------------------

# Set the default LAN IP address
default_ip="192.168.1.1"
ip_regex="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
# Override default IP if a valid custom IP is provided as the first argument
[[ -n "${1}" && "${1}" != "${default_ip}" && "${1}" =~ ${ip_regex} ]] && {
    echo "Modify default IP address to: ${1}"
    sed -i "/lan) ipad=\${ipaddr:-/s/\${ipaddr:-\"[^\"]*\"}/\${ipaddr:-\"${1}\"}/" package/base-files/*/bin/config_generate
}

# Set the default password for the 'root' user (change empty password to 'password')
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Append source repository information
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCEREPO='github.com/retro98boy/openwrt'" >>package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='immortalwrt-emb3531'" >>package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCEBRANCH='main'" >>package/base-files/files/etc/openwrt_release
echo "DISTRIB_DESCRIPTION='ImmortalWrt EMB-3531 R$(date +%Y.%m.%d)'" >>package/base-files/files/etc/openwrt_release

# Configure ccache
sed -i '/CONFIG_DEVEL/d' .config
sed -i '/CONFIG_CCACHE/d' .config
if [[ "${2}" == "true" ]]; then
    echo "CONFIG_DEVEL=y" >>.config
    echo "CONFIG_CCACHE=y" >>.config
    echo 'CONFIG_CCACHE_DIR="$(TOPDIR)/.ccache"' >>.config
else
    echo '# CONFIG_DEVEL is not set' >>.config
    echo "# CONFIG_CCACHE is not set" >>.config
    echo 'CONFIG_CCACHE_DIR=""' >>.config
fi

# ------------------------------- Main source configuration ends -------------------------------

# ------------------------------- Additional customizations -------------------------------

# Set EMB-3531 specific hostname
sed -i "s/option hostname.*/option hostname 'ImmortalWrt-EMB3531'/" package/base-files/files/bin/config_generate

# Set timezone to Asia/Shanghai
sed -i "s/option zonename.*/option zonename 'Asia\/Shanghai'/" package/base-files/files/bin/config_generate
sed -i "s/option timezone.*/option timezone 'CST-8'/" package/base-files/files/bin/config_generate

# ------------------------------- Additional customizations ends -------------------------------
