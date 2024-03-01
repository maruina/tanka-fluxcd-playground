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
  newKarpenterNodePoll(name, namespace):: {
    apiVersion: 'karpenter.sh/v1beta1',
    kind: 'NodePool',
    metadata: {
      name: name,
      namespace: namespace,
    },
    spec: {
      template: {
        spec: {
          requirements: [
            {
              key: 'kubernetes.io/arch',
              operator: 'In',
              values: '["amd64"]',
            },
            {
              key: 'kubernetes.io/os',
              operator: 'In',
              values: '["linux"]',
            },
            {
              key: 'karpenter.sh/capacity-type',
              operator: 'In',
              values: '["on-demand"]',
            },
            {
              key: 'karpenter.k8s.aws/instance-category',
              operator: 'In',
              values: '["c", "m", "r"]',
            },
            {
              key: 'kubernetes.io/arch',
              operator: 'Gt',
              values: '["2"]',
            },
          ],
          nodeClassRef: {
            name: 'default',
          },
        },
        limits: {
          cpu: 1000,
        },
        disruption: {
          consolidationPolicy: 'WhenUnderutilized',
          expireAfter: '1h',  // Very shot for testing purpose
        },
      },
    },
  },
  newKarpenterNodeClass(name, namespace, role, discoveryTag):: {
    apiVersion: 'karpenter.k8s.aws/v1beta1',
    kind: 'EC2NodeClass',
    metadata: {
      name: name,
      namespace: namespace,
    },
    spec: {
      amiFamily: 'AL2',
      role: role,
      subnetSelectorTerms: [{
        tags: {
          'karpenter.sh/discovery': discoveryTag,
        },
      }],
      securityGroupSelectorTerms: [{
        tags: {
          'karpenter.sh/discovery': discoveryTag,
        },
      }],
    },
  },
  newAwsLoadBalancerController(cluster, serviceAccountRoleArn):: {
    aws_load_balancer_controller: helm.template('aws-load-balancer-controller', './charts/aws-load-balancer-controller', {
      namespace: 'kube-system',
      values: {
        clusterName: cluster,
        serviceAccount: {
          annotations: {
            'eks.amazonaws.com/role-arn': serviceAccountRoleArn,
          },
        },
        tolerations: [{
          key: 'CriticalAddonsOnly',
          operator: 'Exists',
          effect: 'NoSchedule',
        }],
        serviceTargetENISGTags: 'Name=%s-node' % cluster,
      },
    }),
  },
  newPodInfo(message):: {
    podinfo: helm.template('podinfo', './charts/podinfo', {
      namespace: 'default',
      values: {
        ui: {
          message: message,
        },
      },
    }),
  },
}
