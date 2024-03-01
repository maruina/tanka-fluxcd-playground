// Import the EKS functions
local ekslib = import 'eks/main.libsonnet';

{
  environment(cluster):: {
    apiVersion: 'tanka.dev/v1alpha1',
    kind: 'Environment',
    metadata: {
      name: cluster.name,
      labels: {
        env: 'test',
      },
    },
    spec: {
      namespace: 'default',
    },
    data: {
      // This is the place where we define which charts makes a production EKS cluster
      cluster: {
        podinfo: ekslib.newPodInfo(cluster.podinfoMessage),
      },
    },
  },

  // Using inline environments
  // See https://tanka.dev/inline-environments
  clusters:: [
    { name: 'kind', podinfoMessage: 'hello from kind and fluxcd' },
  ],

  envs: {
    [cluster.name]: $.environment(cluster)
    for cluster in $.clusters
  },
}
