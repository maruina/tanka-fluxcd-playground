# tanka-fluxcd-playground
Test tanka + fluxcd to manage multiple k8s clusters

## Requirements

```shell
brew install tanka jsonnet-bundler
```

- Add a repository
```shell
tk tool charts add-repo karpenter oci://public.ecr.aws/karpenter
tk tool charts add karpenter/karpenter@v0.34.0
```
This vendor the chart using tanka


```shell
➜ tk export compiled environments/prod --format='{{env.metadata.labels.env}}//{{env.metadata.name}}//{{.metadata.name}}-{{.kind | lower}}' --merge-strategy=replace-envs --recursive
```
