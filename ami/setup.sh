#!/bin/sh

# Initialize a probcomp stack instance from the base AMI by running on
# that machine.  The base AMI we have been using is ami-80861296, namely
# ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20170414

set -Ceu

sudo apt-get update -qq

# XXX BEGIN KLUDGE https://bugs.launchpad.net/cloud-init/+bug/1309079
sudo rm /boot/grub/menu.lst
sudo update-grub-legacy-ec2 -y
sudo apt-get upgrade -qq
# XXX END KLUDGE https://bugs.launchpad.net/cloud-init/+bug/1309079

sudo apt-get install -qq lsb-release
sudo apt-get install -qq wget

wget http://probcomp.csail.mit.edu/ubuntu-prerelease/probcomp-ubuntu-20170815.asc
echo ad5ab6283116df2db33de5e1a39cba1072297c4c4b06152f29b36831dd2f2178 \
    probcomp-ubuntu-20170815.asc \
| sha256sum -c

sudo apt-key add probcomp-ubuntu-20170815.asc

echo deb http://probcomp.csail.mit.edu/ubuntu-prerelease \
    $(lsb_release -s -c) main \
| sudo tee /etc/apt/sources.list.d/probcomp.list
sudo apt-get update -qq
sudo apt-get install -qq probcomp-ubuntu-keyring
sudo apt-get install -qq python-bayeslite
sudo apt-get install -qq python-cgpm
sudo apt-get install -qq python-crosscat
sudo apt-get install -qq python-iventure
sudo apt-get install -qq python-pytest
sudo apt-get install -qq python-venture

sudo apt-get install -qq python-seaborn
sudo apt-get install -qq python-pip
sudo apt-get install -qq python-virtualenv
virtualenv --system-site-packages ~/venv
(
    set -Ceu
    . ~/venv/bin/activate
    pip install -U 'ipython<6' jupyter
    rm -rf ~/.jupyter
    jupyter notebook --generate-config
)

sudo apt-get install -qq letsencrypt

mkdir -p /home/ubuntu/notebook

# Make sure the Jupyter server starts when the machine boots
sudo rm -f /etc/rc.local
cat > etc-rc.local.tmp <<EOF
#!/bin/sh

set -Ceu

sudo -u ubuntu /home/ubuntu/restart-jupyter.sh

exit 0
EOF
chmod 755 etc-rc.local.tmp
sudo mv etc-rc.local.tmp /etc/rc.local

rm -f restart-jupyter.sh
cat > restart-jupyter.sh <<EOF
#!/bin/sh

set -Ceu

killall jupyter-notebook || true
rm -f /home/ubuntu/jupyter.nohup.out
cd /home/ubuntu/notebook
. ~/venv/bin/activate
nohup jupyter notebook --no-browser \
  --NotebookApp.iopub_data_rate_limit=10000000000 --ip=\* \
  > /home/ubuntu/jupyter.nohup.out &
EOF
chmod 755 restart-jupyter.sh
