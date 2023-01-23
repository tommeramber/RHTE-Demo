sed "s,SUFFIX,apps.$(oc whoami --show-console | awk -F'apps.' '{print $2}'),g" yamls/virtual-service-with-error.yaml| oc apply -f -
