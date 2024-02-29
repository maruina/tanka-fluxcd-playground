local ekslib = import 'eks/main.libsonnet';

{
  environment(cluster):: {
    apiVersion: 'tanka.dev/v1alpha1',
    kind: 'Environment',
    metadata: {
      name: cluster.name,
      labels: {
        env: 'prod',
      },
    },
    spec: {
      namespace: 'default',
    },
    data: {
      eks: {
        karpenter: ekslib.newKarpenter(cluster.name),
        aws_load_balancer_controller: ekslib.newAwsLoadBalancerController(cluster.name),
      },
    },
  },

  clusters:: [
    { name: 'green' },
    { name: 'blue' },
  ],

  envs: {
    [cluster.name]: $.environment(cluster)
    for cluster in $.clusters
  },
}
