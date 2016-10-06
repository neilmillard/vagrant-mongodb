#!/usr/bin/env bash
# installs mongo from the official repos, for centos 7

# use official repo
cat > mongodb-org-3.2.repo <<EOF
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/3.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc
EOF
sudo mv mongodb-org-3.2.repo /etc/yum.repos.d/

# install mongo
sudo yum install -y mongodb-org

#permit SElinux if installed
# semanage port -a -t mongod_port_t -p tcp 27017

## default folders set in /etc/mongod.conf are
# storage.dbPath = /var/lib/mongo   # - for data
# systemLog.path = /var/log/mongodb # - for log files

# start mongo
sudo service mongod start

# and autostart
sudo chkconfig mongod on

# simple smoke test
tail -n 2 /var/log/mongodb/mongod.log
