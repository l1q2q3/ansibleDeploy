#!/bin/bash
#此文件用于存放业务类函数

#用于检测是否已安装
function check_installed(){
	echo "[ Begin }: in function ${FUNCNAME}!"
	ls $install_root_path | grep -E "versions|jobs|tools" >/dev/null 2>&1
	if [ $? -eq 0 ];then
		echo "had installed!" && return 1
	else
		return 0
	fi
	echo "[ End }: execute ${FUNCNAME} SUCCESS!"
}


#用于修改服务工作目录链接
function change_job_link(){
	echo "[ Begin }: in function ${FUNCNAME}!"
	if [[ -L $install_root_path/jobs ]];then
		unlink $install_root_path/jobs
		ln -s $install_root_path/versions/$version $install_root_path/jobs
	fi
	echo "[ End }: execute ${FUNCNAME} SUCCESS!"
}


#用于部分组件特殊处理
function special_config(){
	return 0
}

#用于停止服务
function stop_service(){
	return 0
}

#用于启动服务
function start_service(){
	return 0
}