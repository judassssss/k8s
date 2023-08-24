# run script install filebeat
sudo chmod u+x filebeat.sh
sudo ./filebeat.sh /path/to/file/log
sudo systemctl enable filebeat.service
sudo systemctl start filebeat.service