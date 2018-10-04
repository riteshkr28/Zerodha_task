#!/bin/bash
rm VagrantFile #removing VagrantFile if any
vagrant init ubuntu/trusty64 > log.log # creating VagrantFile
if [ $? -ne 0 ];
	then 
	echo  "Failed to initialize vagrant box" 
	exit 1
fi
sed -i 's/# config.vm.network "public_network"/config.vm.network "public_network", use_dhcp_assigned_default_route: true /g' Vagrantfile #assigning IP
vagrant up > log.log 
if [ $? -ne 0 ];
	then
        echo  "Failed to create the VM"
        exit 1
fi
IP=`vagrant ssh -c 'ifconfig' | sed -n 's/.*inet addr:\([0-9.]\+\)\s.*/\1/p' |awk 'NR==1{print $1}'` #retriving IP
rm hosts.yml #removing previous yaml file if any
echo "host_machine ansible_ssh_host=$IP ansible_become_user=vagrant ansible_become_pass=vagrant ansible_become_method=sudo" > hosts.yml # Creating hostfile for ansible script to run
ansible-playbook -i ./hosts.yml requested_task.yml #this will execute all the given task
