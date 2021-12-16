OSD2=192.168.42.12
FILE=$(podman exec -it ceph-mon cat /var/log/ceph/osd_down1.txt)
VOLUME_LIST=$(podman exec -it ceph-mon ceph-volume lvm list | grep $(cat osd_down1.txt) -A 16 | grep devices | awk '{print $2}')

## OSDs Down ##
OSDS_DOWN=$(podman exec -it ceph-mon ceph osd tree | grep down |awk '{print $4}')

## Take list of down OSDs and output to osd_down1.txt file ##
podman exec -it ceph-mon ceph osd tree | grep down |awk '{print $4}' > /var/log/ceph/osd_down1.txt

## output entire ceph osd find $osd cmd ##
for line in $(podman exec -it ceph-mon cat /var/log/ceph/osd_down1.txt)
do
    podman exec -it ceph-mon ceph osd find $line > /var/log/ceph/osd_down2.txt
done

## Issued servers list  followed by echo cmd below ##
HOST=$(for line in $(podman exec -it ceph-mon cat /var/log/ceph/osd_down1.txt)
    do podman exec -it ceph-mon ceph osd find $line | grep host | awk '{print $ 2}' | sort -u | tr -d '",'
done)
#    podman exec -it ceph-mon ceph osd find $(cat /var/log/ceph/osd_down1.txt) | grep host | awk '{print $ 2}' | sort -u | tr -d '",'

DISK=$(sshpass -p vagrant ssh -l root $OSD2 podman exec -it ceph-mon ceph-volume lvm list | grep $(cat osd_down1.txt) -A 16 | grep devices | awk '{print $2}')

echo "Issued server/s:"
echo "$HOST"
echo "OSDs down:"
echo "$OSDS_DOWN"
echo "Issued disk/s: $DISK"
