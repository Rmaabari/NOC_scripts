
NETBOX=192.168.42.12:8000
OSD2=192.168.42.12
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
    echo "Issued disk/s:"
    echo "$DISK"
else
    printf "No OSDs down found \n"
fi


#Issued U position, Also, find out how to grep only one server name and his related lines using

POS=$(curl -s --header "authorization: Token 0123456789abcdef0123456789abcdef01234567" http://192.168.42.12:8000/api/dcim/devices/1/)
PSO=$(echo $POS grep $HOST | grep -o '"position":..'| tr -d 'position:"')
echo "U position: $PSO"

SERIAL=$(curl -s --header "authorization: Token 0123456789abcdef0123456789abcdef01234567" http://192.168.42.12:8000/api/dcim/devices/1/ | grep -o '"serial"':........... | tr -d '"' | sed 's/^.*://')
echo "Serial number:"
echo "$SERIAL"
