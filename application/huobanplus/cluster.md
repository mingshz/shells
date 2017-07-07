# 集群部署
## 所有机器互相信任
` firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.18.119.55" accept'
`

`firewall-cmd --reload
`
以及信任LB
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.18.119.56" accept'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="112.74.139.48" accept'
firewall-cmd --permanent --add-port=10000/tcp

所有服务器都互相hosts所有集群的名字


## 设定其中一台为中心服务器
c1.domain
是我们固定为它所取的名字
c1将负责处理我们的资源，以及维持JMS
其他节点的命名为
c1_n?.domain
### 安装activeMQ
./installActiveMQ.sh

允许操作IP 访问该port即可访问实例

### 开放资源访问用户
usermod -s /bin/bash -d /home/huotu/home huotu
mkdir /home/huotu/home
chown huotu:huotu /home/huotu/home
sudo -u huotu ssh-keygen
### 开放redis

## 使用支持集群的server和context


