#!/bin/bash
sudo apt update -y &&
sudo apt install -y nginx
echo "Hello World ${self.public_ip}" > /var/www/html/index.html