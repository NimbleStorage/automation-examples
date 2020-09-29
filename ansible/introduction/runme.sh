#!/bin/bash

set -e

ansible-playbook provision.yaml -e nimble_array=nva \
    -e volume_name=myvol1 -e volume_igroup=node22
ansible-playbook query.yaml -e nimble_array=nva -e volume_name=myvol1
ansible -m command node22 -a 'df -h /mnt/myvol1'
ansible-playbook tune.yaml -e nimble_array=nva \
    -e volume_name=myvol1 -e volume_iops=1000 \
    -e "volume_description='Mutated by Ansible'"
ansible -m shell node22 -a 'date > /mnt/myvol1/date.txt && sync'
ansible-playbook snapshot.yaml -e nimble_array=nva \
    -e volume_name=myvol1 -e snapshot_name=mysnap1 
ansible-playbook provision.yaml -e nimble_array=nva \
    -e volume_name=myvol1-clone -e snapshot_name=mysnap1 \
    -e volume_clone=yes -e clone_from=myvol1 \
    -e volume_igroup=node23
ansible -m command node22 -a 'cat /mnt/myvol1/date.txt'
ansible -m command node23 -a 'cat /mnt/myvol1-clone/date.txt'
ansible-playbook decommission.yaml -e nimble_array=nva \
    -e volume_name=myvol1-clone -e volume_igroup=node23
ansible-playbook decommission.yaml -e nimble_array=nva \
    -e volume_name=myvol1 -e volume_igroup=node22
