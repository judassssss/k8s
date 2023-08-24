#!/bin/bash
PATH_FILE_VNG_TRUST_PEM=$(readlink -f VNG.trust.pem)
PATH_FILE_USER_CER_PEM=$(readlink -f user.cer.pem)
PATH_FILE_USER_KEY_PEM=$(readlink -f user.key.pem)
PATH_FILE_LOG=$1

# Read file info.md
read_file_info() {
while read -r line; do
    if [[ "$(awk '{print $1}' <<< "$line")" == 'TOPIC:' ]]; then
        TOPIC="$(awk -F\" '{print $2}' <<< "$line")"
    elif [[ "$(awk '{print $1}' <<< "$line")" == 'BOOTSTRAP_SERVERS:' ]]; then
        SERVER="$(awk -F\" '{print $2}' <<< "$line")"
        SERVER=$(echo $SERVER | sed 's/,/","/g')
    else
        continue
    fi
done < info.md
}

check_file_log_exist() {
    if [[ ! -f $PATH_FILE_LOG ]]; then
        echo "Missing file log ! Please input file"
        exit 1
    fi
}

debian_filebeat() {

    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    sudo apt-get install apt-transport-https
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
    sudo apt-get update && sudo apt-get install filebeat

    sudo bash -c 'echo "" > /etc/filebeat/filebeat.yml'

    sudo bash -c 'cat > /etc/filebeat/filebeat.yml' << EOF
filebeat.inputs:
- type: log
  paths:
    - $PATH_FILE_LOG

output.kafka:
  hosts: ["$SERVER"]
  topic: $TOPIC
  partition.round_robin:
    reachable_only: false
  required_acks: 1
  compression: gzip
  max_message_bytes: 1000000
  ssl.certificate_authorities:
    - $PATH_FILE_VNG_TRUST_PEM
  ssl.certificate: "$PATH_FILE_USER_CER_PEM"
  ssl.key: "$PATH_FILE_USER_KEY_PEM"
  ssl.verification_mode: "none"
logging.level: info
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  name: filebeat
  keepfiles: 7
  permissions: 0644
EOF

}

rpm_filebeat() {

    sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
    sudo bash -c 'cat > /etc/yum.repos.d/filebeat.reop' << EOF
[elastic-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
    sudo yum install filebeat

    sudo bash -c 'cat > /etc/filebeat/filebeat.yml' << EOF
filebeat.inputs:
- type: log
  paths:
    - $PATH_FILE_LOG

output.kafka:
  hosts: ["$SERVER"]
  topic: $TOPIC
  partition.round_robin:
    reachable_only: false
  required_acks: 1
  compression: gzip
  max_message_bytes: 1000000
  ssl.certificate_authorities:
    - $PATH_FILE_VNG_TRUST_PEM
  ssl.certificate: "$PATH_FILE_USER_CER_PEM"
  ssl.key: "$PATH_FILE_USER_KEY_PEM"
  ssl.verification_mode: "none"
logging.level: info
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  name: filebeat
  keepfiles: 7
  permissions: 0644
EOF


}

check_file_log_exist
read_file_info

if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]
    then
        echo " It's a Debian based system"
        debian_filebeat
elif [ "$(grep -Ei 'fedora|redhat|centos' /etc/*release)" ]
    then
        echo "It's a RedHat based system."
        rpm_filebeat
else
    echo "This script doesn't support Filebeat installation on this OS."
fi
echo "Intallation completed. Happy logging!"