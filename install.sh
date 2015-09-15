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
    cp -rf $DST/ceph/deploy.sh $DST/puppet-ceph
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


 for m in $MONS; do
        echo 'copy tarball to ' $m ' and start deploying'
        sshpass ssh $m '/root/dst_ceph'
        scp caph.tar.gz $m:/root/dst_ceph/ceph.tar.gz
        sshpass ssh $m 'tar xvfz ceph.tar.gz'
        sshpass ssh $m '/root/dst_ceph/deploy.sh'
        sshpass ssh $m 'rm -f ceph.tar.gz';
    done


 for o in $OSDS; do
        echo 'copy tarball to ' $o ' and start deploying'
        sshpass ssh $o '/root/dst_ceph'
        scp caph.tar.gz $o:/root/dst_ceph/ceph.tar.gz
        sshpass ssh $o 'tar xvfz ceph.tar.gz'
        sshpass ssh $o '/root/dst_ceph/deploy.sh'
        sshpass ssh $o 'rm -f ceph.tar.gz';
    done


 for c in $CLIENTS; do
        echo 'copy tarball to ' $c ' and start deploying'
        sshpass ssh $c '/root/dst_ceph'
        scp caph.tar.gz $j:/root/dst_ceph/ceph.tar.gz
        sshpass ssh $c 'tar xvfz ceph.tar.gz'
        sshpass ssh $c '/root/dst_ceph/deploy.sh'
        sshpass ssh $c 'rm -f ceph.tar.gz';
    done
