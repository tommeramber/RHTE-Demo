nohup oc sniff $(oc get pod | awk '{print $1}' | grep dbapi) -p -o pcap/dbapi.pcap &
nohup oc sniff $(oc get pod | awk '{print $1}' | grep frontend) -p -o pcap/frontend.pcap &
nohup oc sniff $(oc get pod | awk '{print $1}' | grep mariadb) -p -o pcap/mariadb.pcap &
