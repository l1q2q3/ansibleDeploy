#!/bin/bash
BASEPATH=$(cd `dirname $0`; pwd)
source $BASEPATH/../conf/param.cfg
source $BASEPATH/../common/common_function.sh
source $BASEPATH/../common/do_business.sh
source $BASEPATH/../common/do_os.sh


function do_install(){
	check_os
	[[ $? -ne 0 ]] && echo "os not support!" && return 1

	check_installed
	[[ $? -ne 0 ]] && echo "had installed!" && return 1	
	
	do_os
	[[ $? -ne 0 ]] && echo "setup os failure!" && return 1
	
	change_job_link
	[[ $? -ne 0 ]] && echo "change job link failure!" && return 1
	
	start_service
	[[ $? -ne 0 ]] && echo "start service failure!" && return 1
}


function do_uninstall(){
	return 0
}

function do_upgrade(){
	return 0
}

function do_rollback(){
	return 0
}