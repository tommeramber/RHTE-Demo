# Instructions
1. Service Mesh Setup
```bash
oc apply -f ns-carinfo.yaml
oc apply -f ns-smcp.yaml
oc apply -f smcp.yaml
oc apply -f smmr.yaml
```
2. Run AnsibleCarinfo Playbook
