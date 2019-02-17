```
CLUSTER_NAME=demo1

cp terraform.tfvars.sample terraform.tfvars

terraform init
terraform plan -var cluster_name=${CLUSTER_NAME} -state ${CLUSTER_NAME}.tfstate -out ${CLUSTER_NAME}.tfplan
terraform apply -state-out ${CLUSTER_NAME}.tfstate ${CLUSTER_NAME}.tfplan

pks create-cluster ${CLUSTER_NAME} -e $(terraform output -state ${CLUSTER_NAME}.tfstate k8s_master_lb_dns_name) -p small -n 1 --wait

terraform plan -var cluster_name=${CLUSTER_NAME} -var instance_ids='["Replacae with istance ids of Master vms"]' -state ${CLUSTER_NAME}.tfstate -out ${CLUSTER_NAME}.tfplan
terraform apply -state-out ${CLUSTER_NAME}.tfstate ${CLUSTER_NAME}.tfplan

pks get-credentials ${CLUSTER_NAME}

kubectl cluster-info
kubectl get pod --all-namespaces

Get the uuid of the cluster by `pks cluster ${CLUSTER_NAME} --json | jq -r .uuid`
and put '{"kubernetes.io/cluster/service-instance_<CLUSTER_UUID>"=""}' to `public_subnet_tags` in `credentials.yml` and set the pipeline, then rerun `pave-aws` task.

kubectl run hello-pks --image=making/hello-pks:0.0.4 --port=8080
kubectl expose deployment hello-pks --port=8080 --target-port=8080 --type=LoadBalancer


kubectl delete service hello-pks
kubectl delete deployment hello-pks


terraform destroy -force -var cluster_name=${CLUSTER_NAME} -state ${CLUSTER_NAME}.tfstate
```
