#!/bin/bash
#Create name space for Jenkins
/usr/local/bin/kubectl create namespace jenkins

#Get the chart for Jenkins
/usr/local/bin/helm repo add jenkinsci https://charts.jenkins.io
/usr/local/bin/helm repo update

#Create persistence volume for Jenkins
/usr/local/bin/kubectl apply -f /home/ec2-user/git/jenkins/jenkins-volume.yaml
#Create Account for Jenkins
/usr/local/bin/kubectl apply -f /home/ec2-user/git/jenkins/jenkins-sa.yaml

#Create Jenkins Container
chart=jenkinsci/jenkins
/usr/local/bin/helm install jenkins -n jenkins -f /home/ec2-user/git/jenkins/jenkins-values.yaml $chart

#Password for Jenkins
jsonpath="{.data.jenkins-admin-password}"
secret=$(/usr/local/bin/kubectl get secret -n jenkins jenkins -o jsonpath=$jsonpath)
echo $(echo $secret | base64 --decode)
jsonpath="{.spec.ports[0].nodePort}"
NODE_PORT=$(/usr/local/bin/kubectl get -n jenkins -o jsonpath=$jsonpath services jenkins)
jsonpath="{.items[0].status.addresses[0].address}"
NODE_IP=$(/usr/local/bin/kubectl get nodes -n jenkins -o jsonpath=$jsonpath)
echo http://$NODE_IP:$NODE_PORT/login

#Port forward
pod_name=/usr/local/bin/kubectl -n jenkins get --no-headers=true pods -o name | awk -F "/" '{print $2}'
/usr/local/bin/kubectl -n jenkins port-forward $pod_name 8080:8080