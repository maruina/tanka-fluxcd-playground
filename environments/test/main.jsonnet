// Import the EKS functions
local ekslib = import 'eks/main.libsonnet';

{
  local cert_manager_namespace = 'cert-manager',
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
        cert_manager_namespace: ekslib.newNamespace(cert_manager_namespace),
        cert_manager: ekslib.newCertManager(cert_manager_namespace),
      },
    },
  },

  // Using inline environments
  // See https://tanka.dev/inline-environments
  clusters:: [
    { name: 'kind', podinfoMessage: 'hello from Peter' },
  ],

  envs: {
    [cluster.name]: $.environment(cluster)
    for cluster in $.clusters
  },
}
