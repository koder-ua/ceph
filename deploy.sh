#! /bin/bash

################################################
#      for first time work only in ubuntu      #
 apt-get install ruby build-essential ruby1.9.1 ruby1.9.1-dev libxml2 zlib-bin zlib1g zlib1g-dev



################################################################
#      need investigate how to install without bundler         #
# cat Gemfile | grep -w gem | sed "s/,/ /g" | awk {'print $2'} #
################################################################

     sudo gem install bundler >> /root/gem_install.log
     bundle install >> /root/bundle_install.log

  # Install Puppet modules

     puppet module install puppetlabs-stdlib
     puppet module install puppetlabs-apt
     puppet module install puppetlabs-inifile
     puppet module install puppetlabs-apache
     puppet module install puppetlabs-concat
     puppet module install puppetlabs-firewall

     cp -rf $DST/ceph /etc/puppetlabs/code/modules/
     cd /etc/puppetlabs/code/modules/ceph

###############################################################

     puppet apply /tmp/ceph.puppet

