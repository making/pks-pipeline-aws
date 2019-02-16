```
cp terraform.tfvars.sample terraform.tfvars
terraform init
terraform plan -var cluster_name=foo -out plan
terraform apply plan

pks create-cluster $(terraform output cluster_name) -e $(terraform output k8s_master_lb_dns_name) -p small -n 1 --wait

terraform plan -var cluster_name=foo -var instance_ids='["i-xxxxxxxxxxxxxxxxx"]' -out plan
terraform apply plan

pks get-credentials $(terraform output cluster_name)

kubectl cluster-info
kubectl get pod --all-namespaces


kubectl run hello-pks --image=making/hello-pks:0.0.3 --port=8080
kubectl expose deployment hello-pks --port=8080 --target-port=8080 --type=LoadBalancer


kubectl delete service hello-pks
kubectl delete deployment hello-pks


terraform destroy -force -var cluster_name=foo
```