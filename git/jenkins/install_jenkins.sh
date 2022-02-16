#/bin/bash
#Create name space for Jenkins
kubectl create namespace jenkins

#Get the chart for Jenkins
helm repo add jenkinsci https://charts.jenkins.io
helm repo update

#Create persistence volume for Jenkins
kubectl apply -f jenkins-volume.yaml
#Create Account for Jenkins
kubectl apply -f jenkins-sa.yaml

#Create Jenkins Container
chart=jenkinsci/jenkins
helm install jenkins -n jenkins -f jenkins-values.yaml $chart

#Password for Jenkins
jsonpath="{.data.jenkins-admin-password}"
secret=$(kubectl get secret -n jenkins jenkins -o jsonpath=$jsonpath)
echo $(echo $secret | base64 --decode)
jsonpath="{.spec.ports[0].nodePort}"
NODE_PORT=$(kubectl get -n jenkins -o jsonpath=$jsonpath services jenkins)
jsonpath="{.items[0].status.addresses[0].address}"
NODE_IP=$(kubectl get nodes -n jenkins -o jsonpath=$jsonpath)
echo http://$NODE_IP:$NODE_PORT/login

#Port forward
pod_name=kubectl -n jenkins get --no-headers=true pods -o name | awk -F "/" '{print $2}'
kubectl -n jenkins port-forward $pod_name 8080:8080