#bash
sudo k3s kubectl get nodes --selector='!kubernetes.io/role' -o name | while read node; do
    status=$(sudo k3s kubectl get $node -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
    if [ "$status" != "True" ]; then
        sudo k3s kubectl delete $node
    fi
done