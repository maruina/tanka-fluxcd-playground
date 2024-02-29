// Import the EKS functions
local ekslib = import 'eks/main.libsonnet';
// Import the infrastructure data generated from terraform output
local tf = import 'tf.jsonnet';

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
      // This is the place where we define which charts are part of a production EKS cluster
      eks: {
        karpenter: ekslib.newKarpenter(cluster.name, cluster.karpenter_role_arn),
        aws_load_balancer_controller: ekslib.newAwsLoadBalancerController(cluster.name),
      },
    },
  },

  // Using inline environments
  clusters:: [
    { name: 'green' },
    { name: 'blue' },
  ],

  envs: {
    [cluster.name]: $.environment(cluster + tf.clusters[cluster.name])
    for cluster in $.clusters
  },
}
