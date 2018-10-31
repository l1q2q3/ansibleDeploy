#!/bin/bash

if [[ $1 == "start" || $1 == "stop" || $1 == "restart" ]]; then
    ansible-playbook -i hosts service.yml --extra-vars "action=$1" -k
else
    echo "Input error!!  usage: bash service.sh stop|start|restart"
fi
