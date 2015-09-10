#! /bin/bash

MONS="mon_host1 mon_host2 mon_host3"
CLIENTS="client_host1 client_host2"
OSDS="osd_host1 osd_host2 osd_host3"


  DST='/root/dst_ceph'
      mkdir -p $DST
      cd $DST

 git clone https://github.com/stackforge/puppet-ceph.git
 git clone git@github.com:vsolovei/ceph.git
    cp -rf $DST/ceph/metadata.json $DST/puppet-ceph
    cp -rf $DST/ceph/Puppetfile $DST/puppet-ceph

    rm -rf $DST/ceph
    mv puppet-ceph ceph

 cd ceph/


#######################################
#       !!!!!  WARNING  !!!!!         #
#      require package 'pwgen'        #

 ADMIN_KEY=`pwgen 40 1`
 MON_KEY=`pwgen 40 1`
 OSD_KEY=`pwgen 40 1`

#######################################
  MONS_CEPH_PUPPET=`echo $MONS | sed "s/ /,/g"`


     sed -i "s/ADMIN_KEY/$ADMIN_KEY/g" ceph.puppet
     sed -i "s/MON_KEY/$MON_KEY/g" ceph.puppet
     sed -i "s/OSD_KEY/$OSD_KEY/g" ceph.puppet
     sed -i "s/MONS/'$MONS_CEPH_PUPPET'/g" ceph.puppet



 cd ..

     tar cfvz ceph.tar.gz ceph

##############################
#    for i in $MONS; do      #
#        echo "MONS=$i";     #
#        done                #
##############################

#############################################
#       copy ceph.tar.gz to nodes           #
#             untar tarball                 #
#############################################


 mkdir -p /etc/puppetlabs/code/modules/
   cp -rf ceph /etc/puppetlabs/code/modules/
   cd /etc/puppetlabs/code/modules/ceph


 apt-get install ruby build-essential ruby1.9.1 ruby1.9.1-dev libxml2 zlib-bin zlib1g zlib1g-dev

################################################################
#                   need investigate                           #
# cat Gemfile | grep -w gem | sed "s/,/ /g" | awk {'print $2'} #
################################################################

    sudo gem install bundler
    bundle install

        # Install Puppet modules

     puppet module install puppetlabs-stdlib
     puppet module install puppetlabs-apt
     puppet module install puppetlabs-inifile
     puppet module install puppetlabs-apache
     puppet module install puppetlabs-concat
     puppet module install puppetlabs-firewall


###############################################################

     puppet apply /tmp/ceph.puppet
