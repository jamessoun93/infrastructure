cd /home/ec2-user/
sudo mkdir .ssh
sudo chmod 700 .ssh
sudo touch .ssh/authorized_keys
sudo chmod 600 .ssh/authorized_keys
sudo wget -O .ssh/authorized_keys https://github.com/jamessoun93.keys