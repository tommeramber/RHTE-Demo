# Instructions
1. Service Mesh Setup
```bash
oc apply -f ns-carinfo.yaml
oc apply -f ns-smcp.yaml
oc apply -f smcp.yaml
oc apply -f smmr.yaml
```
2. Run AnsibleCarinfo Playbook
```bash
git clone https://github.com/ooichman/AnsibleCarinfo.git

cd AnsibleCarinfo

cp ~/.kube/config kubeconfig

podman run -ti --rm --name ose-openshift -e OPTS="-v -e app_version=1-1 -e namespace=carinfo" -v ${HOME}/AnsibleCarinfo/src/:/opt/app-root/src/:Z,rw -v ${HOME}/AnsibleCarinfo/:/opt/app-root/ose-ansible/:Z,ro -e PLAYBOOK_FILE=/opt/app-root/ose-ansible/playbook.yaml -e K8S_AUTH_KUBECONFIG=/opt/app-root/ose-ansible/kubeconfig -e INVENTORY=/opt/app-root/ose-ansible/inventory -e K8S_AUTH_API_KEY=$(oc whoami -t)  -e DEFAULT_LOCAL_TMP=/tmp/  -e K8S_AUTH_HOST=$(oc whoami --show-server) -e K8S_AUTH_VALIDATE_CERTS=false quay.io/two.oes/ose-openshift
```

3. Gateway
```bash
suffix="apps.$(oc whoami --show-console | awk -F'apps.' '{print $2}')"

sed -i "s,SUFFIX,apps.$(oc whoami --show-console | awk -F'apps.' '{print $2}'),g" gateway.yaml

oc apply -f gateway.yaml
```
4. Generate traffic
```bash
oc get route -n rhte-service-mesh-control-plane | grep carinfo.$suffix
ROUTE=$(echo "carinfo.$suffix")
curl -k -s -H 'Content-Type: application/json' -d '{"Manufacture": "Alfa Romeo","Module": "Jullieta"}' ${ROUTE}/query | jq
```


5. Statistics of proper state
```bash
mkdir ~/curl-statistics; cd ~/curl-statistics ; touch loop_curl_statistics.txt

cat > loop_curl_statistics.txt << EOF
     time_namelookup:  %{time_namelookup}s\n
        time_connect:  %{time_connect}s\n
     time_appconnect:  %{time_appconnect}s\n
    time_pretransfer:  %{time_pretransfer}s\n
       time_redirect:  %{time_redirect}s\n
  time_starttransfer:  %{time_starttransfer}s\n
                     ----------\n
          time_total:  %{time_total}s\n
EOF

curl -w "@loop_curl_statistics.txt" -k -s -H 'Content-Type: application/json' -d '{"Manufacture": "Alfa Romeo","Module": "Jullieta"}' ${ROUTE}/query | jq
```
