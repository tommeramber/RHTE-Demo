# Instructions
## 0. [Install Service Mesh](https://docs.openshift.com/container-platform/4.10/service_mesh/v2x/installing-ossm.html#ossm-install-ossm-operator_installing-ossm)

## 1. Service Mesh Setup
```bash
cd yamls
oc apply -f ns-carinfo.yaml
oc apply -f ns-smcp.yaml
oc apply -f smcp.yaml
oc apply -f smmr.yaml
cd ..
```
## 2. Run AnsibleCarinfo Playbook
```bash
git clone https://github.com/ooichman/AnsibleCarinfo.git

cd AnsibleCarinfo

cp ~/.kube/config kubeconfig

podman run -ti --rm --name ose-openshift -e OPTS="-v -e app_version=1-1 -e namespace=carinfo" -v ${HOME}/AnsibleCarinfo/src/:/opt/app-root/src/:Z,rw -v ${HOME}/AnsibleCarinfo/:/opt/app-root/ose-ansible/:Z,ro -e PLAYBOOK_FILE=/opt/app-root/ose-ansible/playbook.yaml -e K8S_AUTH_KUBECONFIG=/opt/app-root/ose-ansible/kubeconfig -e INVENTORY=/opt/app-root/ose-ansible/inventory -e K8S_AUTH_API_KEY=$(oc whoami -t)  -e DEFAULT_LOCAL_TMP=/tmp/  -e K8S_AUTH_HOST=$(oc whoami --show-server) -e K8S_AUTH_VALIDATE_CERTS=false quay.io/two.oes/ose-openshift
```

## 3. Gateway & VirtualService & DestinationRule
```bash
suffix="apps.$(oc whoami --show-console | awk -F'apps.' '{print $2}')"

sed "s,SUFFIX,apps.$(oc whoami --show-console | awk -F'apps.' '{print $2}'),g" yamls/gateway.yaml | oc apply -f - 
```

## 4. Generate traffic
```bash
ROUTE=$(echo "carinfo.$suffix")

curl -k -s -H 'Content-Type: application/json' -d '{"Manufacture": "Alfa Romeo","Module": "Jullieta"}' ${ROUTE}/query | jq
```


## 5. Statistics of proper state
```bash
cd ~/curl-statistics
curl -w "@loop_curl_statistics.txt" -k -s -H 'Content-Type: application/json' -d '{"Manufacture": "Alfa Romeo","Module": "Jullieta"}' ${ROUTE}/query | jq
```


## 6. Inject Delay
```bash
sed "s,SUFFIX,apps.$(oc whoami --show-console | awk -F'apps.' '{print $2}'),g" yamls/virtual-service-with-delay.yaml| oc apply -f -

for i in {0..1000} ; do curl -k -s -H 'Content-Type: application/json' -d '{"Manufacture": "Alfa Romeo","Module": "Jullieta"}' ${ROUTE}/query | jq ; done
```

![screenshot](https://user-images.githubusercontent.com/60185557/211827869-0a7accf9-2fe9-4a28-9ea5-91f31930b437.PNG)

