#!/bin/bash

ansible-playbook -i hosts install.yml --tags "all_install" -k