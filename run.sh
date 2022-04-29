#!/bin/bash
set -e

echo "-----Starting minikube-----"
minikube start --extra-config=kubeadm.ignore-preflight-errors=NumCPU --extra-config=kubelet.housekeeping-interval=10s --force --cpus 1
echo "-----Installing metrics-server-----"
minikube addons enable metrics-server
echo "-----Waiting for metrics-server to get ready-----"
sleep 10
kubectl wait pods -n kube-system -l k8s-app=metrics-server --for condition=Ready --timeout=300s
sleep 10
echo "-----Initiating test scenarios-----"

for SCENARIO in scenarios/*.yaml
do
  echo "-----Scenario ${SCENARIO}-----"
  kubectl apply -f ${SCENARIO}
  sleep 90
  for I in 1 2 3 4
  do
    sleep 15
    kubectl top pod
  done
  kubectl delete -f ${SCENARIO}
  sleep 60
done

minikube delete
