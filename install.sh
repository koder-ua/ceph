#! /bin/bash

 MONS="mon_host1 mon_host2 mon_host3"
 CLIENTS="client_host1 client_host2"
 OSDS="osd_host1 osd_host2 osd_host3"

### WARNING !! use format <OSD_DISK>:<OSD_JORNAL>  for example sda:sdb1 sdc:sdb2 ....
 DISKS='sda:sdb1 sdd:sdb2 sdf:sdb3 sde:sdb4 sdg: sdk:sdb5 sdh:sdi1'

 DST='/root/dst_ceph'
      mkdir -p $DST
      cd $DST

 git clone https://github.com/stackforge/puppet-ceph.git
 git clone git@github.com:vsolovei/ceph.git

    cp -rf $DST/ceph/metadata.json $DST/puppet-ceph
    cp -rf $DST/ceph/deploy.sh $DST/puppet-ceph
#    cp -rf $DST/ceph/Puppetfile $DST/puppet-ceph
    cp -rf $DST/ceph/ceph.puppet $DST/puppet-ceph

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

  UUID=`uuidgen`
  MONS_CEPH_PUPPET=`echo $MONS | sed "s/ /,/g"`
  OSDS_CEPH_PUPPET=`echo $OSDS | sed "s/ /,/g"`
  CLIENTS_CEPH_PUPPET=`echo $CLIENTS | sed "s/ /,/g"`


     sed -i "s/UUID/$UUID/g" ceph.puppet
     sed -i "s/ADMIN_KEY/$ADMIN_KEY/g" ceph.puppet
     sed -i "s/MON_KEY/$MON_KEY/g" ceph.puppet
     sed -i "s/OSD_KEY/$OSD_KEY/g" ceph.puppet
     sed -i "s/MON_HOSTS/'$MONS_CEPH_PUPPET'/g" ceph.puppet

     sed -i "s/\/OSDS\//$OSDS_CEPH_PUPPET/g" ceph.puppet
     sed -i "s/\/MONS\//$MONS_CEPH_PUPPET/g" ceph.puppet
     sed -i "s/\/CLIENTS\//$CLIENTS_CEPH_PUPPET/g" ceph.puppet


    for i in $DISKS; do
          A=$(echo $i | awk -F ":" {'print $1'})
          B=$(echo $i | awk -F ":" {'print $2'})
       sed -i "s/DISKS/DISKS\n\t'\/dev\/$A':\n\t\t journal => '$B';/g" ceph.puppet;
    done
       sed -i "s/DISKS/#/g" ceph.puppet


 cd ..
     tar cfvz ceph.tar.gz ceph


 for m in $MONS; do
        echo 'copy tarball to ' $m ' and start deploying'
        ssh $m 'mkdir /root/dst_ceph'
        scp caph.tar.gz $m:/root/dst_ceph/ceph.tar.gz
        ssh $m 'tar xvfz /root/dst_ceph/ceph.tar.gz'
        ssh $m '/root/dst_ceph/deploy.sh'
        ssh $m 'rm -f ceph.tar.gz';
    done

 for o in $OSDS; do
        echo 'copy tarball to ' $o ' and start deploying'
        ssh $o 'mkdir /root/dst_ceph'
        scp caph.tar.gz $o:/root/dst_ceph/ceph.tar.gz
        ssh $o 'tar xvfz /root/dst_ceph/ceph.tar.gz'
        ssh $o '/root/dst_ceph/deploy.sh'
        ssh $o 'rm -f ceph.tar.gz';
    done

 for c in $CLIENTS; do
        echo 'copy tarball to ' $c ' and start deploying'
        ssh $c 'mkdir /root/dst_ceph'
        scp caph.tar.gz $j:/root/dst_ceph/ceph.tar.gz
        ssh $c 'tar xvfz /root/dst_ceph/ceph.tar.gz'
        ssh $c '/root/dst_ceph/deploy.sh'
        ssh $c 'rm -f ceph.tar.gz';
    done
