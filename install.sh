#! /bin/bash

 MONS="mon_host1 mon_host2 mon_host3"
 CLIENTS="client_host1 client_host2"
 OSDS="osd_host1 osd_host2 osd_host3"

### WARNING !! use format <OSD_DISK>:<OSD_JORNAL>  for example sda:sdb1 sdc:sdb2 ....
 DISKS='sda:sdb1 sdd:sdb2 sdf:sdb3 sde:sdb4 sdg: sdk:sdb5 sdh:sdi1'

 DST='/tmp/dst_ceph'
      mkdir -p $DST
      cd $DST

 git clone https://github.com/stackforge/puppet-ceph.git
 git clone -b install_script https://github.com/vsolovei/ceph.git

    cp -rf $DST/ceph/metadata.json $DST/puppet-ceph
    cp -rf $DST/ceph/deploy.sh $DST/puppet-ceph
    cp -rf $DST/ceph/gen.py $DST/puppet-ceph
#    cp -rf $DST/ceph/Puppetfile $DST/puppet-ceph
    cp -rf $DST/ceph/ceph.puppet $DST/puppet-ceph

        rm -rf $DST/ceph
        mv puppet-ceph ceph

  cd ceph/

   ADMIN_KEY=`gen.py`
   MON_KEY=`gen.py`
   OSD_KEY=`gen.py`
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
        ssh $m 'mkdir -p /tmp/dst_ceph/'
        scp $DST/ceph.tar.gz $m:/tmp/dst_ceph/ceph.tar.gz
        ssh $m 'cd /tmp/dst_ceph; tar xvfz /tmp/dst_ceph/ceph.tar.gz'
        ssh $m '/tmp/dst_ceph/ceph/deploy.sh'
        ssh $m 'rm -f /tmp/dst_ceph/ceph.tar.gz';
    done

 for o in $OSDS; do
        echo 'copy tarball to ' $o ' and start deploying'
        ssh $o 'mkdir -p /tmp/dst_ceph'
        scp $DST/ceph.tar.gz $o:/tmp/dst_ceph/ceph.tar.gz
        ssh $o 'cd /tmp/dst_ceph; tar xvfz /tmp/dst_ceph/ceph.tar.gz'
        ssh $o '/tmp/dst_ceph/ceph/deploy.sh'
        ssh $o 'rm -f /tmp/dst_ceph/ceph.tar.gz';
    done

 for c in $CLIENTS; do
        echo 'copy tarball to ' $c ' and start deploying'
        ssh $c 'mkdir /tmp/dst_ceph'
        scp $DST/ceph.tar.gz $j:/tmp/dst_ceph/ceph.tar.gz
        ssh $c 'cd /tmp/dst_ceph; tar xvfz /tmp/dst_ceph/ceph.tar.gz'
        ssh $c '/tmp/dst_ceph/ceph/deploy.sh'
        ssh $c 'rm -f /tmp/dst_ceph/ceph.tar.gz';
    done


