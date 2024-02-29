local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);

// Creating a function per chart so we can use in our environment
// and pass the variables we need when calling helm template
{
  newKarpenter(cluster, serviceAccountRoleArn):: {
    karpenter: helm.template('karpenter', './charts/karpenter', {
      namespace: 'kube-system',
      values: {
        settings: {
          clusterName: cluster,
        },
        serviceAccount: {
          annotations: {
            'eks.amazonaws.com/role-arn': serviceAccountRoleArn,
          },
        },
        controller: {
          resources: {
            requests: {
              cpu: '1',
              memory: '1Gi',
            },
            limits: {
              cpu: '1',
              memory: '1Gi',
            },
          },
        },
      },
    }),
  },
  newAwsLoadBalancerController(cluster):: {
    aws_load_balancer_controller: helm.template('aws-load-balancer-controller', './charts/aws-load-balancer-controller', {
      namespace: 'kube-system',
      values: {
        clusterName: cluster,
        tolerations: [{
          key: 'CriticalAddonsOnly',
          operator: 'Exists',
          effect: 'NoSchedule',
        }],
        serviceTargetENISGTags: 'Name=%s-node' % cluster,
      },
    }),
  },
}
