local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);

{
  newKarpenter(cluster):: {
    karpenter: helm.template('karpenter', './charts/karpenter', {
      namespace: 'kube-system',
      values: {
        settings: {
          clusterName: cluster,
        },
      },
    }),
  },
  newAwsLoadBalancerController(cluster):: {
    aws_load_balancer_controller: helm.template('aws-load-balancer-controller', './charts/aws-load-balancer-controller', {
      namespace: 'kube-system',
      values: {
        clusterName: cluster,
      },
    }),
  },
}
