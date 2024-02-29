local ekslib = import 'eks/main.libsonnet';
local cluster = 'green';

// local raw = import '../raw/cluster
{
  eks: {
    karpenter: ekslib.newKarpenter(cluster),
    aws_load_balancer_controller: ekslib.newAwsLoadBalancerController(cluster),
  },
}
