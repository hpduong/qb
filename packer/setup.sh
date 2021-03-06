#!/usr/bin/env bash

set -e

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y build-essential cmake swig python-software-properties
sudo apt-get install -y git wget vim tmux unzip
sudo apt-get install -y libboost-program-options-dev libboost-python-dev libtool libboost-all-dev
sudo apt-get install -y liblzma-dev libpq-dev liblz4-tool
sudo apt-get install -y default-jre default-jdk

# Install Docker
sudo apt-get install -y apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee --append /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get purge lxc-docker
sudo apt-get install -y linux-image-extra-$(uname -r) apparmor
sudo apt-get install -y docker-engine
sudo usermod -aG docker ubuntu

sudo add-apt-repository ppa:keithw/mosh
sudo apt-get update
sudo apt-get install -y mosh

# Install Python 3.5 and the Scipy Stack
wget http://repo.continuum.io/archive/Anaconda3-4.0.0-Linux-x86_64.sh
bash Anaconda3-4.0.0-Linux-x86_64.sh -b
rm Anaconda3-4.0.0-Linux-x86_64.sh
echo "export PATH=/home/ubuntu/anaconda3/bin:$PATH" >> ~/.bashrc
echo "export PYTHONPATH=$PYTHONPATH:/home/ubuntu/dependencies/spark-1.6.1-bin-hadoop2.6/python" >> ~/.bashrc
echo "export SPARK_HOME=/home/ubuntu/dependencies/spark-1.6.1-bin-hadoop2.6" >> ~/.bashrc
cat /home/ubuntu/aws-qb-env.sh >> ~/.bashrc

# Install Python dependencies
/home/ubuntu/anaconda3/bin/pip install -r requirements.txt

# Install KenLM
mkdir ~/dependencies
cd ~/dependencies
git clone https://github.com/kpu/kenlm.git
cd kenlm
cmake .
make
sudo make install
/home/ubuntu/anaconda3/bin/python3 setup.py install
cd ~/

# Install Apache Spark
wget http://d3kbcqa49mib13.cloudfront.net/spark-1.6.1-bin-hadoop2.6.tgz
tar -xvzf spark-1.6.1-bin-hadoop2.6.tgz
rm spark-1.6.1-bin-hadoop2.6.tgz
mv spark-1.6.1-bin-hadoop2.6 ~/dependencies
echo "export PYSPARK_PYTHON=/home/ubuntu/anaconda3/bin/python3" >> ~/.bashrc
echo "#!/usr/bin/env bash" >> ~/dependencies/spark-1.6.1-bin-hadoop2.6/conf/spark-env.sh
echo "export PYSPARK_PYTHON=/home/ubuntu/anaconda3/bin/python3" >> ~/dependencies/spark-1.6.1-bin-hadoop2.6/conf/spark-env.sh

# Install Utilities
/home/ubuntu/anaconda3/bin/pip install glances

# Create aws credentials directory
mkdir -p /home/ubuntu/.aws

# Create Luigi logging directory
sudo mkdir /var/log/luigi
sudo chown ubuntu /var/log/luigi

# Configure ulimits
sudo mv /home/ubuntu/limits.conf /etc/security/limits.conf
