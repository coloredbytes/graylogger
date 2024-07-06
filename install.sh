#!/usr/bin/env bash
# Dev: Joshua Ross
# Github: https://github.com/ColoredBytes
# Purpose: Graylog install script.

# Variables
HOST_IP=$(hostname -I | cut -d' ' -f1) # Get the IP address of the host machine
TMP=$(mktemp -d) # Create TMP directory
LOG_FILE="$TMP/errors.log"
CURDIR=$(pwd)
SUBFOLDER="conf"   # Replace this with the name of your subfolder

# script functions
error_exit() {
    echo "$1" 1>&2
    echo "An error occurred. Please check the log file at ${LOG_FILE} for more details."
    exit 1
}

mongo_systemd() {
    sudo systemctl daemon-reload
    sudo systemctl enable mongod
    sudo systemctl start mongod
    sudo systemctl status mongod
}

graylog_systemd() {
    sudo systemctl daemon-reload
    sudo systemctl enable graylog-server.service
    sudo systemctl start graylog-server.service
    sudo systemctl --type=service --state=active | grep graylog
}

OpenSearch_install() {
    sudo curl -SL https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/opensearch-2.x.repo -o /etc/yum.repos.d/opensearch-2.x.repo
    sudo sed -i "s/^gpgcheck=.*/gpgcheck=0/g" /etc/yum.repos.d/opensearch-2.x.repo
    sudo OPENSEARCH_INITIAL_ADMIN_PASSWORD=$(tr -dc A-Z-a-z-0-9_@#%^-_=+ < /dev/urandom | head -c${1:-32}) yum -y install opensearch
}

# -----------------------------------------------------------------------------------------------

echo "[+] Checking for root permissions"
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root"
    exit 1
fi

echo "[+] Checking for updates"
dnf upgrade -y

# -----------------------------------------------------------------------------------------------

# MongoDB Install
mv "$CURDIR/$SUBFOLDER/mongodb-org.repo" /etc/yum.repos.d/mongodb-org.repo
sudo yum install -y mongodb-org
sudo yum versionlock add mongodb-org
mongo_systemd

# -----------------------------------------------------------------------------------------------

# OpenSearch Install
OpenSearch_install

# Add OpenSearch Config.
cat > /graylog/opensearch/config/opensearch.yml <<EOF
cluster.name: graylog
node.name: ${HOSTNAME}
path.data: /var/lib/opensearch
path.logs: /var/log/opensearch
network.host: 0.0.0.0
discovery.seed_hosts: ["127.0.0.1"]
cluster.initial_master_nodes: ["127.0.0.1"]
action.auto_create_index: false
plugins.security.disabled: true
indices.query.bool.max_clause_count: 32768
EOF

# Enable JVM options.
sudo sed -i 's/-Xms[0-9]*g/-Xms8g/' /etc/opensearch/jvm.options
sudo sed -i 's/-Xmx[0-9]*g/-Xmx8g/' /etc/opensearch/jvm.options

# setting max files for opensearch
echo "[+] setting max files for opensearch"
sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' >> /etc/sysctl.conf

# Restart Opensearch Service
echo "[+] Reloading Opensearch Service"
systemctl daemon-reload
systemctl enable opensearch.service
systemctl start opensearch.service

# -----------------------------------------------------------------------------------------------

# Graylog Install
sudo rpm -Uvh https://packages.graylog2.org/repo/packages/graylog-6.0-repository_latest.rpm
sudo yum install graylog-server
sudo yum versionlock add graylog-server-6.0

# Create Secrets
SECRET=$(pwgen -N 1 -s 96)
echo -n "Enter Admin web interface Password: "
read passwd
ADMIN=$(echo $passwd | tr -d '\n' | sha256sum | cut -d" " -f1)
echo "Generated password salt is $SECRET"
echo "Generated admin hash is $ADMIN"

# Apply Secrets
echo "[+] Adjusting Graylog Server configuration file"
CONFIGSECRET="password_secret = $SECRET"
CONFIGADMIN="root_password_sha2 = $ADMIN"
echo "[+] replacing in configuration files"
sed -r "s/password_secret =/${CONFIGSECRET}/g" -i /etc/graylog/server/server.conf
sed -r "s/root_password_sha2 =/${CONFIGADMIN}/g" -i /etc/graylog/server/server.conf
sed -i 's/#http_bind_address = 127.0.0.1:9000/http_bind_address = 0.0.0.0:9000/g' /etc/graylog/server/server.conf

# Graylog systemd commands
graylog_systemd
