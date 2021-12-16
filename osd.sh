CEPH_OSD_TREE=$(podman exec -it ceph-mon ceph osd tree | grep down)
FILE=$(podman exec -it ceph-mon cat /var/log/ceph/osd_down1.txt)
VOLUME_LIST=$(podman exec -it ceph-mon ceph-volume lvm list | grep $(cat osd_down1.txt) -A 16 | grep devices | awk '{print $2}')

if [[ -n $CEPH_OSD_TREE ]]
then
    OSDS_DOWN=$(podman exec -it ceph-mon ceph osd tree | grep down |awk '{print $4}')
    podman exec -it ceph-mon ceph osd tree | grep down |awk '{print $4}' > /var/log/ceph/osd_down1.txt
    for line in $(podman exec -it ceph-mon cat /var/log/ceph/osd_down1.txt)
do
    podman exec -it ceph-mon ceph osd find $line > /var/log/ceph/osd_down2.txt
done
HOST=$(for line in $(podman exec -it ceph-mon cat /var/log/ceph/osd_down1.txt)
    do podman exec -it ceph-mon ceph osd find $line | grep host | awk '{print $ 2}' | sort -u | tr -d '",'
done| uniq )

DISK=$(sshpass -p vagrant ssh -l root $OSD2 podman exec -it ceph-mon ceph-volume lvm list | grep $(cat osd_down1.txt) -A 16 | grep devices | awk '{print $2}')
    echo "Issued server/s:"
    echo "$HOST"
    echo "OSDs down:"
    echo "$OSDS_DOWN"
    echo "Issued disk/s: $DISK"
else
    printf "No OSDs down found \n"
fi
