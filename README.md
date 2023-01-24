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

mkdir src

podman run -ti --rm --name ose-openshift -e OPTS="-v -e app_version=1-1 -e namespace=carinfo" -v $(pwd)/src/:/opt/app-root/src/:Z,rw -v $(pwd)/:/opt/app-root/ose-ansible/:Z,ro -e PLAYBOOK_FILE=/opt/app-root/ose-ansible/playbook.yaml -e K8S_AUTH_KUBECONFIG=/opt/app-root/ose-ansible/kubeconfig -e INVENTORY=/opt/app-root/ose-ansible/inventory -e K8S_AUTH_API_KEY=$(oc whoami -t)  -e DEFAULT_LOCAL_TMP=/tmp/  -e K8S_AUTH_HOST=$(oc whoami --show-server) -e K8S_AUTH_VALIDATE_CERTS=false quay.io/two.oes/ose-openshift
```

## 3. Patch the deployment and the statefulset with the 'inject' annotations :
```bash

oc patch statefulset mariadb-1-1 -p '{ "spec": { "template": { "metadata": { "annotations": {"sidecar.istio.io/inject": "true"}}}}}'
sleep 5
oc patch deployment dbapi-1-1 -p '{ "spec": { "template": { "metadata": { "annotations": {"sidecar.istio.io/inject": "true"}}}}}'
oc patch deployment frontend-1-1 -p '{ "spec": { "template": { "metadata": { "annotations": {"sidecar.istio.io/inject": "true"}}}}}'

```


## 4. Gateway & VirtualService & DestinationRule
```bash
sed "s,SUFFIX,apps.$(oc whoami --show-console | awk -F'apps.' '{print $2}'),g" yamls/gateway.yaml | oc apply -f - 
```

## 5. Generate traffic
```bash
suffix="apps.$(oc whoami --show-console | awk -F'apps.' '{print $2}')"

ROUTE=$(echo -n 'http://' && echo "carinfo.$suffix")

curl -k -s -H 'Content-Type: application/json' -d '{"Manufacture": "Alfa Romeo","Module": "Jullieta"}' ${ROUTE}/query | jq
```


## 6. Statistics of proper state
```bash

cd curl-statistics

curl -w "@loop_curl_statistics.txt" -k -s -H 'Content-Type: application/json' -d '{"Manufacture": "Alfa Romeo","Module": "Jullieta"}' ${ROUTE}/query -o /dev/null

cd ..
```


## 7. Inject Delay
```bash

for i in {0..1000} ; do curl -w "@curl-statistics/loop_curl_statistics.txt" -k -s -H 'Content-Type: application/json' -d '{"Manufacture": "Alfa Romeo","Module": "Jullieta"}' ${ROUTE}/query -o /dev/null ;sleep 0.5 ;  done

sed "s,SUFFIX,apps.$(oc whoami --show-console | awk -F'apps.' '{print $2}'),g" yamls/virtual-service-with-error.yaml| oc apply -f -

```

![screenshot](https://user-images.githubusercontent.com/60185557/211831556-5020f83c-a83a-4e0e-a802-f16011f090c3.PNG)

