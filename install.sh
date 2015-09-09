#! /bin/bash

MONS="mon_host1 mon_host2 mon_host3"
CLIENTS="client_host1 client_host2"
OSDS="osd_host1 osd_host2 osd_host3"



######### on the node ###########
#    cd /root/
# mkdir dst_ceph/

  DST='/root/dst_ceph'
  mkdir -p $DST
  cd $DST

 git clone https://github.com/stackforge/puppet-ceph.git
 git clone git@github.com:vsolovei/ceph.git
    cp -rf $DST/ceph/metadata.json $DST/puppet-ceph
    cp -rf $DST/ceph/Puppetfile $DST/puppet-ceph



   mv puppet-ceph ceph
   cd puppet-ceph/

 sudo apt-get install ruby build-essential ruby1.9.1 ruby1.9.1-dev libxml2 zlib zlib-bin zlib1g zlib1g-dev
 sudo gem install bundler
 bundle install


        # Install Puppet modules

     puppet module install puppetlabs-stdlib
     puppet module install puppetlabs-apt
     puppet module install puppetlabs-inifile
     puppet module install puppetlabs-apache
     puppet module install puppetlabs-concat
     puppet module install puppetlabs-firewall

 cp -rf ceph /etc/puppet/modules/

     puppet apply /tmp/ceph.puppet
