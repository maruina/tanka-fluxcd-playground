# tanka-fluxcd-playground
Test tanka + fluxcd to manage multiple k8s clusters

## Requirements

```shell
brew install tanka jsonnet-bundler
```

### Add a repository with tanka
```shell
tk tool charts add-repo karpenter oci://public.ecr.aws/karpenter
tk tool charts add karpenter/karpenter@v0.34.0

tk tool charts add-repo eks https://aws.github.io/eks-charts
tk tool charts add eks/aws-load-balancer-controller@v1.7.1
```

### Generate the environment

```shell
tk export manifests environments/prod --format='{{env.metadata.labels.env}}//{{env.metadata.name}}//{{.metadata.name}}-{{.kind | lower}}' --merge-strategy=replace-envs --recursive
```

## Test with `kind`

To provision a local cluster with kind and automatically installed all the desired charts:

```shell
kind create cluster
export GITHUB_TOKEN=<gh-token>
flux bootstrap github --token-auth --owner=maruina --repository=tanka-fluxcd-playground --branch=main --path=manifests/test/kind --personal
# Test if podinfo is running
kubectl port-forward service/podinfo 9898:9898
# On another shell
curl localhost:9898
# Make sure all charts are deployed
kubectl get pods --all-namespaces
NAMESPACE            NAME                                         READY   STATUS    RESTARTS      AGE
cert-manager         cert-manager-6854c975d5-jp8nv                1/1     Running   0             6m32s
cert-manager         cert-manager-cainjector-6976895488-fgfdt     1/1     Running   1 (88s ago)   6m32s
cert-manager         cert-manager-webhook-fcf48cc54-fhlqm         1/1     Running   0             6m32s
default              podinfo-8d9cddc85-4kqtx                      1/1     Running   0             25m
flux-system          helm-controller-5d8d5fc6fd-qlzhb             1/1     Running   0             25m
flux-system          kustomize-controller-7b7b47f459-z78bv        1/1     Running   0             25m
flux-system          notification-controller-5bb6647999-2wlx2     1/1     Running   0             25m
flux-system          source-controller-7667765cd7-n9rrf           1/1     Running   0             25m
kube-system          coredns-76f75df574-54kzc                     1/1     Running   0             28m
kube-system          coredns-76f75df574-m7n58                     1/1     Running   0             28m
kube-system          etcd-kind-control-plane                      1/1     Running   0             28m
kube-system          kindnet-5sg2d                                1/1     Running   0             28m
kube-system          kube-apiserver-kind-control-plane            1/1     Running   0             28m
kube-system          kube-controller-manager-kind-control-plane   1/1     Running   0             28m
kube-system          kube-proxy-thgmz                             1/1     Running   0             28m
kube-system          kube-scheduler-kind-control-plane            1/1     Running   0             28m
local-path-storage   local-path-provisioner-7577fdbbfb-76d65      1/1     Running   0             28m
```

## Issues

Charts like AWS Load Balancer controller use helm functions `genCA` which generates a new CA every time we call `helm template`. See https://github.com/helm/helm/issues/10731
