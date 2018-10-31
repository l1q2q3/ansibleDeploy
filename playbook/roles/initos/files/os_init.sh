#!/bin/bash
#script name:CentOS7.X OS optimize script!
#Author:Chenguomin
#Date:2018/4/12

BASEPATH=$(cd `dirname $0`; pwd)
source $BASEPATH/config.ini


#define variable
sys_version=`cat /etc/redhat-release  | awk '/[0-9]/ {for(i=1;i<=NF;i++) if($i ~ /[0-9]/)  print $i i}' |awk -F. '{ print $1 }'`
if [[ ! -f /etc/redhat-release && $sys_version != "7" ]]; then
    echo "This script not support the OS" && exit 1
fi

#get first network interface IP address
host_ip=$(ifconfig $interface_dev | grep inet | head -n1 | awk '{print $2}')

#add ssh user
function add_user(){
    useradd $ssh_user
    echo "$ssh_user_passwd" | passwd --stdin $ssh_user
cat > /etc/sudoers.d/$ssh_user << EOF
$ssh_user ALL=(ALL) ALL

EOF
}

#set selinux
function set_selinux(){
   sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
   setenforce 0
   [[ $? -ne 0 ]] && echo "set selinux failed!!" && return 1
}

#disable firewalld and install iptables
function set_firewall(){
    systemctl stop firewalld.service
    systemctl disable firewalld.service
    yum -y install iptables-services
    systemctl restart iptables.service
    systemctl enable iptables.service
    iptables -F
    iptables-save
    [[ $? -ne 0 ]] && echo "set firewall failed!!" && return 1
}

#set open file handle
function set_limits(){
echo "ulimit -SHn 65535">> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
*           soft   nofile       65535
*           hard   nofile       65535
EOF

}

#set sshd
function set_sshd(){
cat >> /etc/ssh/sshd_config << EOF
ListenAddress $host_ip
PermitRootLogin no
AllowUsers  $ssh_user
AllowGroups $ssh_user
EOF
    chmod 640 /etc/ssh/sshd_config 
    systemctl restart sshd
    [[ $? -ne 0 ]] && echo "set sshd failed!!" && return 1
}

#set sysctl
function set_sysctl(){
cat >> /etc/sysctl.conf << EOF
net.ipv4.conf.all.arp_announce = 2
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.$interface_dev.arp_announce = 2
net.ipv4.conf.$interface_dev.arp_announce = 2

net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.default.arp_ignore = 1
net.ipv4.conf.lo.arp_ignore = 1
net.ipv4.conf.$interface_dev.arp_ignore = 1
net.ipv4.conf.$interface_dev.arp_ignore = 1

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_max_syn_backlog = 32768
net.ipv4.ip_local_port_range = 1024 65535

net.core.wmem_default = 1746400
net.core.wmem_max = 3492800
net.core.rmem_default = 1746400
net.core.rmem_max = 3492800
net.core.netdev_max_backlog = 32768
net.core.somaxconn = 16384

EOF
sysctl -p
}

#disable ipv6
function disable_ipv6(){
echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf
sed -i '/^IPV6*/d' /etc/sysconfig/network-scripts/ifcfg-$interface_dev
sed -i '/^GRUB_CMDLINE_LINUX=*/d' /etc/default/grub
echo 'GRUB_CMDLINE_LINUX="ipv6.disable=1 crashkernel=auto rhgb quiet"' >> /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
[[ $? -ne 0 ]] && echo "disable ipv6 failed!!" && return 1
}

#disable ctrl-alt-del
function disable_ctrl_alt_del(){
rm -rf /usr/lib/systemd/system/ctrl-alt-del.target
init q
}

##main 
function main(){
    add_user
    set_selinux
    set_firewall
    set_limits
    set_sshd
    set_sysctl
    disable_ipv6
	disable_ctrl_alt_del
}

main


