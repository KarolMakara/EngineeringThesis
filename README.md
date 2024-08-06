## Known issues

Sometimes pvc waits for connection:
kubectl delete storageclasses.storage.k8s.io local-path

and restart terraform

## Install CNI

cd ansible
source ANSIBLE_ENV/bin/activate
ansible-playbook install_antrea.yml