#! /bin/bash

 MONS="mon_host1 mon_host2 mon_host3"
 CLIENTS="client_host1 client_host2"
 OSDS="osd_host1 osd_host2 osd_host3"

###############################################################################
# if you want to specify KEYs, insert them here
# else, leave this parameters empty and keys will be generated automatically

  ADMIN_KEY=''
  MON_KEY=''
  OSD_KEY=''

###############################################################################


### WARNING !! use format <OSD_DISK>:<OSD_JORNAL>  for example sda:sdb1 sdc:sdb2 ....
 DISKS='sda:sdb1 sdd:sdb2 sdf:sdb3 sde:sdb4 sdg: sdk:sdb5 sdh:sdi1'




 TMP_INSTALL='/tmp/TMP_INSTALL_ceph'
      mkdir -p $TMP_INSTALL
      cd $TMP_INSTALL

 git clone https://github.com/stackforge/puppet-ceph.git
 git clone -b install_script https://github.com/vsolovei/ceph.git

    cp -rf $TMP_INSTALL/ceph/metadata.json $TMP_INSTALL/puppet-ceph
    cp -rf $TMP_INSTALL/ceph/deploy.sh $TMP_INSTALL/puppet-ceph
    cp -rf $TMP_INSTALL/ceph/gen.py $TMP_INSTALL/puppet-ceph
#    cp -rf $TMP_INSTALL/ceph/Puppetfile $TMP_INSTALL/puppet-ceph
    cp -rf $TMP_INSTALL/ceph/ceph.puppet $TMP_INSTALL/puppet-ceph

        rm -rf $TMP_INSTALL/ceph
        mv puppet-ceph ceph

  cd ceph/


    if [ "$ADMIN_KEY" == "" ]
     then
     ADMIN_KEY=`$TMP_INSTALL/ceph/gen.py`
    fi
 echo 'ADMIN_KEY = '$ADMIN_KEY

    if [ "$MON_KEY" == "" ]
     then
     MON_KEY=`$TMP_INSTALL/ceph/gen.py`
    fi
 echo 'MON_KEY = '$MON_KEY

    if [ "$OSD_KEY" == "" ]
     then
     OSD_KEY=`$TMP_INSTALL/ceph/gen.py`
    fi
 echo 'OSD_KEY = '$OSD_KEY


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
        ssh $m 'mkdir -p /tmp/TMP_INSTALL_ceph/'
        scp $TMP_INSTALL/ceph.tar.gz $m:/tmp/TMP_INSTALL_ceph/ceph.tar.gz
        ssh $m 'cd /tmp/TMP_INSTALL_ceph; tar xvfz /tmp/TMP_INSTALL_ceph/ceph.tar.gz'
        ssh $m '/tmp/TMP_INSTALL_ceph/ceph/deploy.sh'
        ssh $m 'rm -f /tmp/TMP_INSTALL_ceph/ceph.tar.gz';
    done

 for o in $OSDS; do
        echo 'copy tarball to ' $o ' and start deploying'
        ssh $o 'mkdir -p /tmp/TMP_INSTALL_ceph'
        scp $TMP_INSTALL/ceph.tar.gz $o:/tmp/TMP_INSTALL_ceph/ceph.tar.gz
        ssh $o 'cd /tmp/TMP_INSTALL_ceph; tar xvfz /tmp/TMP_INSTALL_ceph/ceph.tar.gz'
        ssh $o '/tmp/TMP_INSTALL_ceph/ceph/deploy.sh'
        ssh $o 'rm -f /tmp/TMP_INSTALL_ceph/ceph.tar.gz';
    done

 for c in $CLIENTS; do
        echo 'copy tarball to ' $c ' and start deploying'
        ssh $c 'mkdir /tmp/TMP_INSTALL_ceph'
        scp $TMP_INSTALL/ceph.tar.gz $j:/tmp/TMP_INSTALL_ceph/ceph.tar.gz
        ssh $c 'cd /tmp/TMP_INSTALL_ceph; tar xvfz /tmp/TMP_INSTALL_ceph/ceph.tar.gz'
        ssh $c '/tmp/TMP_INSTALL_ceph/ceph/deploy.sh'
        ssh $c 'rm -f /tmp/TMP_INSTALL_ceph/ceph.tar.gz';
    done


