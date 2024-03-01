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
```

## Issues

Charts like AWS Load Balancer controller use helm functions `genCA` which generates a new CA every time we call `helm template`. See https://github.com/helm/helm/issues/10731
