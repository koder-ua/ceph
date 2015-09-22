#! /bin/bash

################################################
#      for first time work only in ubuntu      #

 sudo apt-get install --assume-yes ruby build-essential ruby1.9.1 ruby1.9.1-dev libxml2 zlib-bin zlib1g zlib1g-dev iptables-persistent



################################################################
#      need investigate how to install without bundler         #
# cat Gemfile | grep -w gem | sed "s/,/ /g" | awk {'print $2'} #
################################################################

    cd /tmp/TMP_INSTALL_ceph/ceph/
    mkdir /tmp/TMP_INSTALL_ceph/log/

    sudo  gem install -q bundler >> /tmp/TMP_INSTALL_ceph/log/gem_install.log
    bundle install >> /tmp/TMP_INSTALL_ceph/log/bundle_install.log


 # Install Puppet modules

    sudo  puppet module install puppetlabs-stdlib
    sudo  puppet module install puppetlabs-apt
    sudo  puppet module install puppetlabs-inifile
    sudo  puppet module install puppetlabs-apache
    sudo  puppet module install puppetlabs-concat
    sudo  puppet module install puppetlabs-firewall

    sudo cp -rf /tmp/TMP_INSTALL_ceph/ceph /etc/puppetlabs/code/modules/
    sudo cd /etc/puppetlabs/code/modules/ceph/

###############################################################

    sudo puppet apply ceph.puppet

