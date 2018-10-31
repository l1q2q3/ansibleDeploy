#!/bin/bash
#此文件用于存放通用类函数

#检测系统类型，默认只支持centos7
function check_os(){
	echo "[ Begin }: in function ${FUNCNAME}!"
	sys_version=`cat /etc/redhat-release  | awk '/[0-9]/ {for(i=1;i<=NF;i++) if($i ~ /[0-9]/)  print $i i}' |awk -F. '{ print $1 }'`
	if [[ ! -f /etc/redhat-release && $sys_version != "7" ]];then
		echo "This script not support the OS" && return 1
	else
		return 0
	fi
	echo "[ End }: execute ${FUNCNAME} SUCCESS!"
}


#自动填充模板文件中含{{*}}的参数
#usage: fillup_dir_files "directory" "param file"
#param1: template directory
#param2: define parameter file(null is conf/param.cfg)
function fillup_dir_files(){
	echo "[ Begin }: in function ${FUNCNAME}!"
	local file_dir=$1
	local except_file_list=$2
	local fillup_flag=0
	[[ ! -d "$file_dir" ]] && echo "$file_dir not exist!" && return 0
	for file in $file_dir/*
	do
		if [ -d "$file" ]; then
			fillup_dir_files $file $except_file_list
			[[ $? -ne 0 ]] && fillup_flag=1
		elif [ -f "$file" ]; then
			local is_except="false"
			OLD_IFS=$IFS
			IFS=","
		    for except_file in ${except_file_list[*]}
			do
				[[ "" != `echo "${file}" | grep "${except_file}"` ]] && is_except="true" && break
			done
		IFS=$OLD_IFS
		[[ "$is_except" == "true" ]] && continue
		local para_list=(`grep -o "{{.*}}" ${file} | sed 's/}}/\n/g' | grep "{{" | sed 's/.*{{//g' | sort -u`)
		for j in `echo ${para_list[@]}`
		do
		    egrep -v "^[[:space:]]*#" ${conf_home}/param.cfg | awk -F "=" '{print $1}' | grep -w "$j" >/dev/null
			if (( $? == 0 ));then
			    local para_value=`egrep -v "^[[:space:]]*#" ${conf_home}/param.cfg | awk -F"=" -v a=$j '{if($1==a)print $0}' | awk -F"=" 'BEGIN{i=2}{while(i<=NF){if(i<NF){printf $i"=";i++}else{printf $i;i++}}}' | tr -d "\""`
				para_value=`echo ${para_value} | sed 's/\\\\/\\\\\\\\/'`
				para_value=`echo ${para_value} | sed 's/#/\\\#/'`
				sed -i "s#{{$j}}#${para_value}#g" $file
			else
			    echo "${file} {{$j}} had not in ${conf_home}}/param.cfg!"
				fillup_flag=1				
			fi
		done
		fi
	done
	[[ $fillup_flag -ne 0 ]] && return 1
	echo "[ End }: execute ${FUNCNAME} SUCCESS!"
}

