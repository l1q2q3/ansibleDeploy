#!/bin/bash

function usage(){
cat << EOF > help.txt
Usage:  bash upgrade.sh [component name]

For example:
bash upgrade.sh api     # It will upgrade webapi node.
bash upgrade.sh all     # upgrade all node

Component explain:
admin          --> IDCM.AdminSite
api            --> IDCM.WebApiNotServer
apic2c         --> IDCM.WebApiC2C
maintain       --> IDCM.WebAPIMaintain
scheduler      --> IDCM.Host.Scheduler
schedulerc2c   --> IDCM.Host.C2CScheduler
match          --> IDCM.Host.MatchEngine
websockapi     --> IDCM.Host.WebSocketAPI
syncdata       --> IDCM.Persistence.SyncData
all            --> ALL component
EOF
cat help.txt
}

function compress_all(){
	cd /data/svn/Code
	for $i in `ls`;do
		tar -czf $i.tar.gz $i
	done
}
#更新代码
cd /data/svn/Code
svn update

#压缩文件夹
rm -rf /data/svn/Code/*.tar.gz
tar -czf Configs.tar.gz Configs

case $1 in
    admin)
    tar -czf IDCM.AdminSite.tar.gz IDCM.AdminSite
	;;
	api)
	tar -czf IDCM.WebApiNotServer.tar.gz IDCM.WebApiNotServer
	;;
	apic2c)
	tar -czf IDCM.WebApiC2C.tar.gz IDCM.WebApiC2C
	;;
	maintain)
	tar -czf IDCM.WebAPIMaintain.tar.gz IDCM.WebAPIMaintain
	;;
	scheduler)
	tar -czf IDCM.Host.Scheduler.tar.gz IDCM.Host.Scheduler
	;;
	schedulerc2c)
	tar -czf IDCM.Host.C2CScheduler.tar.gz IDCM.Host.C2CScheduler
	;;
	match)
	tar -czf IDCM.Host.MatchEngine.tar.gz IDCM.Host.MatchEngine
	;;
	websockapi)
	tar -czf IDCM.Host.WebSocketAPI.tar.gz IDCM.Host.WebSocketAPI
	;;
	syncdata)
	tar -czf IDCM.Persistence.SyncData.tar.gz IDCM.Persistence.SyncData
	;;
    all)
	compress_all
	;;
	help|*)
	usage
	;;
esac
    

#执行ansible升级动作
cd /data/deploy/IDCM/playbook
ansible-playbook -i hosts upgrade.yml -k
