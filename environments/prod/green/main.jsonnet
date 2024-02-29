local eksimport = import 'eks/main.libsonnet';


local cluster = 'green';
eksimport.eks(cluster)

// local raw = import '../raw/cluster
{
  clusters: {},
}
