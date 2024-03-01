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
      // This is the place where we define which charts makes a production EKS cluster
      eks: {
        karpenter: ekslib.newKarpenter(cluster.name, cluster.karpenter_role_arn),
        nodePool: ekslib.newKarpenterNodePoll('default', 'kube-system'),
        nodeClass: ekslib.newKarpenterNodeClass('default', 'kube-system', cluster.karpenter_node_role, cluster.name),
        awsLoadBalancerController: ekslib.newAwsLoadBalancerController(cluster.name, cluster.aws_load_balancer_controller_role_arn),
      },
    },
  },

  // Using inline environments
  // See https://tanka.dev/inline-environments
  clusters:: [
    { name: 'green' },
    { name: 'blue' },
  ],

  envs: {
    [cluster.name]: $.environment(cluster + tf.clusters[cluster.name])
    for cluster in $.clusters
  },
}
