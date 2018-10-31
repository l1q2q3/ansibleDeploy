#!/bin/bash
#此文件用于存放系统类函数

#设置ssh，不允许root登陆，修改服务监听地址。
function set_ssh(){
    echo "[ Begin }: in function ${FUNCNAME}!"
    if [ -f /etc/ssh/sshd_config ]; then
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    cat >> /etc/ssh/sshd_config << EOF
ListenAddress $host_ip
PermitRootLogin no
AllowUsers  $ssh_user
AllowGroups $ssh_user
EOF
    systemctl restart sshd
    [[ $? -ne 0 ]] && echo "Restart sshd failure!" && return 1
    else
        echo "sshd_config file not exist!!" && return 1
    fi
    echo "[ End }: execute ${FUNCNAME} SUCCESS!"
}

#还原SSH设置
function unset_ssh(){
    echo "[ Begin }: in function ${FUNCNAME}!"
    if [ -f /etc/ssh/sshd_config ]; then
        rm -rf /etc/ssh/sshd_config
        mv /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
        systemctl restart sshd
        [[ $? -ne 0 ]] && echo "Restart sshd failure!" && return 1
    else
        echo "sshd_config file not exist!!" && return 1
    fi
    echo "[ End }: execute ${FUNCNAME} SUCCESS!"
}

#设置DNS
function set_dns(){
    echo "[ Begin }: in function ${FUNCNAME}!"
    return 0
    echo "[ End }: execute ${FUNCNAME} SUCCESS!"
}

#还原DNS设置
function unset_dns(){
    echo "[ Begin }: in function ${FUNCNAME}!"
    return 0
    echo "[ End }: execute ${FUNCNAME} SUCCESS!"
}

#设置NTP
function set_ntp(){
    echo "[ Begin }: in function ${FUNCNAME}!"
    return 0
    echo "[ End }: execute ${FUNCNAME} SUCCESS!"
}

#还原NTP设置
function unset_ntp(){
    echo "[ Begin }: in function ${FUNCNAME}!"
    return 0
    echo "[ End }: execute ${FUNCNAME} SUCCESS!"
}

#关闭firewalld
function set_firewalld(){
    echo "[ Begin }: in function ${FUNCNAME}!"
    systemctl stop firewalld
    systemctl disable firewalld
    echo "[ End }: execute ${FUNCNAME} SUCCESS!"
}



#系统类函数总调度函数
function do_os(){
    echo "[ Begin }: in function ${FUNCNAME}!"
    set_ssh
    
    set_dns
    
    set_ntp
    
    set_firewalld
    echo "[ End }: execute ${FUNCNAME} SUCCESS!"    
}

#系统类函数总调度函数
function undo_os(){
    echo "[ Begin }: in function ${FUNCNAME}!"
    unset_ssh
    
    unset_dns
    
    unset_ntp
    
    echo "[ End }: execute ${FUNCNAME} SUCCESS!"    
}