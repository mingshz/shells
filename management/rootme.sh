#!/bin/bash

# 这个脚本是建立一个名为CJ的用户，并且给予它最高权限
# 并设置CJ@蒋才的Mac可以直接登录
useradd CJ
usermod -aG wheel CJ
mkdir /home/CJ/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdEf1a6sTb6+QnCjiyW0zNpp7VwH3YlGhNmGRkEjs3iRbO2p6z+Y7OdDvjZvaXVINOZNztv07NmTHlkq4W+8BvLL2vmbKL4N3T+0LAWoRC4FljD5L0y2e/Ei7lrqKnoiWplM0PPyzu11o3KqGby60UJrxRsYUo/S5Wsnkvpm7DlWUu9hAtuueM58/3EHcaPe+zJsT1aGry5fN+d+syP3S8fKR0AMCgFoYlF/kR5RLfEp97F6B/tT9UoBdZC9O3guVLO+bauxr3u5dU1zhVZUxfl09d1XKFNnf0MpghRRsVNOxSzkl7D6Y1wHg2YbK2in+ELj6o90hqdYrlwJxaV13V CJ@JiangCais-MacBook-Pro.local" >> /home/CJ/.ssh/authorized_keys

chown -R CJ:CJ /home/CJ/.ssh
chmod g-rwx /home/CJ/.ssh
chmod o-rwx /home/CJ/.ssh
