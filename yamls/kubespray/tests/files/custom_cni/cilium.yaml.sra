(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "v1")
  (kind "Namespace")
  (metadata 
    (name "cilium-secrets")
    (labels 
      (app.kubernetes.io/part-of "cilium"))
    (annotations null)))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "v1")
  (kind "ServiceAccount")
  (metadata 
    (name "cilium")
    (namespace "kube-system")))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "v1")
  (kind "ServiceAccount")
  (metadata 
    (name "cilium-envoy")
    (namespace "kube-system")))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "v1")
  (kind "ServiceAccount")
  (metadata 
    (name "cilium-operator")
    (namespace "kube-system")))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "v1")
  (kind "ConfigMap")
  (metadata 
    (name "cilium-config")
    (namespace "kube-system"))
  (data 
    (identity-allocation-mode "crd")
    (identity-heartbeat-timeout "30m0s")
    (identity-gc-interval "15m0s")
    (cilium-endpoint-gc-interval "5m0s")
    (nodes-gc-interval "5m0s")
    (debug "false")
    (debug-verbose "")
    (metrics-sampling-interval "5m")
    (enable-policy "default")
    (policy-cidr-match-mode "")
    (operator-prometheus-serve-addr ":9963")
    (enable-metrics "true")
    (enable-policy-secrets-sync "true")
    (policy-secrets-only-from-secrets-namespace "true")
    (policy-secrets-namespace "cilium-secrets")
    (enable-ipv4 "true")
    (enable-ipv6 "false")
    (custom-cni-conf "false")
    (enable-bpf-clock-probe "false")
    (monitor-aggregation "medium")
    (monitor-aggregation-interval "5s")
    (monitor-aggregation-flags "all")
    (bpf-map-dynamic-size-ratio "0.0025")
    (bpf-policy-map-max "16384")
    (bpf-policy-stats-map-max "65536")
    (bpf-lb-map-max "65536")
    (bpf-lb-external-clusterip "false")
    (bpf-lb-source-range-all-types "false")
    (bpf-lb-algorithm-annotation "false")
    (bpf-lb-mode-annotation "false")
    (bpf-distributed-lru "false")
    (bpf-events-drop-enabled "true")
    (bpf-events-policy-verdict-enabled "true")
    (bpf-events-trace-enabled "true")
    (preallocate-bpf-maps "false")
    (cluster-name "default")
    (cluster-id "0")
    (routing-mode "tunnel")
    (tunnel-protocol "vxlan")
    (tunnel-source-port-range "0-0")
    (service-no-backend-response "reject")
    (enable-l7-proxy "true")
    (enable-ipv4-masquerade "true")
    (enable-ipv4-big-tcp "false")
    (enable-ipv6-big-tcp "false")
    (enable-ipv6-masquerade "true")
    (enable-tcx "true")
    (datapath-mode "veth")
    (enable-masquerade-to-route-source "false")
    (enable-xt-socket-fallback "true")
    (install-no-conntrack-iptables-rules "false")
    (iptables-random-fully "false")
    (auto-direct-node-routes "false")
    (direct-routing-skip-unreachable "false")
    (kube-proxy-replacement "false")
    (bpf-lb-sock "false")
    (enable-node-port "false")
    (nodeport-addresses "")
    (enable-health-check-nodeport "true")
    (enable-health-check-loadbalancer-ip "false")
    (node-port-bind-protection "true")
    (enable-auto-protect-node-port-range "true")
    (bpf-lb-acceleration "disabled")
    (enable-svc-source-range-check "true")
    (enable-l2-neigh-discovery "false")
    (k8s-require-ipv4-pod-cidr "false")
    (k8s-require-ipv6-pod-cidr "false")
    (enable-k8s-networkpolicy "true")
    (enable-endpoint-lockdown-on-policy-overflow "false")
    (write-cni-conf-when-ready "/host/etc/cni/net.d/05-cilium.conflist")
    (cni-exclusive "true")
    (cni-log-file "/var/run/cilium/cilium-cni.log")
    (enable-endpoint-health-checking "true")
    (enable-health-checking "true")
    (health-check-icmp-failure-threshold "3")
    (enable-well-known-identities "false")
    (enable-node-selector-labels "false")
    (synchronize-k8s-nodes "true")
    (operator-api-serve-addr "127.0.0.1:9234")
    (enable-hubble "false")
    (ipam "cluster-pool")
    (ipam-cilium-node-update-rate "15s")
    (cluster-pool-ipv4-cidr (jinja "{{ kube_pods_subnet }}"))
    (cluster-pool-ipv4-mask-size "24")
    (default-lb-service-ipam "lbipam")
    (egress-gateway-reconciliation-trigger-interval "1s")
    (enable-vtep "false")
    (vtep-endpoint "")
    (vtep-cidr "")
    (vtep-mask "")
    (vtep-mac "")
    (procfs "/host/proc")
    (bpf-root "/sys/fs/bpf")
    (cgroup-root "/run/cilium/cgroupv2")
    (identity-management-mode "agent")
    (enable-sctp "false")
    (remove-cilium-node-taints "true")
    (set-cilium-node-taints "true")
    (set-cilium-is-up-condition "true")
    (unmanaged-pod-watcher-interval "15")
    (dnsproxy-enable-transparent-mode "true")
    (dnsproxy-socket-linger-timeout "10")
    (tofqdns-dns-reject-response-code "refused")
    (tofqdns-enable-dns-compression "true")
    (tofqdns-endpoint-max-ip-per-hostname "1000")
    (tofqdns-idle-connection-grace-period "0s")
    (tofqdns-max-deferred-connection-deletes "10000")
    (tofqdns-proxy-response-max-delay "100ms")
    (tofqdns-preallocate-identities "true")
    (agent-not-ready-taint-key "node.cilium.io/agent-not-ready")
    (mesh-auth-enabled "true")
    (mesh-auth-queue-size "1024")
    (mesh-auth-rotated-identities-queue-size "1024")
    (mesh-auth-gc-interval "5m0s")
    (proxy-xff-num-trusted-hops-ingress "0")
    (proxy-xff-num-trusted-hops-egress "0")
    (proxy-connect-timeout "2")
    (proxy-initial-fetch-timeout "30")
    (proxy-max-requests-per-connection "0")
    (proxy-max-connection-duration-seconds "0")
    (proxy-idle-timeout-seconds "60")
    (proxy-max-concurrent-retries "128")
    (http-retry-count "3")
    (http-stream-idle-timeout "300")
    (external-envoy-proxy "true")
    (envoy-base-id "0")
    (envoy-access-log-buffer-size "4096")
    (envoy-keep-cap-netbindservice "false")
    (max-connected-clusters "255")
    (clustermesh-enable-endpoint-sync "false")
    (clustermesh-enable-mcs-api "false")
    (policy-default-local-cluster "false")
    (nat-map-stats-entries "32")
    (nat-map-stats-interval "30s")
    (enable-internal-traffic-policy "true")
    (enable-lb-ipam "true")
    (enable-non-default-deny-policies "true")
    (enable-source-ip-verification "true")))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "v1")
  (kind "ConfigMap")
  (metadata 
    (name "cilium-envoy-config")
    (namespace "kube-system"))
  (data 
    (bootstrap-config.json "{\"admin\":{\"address\":{\"pipe\":{\"path\":\"/var/run/cilium/envoy/sockets/admin.sock\"}}},\"applicationLogConfig\":{\"logFormat\":{\"textFormat\":\"[%Y-%m-%d %T.%e][%t][%l][%n] [%g:%#] %v\"}},\"bootstrapExtensions\":[{\"name\":\"envoy.bootstrap.internal_listener\",\"typedConfig\":{\"@type\":\"type.googleapis.com/envoy.extensions.bootstrap.internal_listener.v3.InternalListener\"}}],\"dynamicResources\":{\"cdsConfig\":{\"apiConfigSource\":{\"apiType\":\"GRPC\",\"grpcServices\":[{\"envoyGrpc\":{\"clusterName\":\"xds-grpc-cilium\"}}],\"setNodeOnFirstMessageOnly\":true,\"transportApiVersion\":\"V3\"},\"initialFetchTimeout\":\"30s\",\"resourceApiVersion\":\"V3\"},\"ldsConfig\":{\"apiConfigSource\":{\"apiType\":\"GRPC\",\"grpcServices\":[{\"envoyGrpc\":{\"clusterName\":\"xds-grpc-cilium\"}}],\"setNodeOnFirstMessageOnly\":true,\"transportApiVersion\":\"V3\"},\"initialFetchTimeout\":\"30s\",\"resourceApiVersion\":\"V3\"}},\"node\":{\"cluster\":\"ingress-cluster\",\"id\":\"host~127.0.0.1~no-id~localdomain\"},\"overloadManager\":{\"resourceMonitors\":[{\"name\":\"envoy.resource_monitors.global_downstream_max_connections\",\"typedConfig\":{\"@type\":\"type.googleapis.com/envoy.extensions.resource_monitors.downstream_connections.v3.DownstreamConnectionsConfig\",\"max_active_downstream_connections\":\"50000\"}}]},\"staticResources\":{\"clusters\":[{\"circuitBreakers\":{\"thresholds\":[{\"maxRetries\":128}]},\"cleanupInterval\":\"2.500s\",\"connectTimeout\":\"2s\",\"lbPolicy\":\"CLUSTER_PROVIDED\",\"name\":\"ingress-cluster\",\"type\":\"ORIGINAL_DST\",\"typedExtensionProtocolOptions\":{\"envoy.extensions.upstreams.http.v3.HttpProtocolOptions\":{\"@type\":\"type.googleapis.com/envoy.extensions.upstreams.http.v3.HttpProtocolOptions\",\"commonHttpProtocolOptions\":{\"idleTimeout\":\"60s\",\"maxConnectionDuration\":\"0s\",\"maxRequestsPerConnection\":0},\"useDownstreamProtocolConfig\":{}}}},{\"circuitBreakers\":{\"thresholds\":[{\"maxRetries\":128}]},\"cleanupInterval\":\"2.500s\",\"connectTimeout\":\"2s\",\"lbPolicy\":\"CLUSTER_PROVIDED\",\"name\":\"egress-cluster-tls\",\"transportSocket\":{\"name\":\"cilium.tls_wrapper\",\"typedConfig\":{\"@type\":\"type.googleapis.com/cilium.UpstreamTlsWrapperContext\"}},\"type\":\"ORIGINAL_DST\",\"typedExtensionProtocolOptions\":{\"envoy.extensions.upstreams.http.v3.HttpProtocolOptions\":{\"@type\":\"type.googleapis.com/envoy.extensions.upstreams.http.v3.HttpProtocolOptions\",\"commonHttpProtocolOptions\":{\"idleTimeout\":\"60s\",\"maxConnectionDuration\":\"0s\",\"maxRequestsPerConnection\":0},\"upstreamHttpProtocolOptions\":{},\"useDownstreamProtocolConfig\":{}}}},{\"circuitBreakers\":{\"thresholds\":[{\"maxRetries\":128}]},\"cleanupInterval\":\"2.500s\",\"connectTimeout\":\"2s\",\"lbPolicy\":\"CLUSTER_PROVIDED\",\"name\":\"egress-cluster\",\"type\":\"ORIGINAL_DST\",\"typedExtensionProtocolOptions\":{\"envoy.extensions.upstreams.http.v3.HttpProtocolOptions\":{\"@type\":\"type.googleapis.com/envoy.extensions.upstreams.http.v3.HttpProtocolOptions\",\"commonHttpProtocolOptions\":{\"idleTimeout\":\"60s\",\"maxConnectionDuration\":\"0s\",\"maxRequestsPerConnection\":0},\"useDownstreamProtocolConfig\":{}}}},{\"circuitBreakers\":{\"thresholds\":[{\"maxRetries\":128}]},\"cleanupInterval\":\"2.500s\",\"connectTimeout\":\"2s\",\"lbPolicy\":\"CLUSTER_PROVIDED\",\"name\":\"ingress-cluster-tls\",\"transportSocket\":{\"name\":\"cilium.tls_wrapper\",\"typedConfig\":{\"@type\":\"type.googleapis.com/cilium.UpstreamTlsWrapperContext\"}},\"type\":\"ORIGINAL_DST\",\"typedExtensionProtocolOptions\":{\"envoy.extensions.upstreams.http.v3.HttpProtocolOptions\":{\"@type\":\"type.googleapis.com/envoy.extensions.upstreams.http.v3.HttpProtocolOptions\",\"commonHttpProtocolOptions\":{\"idleTimeout\":\"60s\",\"maxConnectionDuration\":\"0s\",\"maxRequestsPerConnection\":0},\"upstreamHttpProtocolOptions\":{},\"useDownstreamProtocolConfig\":{}}}},{\"connectTimeout\":\"2s\",\"loadAssignment\":{\"clusterName\":\"xds-grpc-cilium\",\"endpoints\":[{\"lbEndpoints\":[{\"endpoint\":{\"address\":{\"pipe\":{\"path\":\"/var/run/cilium/envoy/sockets/xds.sock\"}}}}]}]},\"name\":\"xds-grpc-cilium\",\"type\":\"STATIC\",\"typedExtensionProtocolOptions\":{\"envoy.extensions.upstreams.http.v3.HttpProtocolOptions\":{\"@type\":\"type.googleapis.com/envoy.extensions.upstreams.http.v3.HttpProtocolOptions\",\"explicitHttpConfig\":{\"http2ProtocolOptions\":{}}}}},{\"connectTimeout\":\"2s\",\"loadAssignment\":{\"clusterName\":\"/envoy-admin\",\"endpoints\":[{\"lbEndpoints\":[{\"endpoint\":{\"address\":{\"pipe\":{\"path\":\"/var/run/cilium/envoy/sockets/admin.sock\"}}}}]}]},\"name\":\"/envoy-admin\",\"type\":\"STATIC\"}],\"listeners\":[{\"address\":{\"socketAddress\":{\"address\":\"0.0.0.0\",\"portValue\":9964}},\"filterChains\":[{\"filters\":[{\"name\":\"envoy.filters.network.http_connection_manager\",\"typedConfig\":{\"@type\":\"type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager\",\"httpFilters\":[{\"name\":\"envoy.filters.http.router\",\"typedConfig\":{\"@type\":\"type.googleapis.com/envoy.extensions.filters.http.router.v3.Router\"}}],\"internalAddressConfig\":{\"cidrRanges\":[{\"addressPrefix\":\"10.0.0.0\",\"prefixLen\":8},{\"addressPrefix\":\"172.16.0.0\",\"prefixLen\":12},{\"addressPrefix\":\"192.168.0.0\",\"prefixLen\":16},{\"addressPrefix\":\"127.0.0.1\",\"prefixLen\":32}]},\"routeConfig\":{\"virtualHosts\":[{\"domains\":[\"*\"],\"name\":\"prometheus_metrics_route\",\"routes\":[{\"match\":{\"prefix\":\"/metrics\"},\"name\":\"prometheus_metrics_route\",\"route\":{\"cluster\":\"/envoy-admin\",\"prefixRewrite\":\"/stats/prometheus\"}}]}]},\"statPrefix\":\"envoy-prometheus-metrics-listener\",\"streamIdleTimeout\":\"300s\"}}]}],\"name\":\"envoy-prometheus-metrics-listener\"},{\"address\":{\"socketAddress\":{\"address\":\"127.0.0.1\",\"portValue\":9878}},\"filterChains\":[{\"filters\":[{\"name\":\"envoy.filters.network.http_connection_manager\",\"typedConfig\":{\"@type\":\"type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager\",\"httpFilters\":[{\"name\":\"envoy.filters.http.router\",\"typedConfig\":{\"@type\":\"type.googleapis.com/envoy.extensions.filters.http.router.v3.Router\"}}],\"internalAddressConfig\":{\"cidrRanges\":[{\"addressPrefix\":\"10.0.0.0\",\"prefixLen\":8},{\"addressPrefix\":\"172.16.0.0\",\"prefixLen\":12},{\"addressPrefix\":\"192.168.0.0\",\"prefixLen\":16},{\"addressPrefix\":\"127.0.0.1\",\"prefixLen\":32}]},\"routeConfig\":{\"virtual_hosts\":[{\"domains\":[\"*\"],\"name\":\"health\",\"routes\":[{\"match\":{\"prefix\":\"/healthz\"},\"name\":\"health\",\"route\":{\"cluster\":\"/envoy-admin\",\"prefixRewrite\":\"/ready\"}}]}]},\"statPrefix\":\"envoy-health-listener\",\"streamIdleTimeout\":\"300s\"}}]}],\"name\":\"envoy-health-listener\"}]}}
")))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "rbac.authorization.k8s.io/v1")
  (kind "ClusterRole")
  (metadata 
    (name "cilium")
    (labels 
      (app.kubernetes.io/part-of "cilium")))
  (rules (list
      
      (apiGroups (list
          "networking.k8s.io"))
      (resources (list
          "networkpolicies"))
      (verbs (list
          "get"
          "list"
          "watch"))
      
      (apiGroups (list
          "discovery.k8s.io"))
      (resources (list
          "endpointslices"))
      (verbs (list
          "get"
          "list"
          "watch"))
      
      (apiGroups (list
          ""))
      (resources (list
          "namespaces"
          "services"
          "pods"
          "endpoints"
          "nodes"))
      (verbs (list
          "get"
          "list"
          "watch"))
      
      (apiGroups (list
          "apiextensions.k8s.io"))
      (resources (list
          "customresourcedefinitions"))
      (verbs (list
          "list"
          "watch"
          "get"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumloadbalancerippools"
          "ciliumbgppeeringpolicies"
          "ciliumbgpnodeconfigs"
          "ciliumbgpadvertisements"
          "ciliumbgppeerconfigs"
          "ciliumclusterwideenvoyconfigs"
          "ciliumclusterwidenetworkpolicies"
          "ciliumegressgatewaypolicies"
          "ciliumendpoints"
          "ciliumendpointslices"
          "ciliumenvoyconfigs"
          "ciliumidentities"
          "ciliumlocalredirectpolicies"
          "ciliumnetworkpolicies"
          "ciliumnodes"
          "ciliumnodeconfigs"
          "ciliumcidrgroups"
          "ciliuml2announcementpolicies"
          "ciliumpodippools"))
      (verbs (list
          "list"
          "watch"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumidentities"
          "ciliumendpoints"
          "ciliumnodes"))
      (verbs (list
          "create"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumidentities"))
      (verbs (list
          "update"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumendpoints"))
      (verbs (list
          "delete"
          "get"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumnodes"
          "ciliumnodes/status"))
      (verbs (list
          "get"
          "update"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumendpoints/status"
          "ciliumendpoints"
          "ciliuml2announcementpolicies/status"
          "ciliumbgpnodeconfigs/status"))
      (verbs (list
          "patch")))))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "rbac.authorization.k8s.io/v1")
  (kind "ClusterRole")
  (metadata 
    (name "cilium-operator")
    (labels 
      (app.kubernetes.io/part-of "cilium")))
  (rules (list
      
      (apiGroups (list
          ""))
      (resources (list
          "pods"))
      (verbs (list
          "get"
          "list"
          "watch"
          "delete"))
      
      (apiGroups (list
          ""))
      (resources (list
          "configmaps"))
      (resourceNames (list
          "cilium-config"))
      (verbs (list
          "patch"))
      
      (apiGroups (list
          ""))
      (resources (list
          "nodes"))
      (verbs (list
          "list"
          "watch"))
      
      (apiGroups (list
          ""))
      (resources (list
          "nodes"
          "nodes/status"))
      (verbs (list
          "patch"))
      
      (apiGroups (list
          "discovery.k8s.io"))
      (resources (list
          "endpointslices"))
      (verbs (list
          "get"
          "list"
          "watch"))
      
      (apiGroups (list
          ""))
      (resources (list
          "services/status"))
      (verbs (list
          "update"
          "patch"))
      
      (apiGroups (list
          ""))
      (resources (list
          "namespaces"
          "secrets"))
      (verbs (list
          "get"
          "list"
          "watch"))
      
      (apiGroups (list
          ""))
      (resources (list
          "services"
          "endpoints"))
      (verbs (list
          "get"
          "list"
          "watch"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumnetworkpolicies"
          "ciliumclusterwidenetworkpolicies"))
      (verbs (list
          "create"
          "update"
          "deletecollection"
          "patch"
          "get"
          "list"
          "watch"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumnetworkpolicies/status"
          "ciliumclusterwidenetworkpolicies/status"))
      (verbs (list
          "patch"
          "update"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumendpoints"
          "ciliumidentities"))
      (verbs (list
          "delete"
          "list"
          "watch"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumidentities"))
      (verbs (list
          "update"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumnodes"))
      (verbs (list
          "create"
          "update"
          "get"
          "list"
          "watch"
          "delete"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumnodes/status"))
      (verbs (list
          "update"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumendpointslices"
          "ciliumenvoyconfigs"
          "ciliumbgppeerconfigs"
          "ciliumbgpadvertisements"
          "ciliumbgpnodeconfigs"))
      (verbs (list
          "create"
          "update"
          "get"
          "list"
          "watch"
          "delete"
          "patch"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumbgpclusterconfigs/status"
          "ciliumbgppeerconfigs/status"))
      (verbs (list
          "update"))
      
      (apiGroups (list
          "apiextensions.k8s.io"))
      (resources (list
          "customresourcedefinitions"))
      (verbs (list
          "create"
          "get"
          "list"
          "watch"))
      
      (apiGroups (list
          "apiextensions.k8s.io"))
      (resources (list
          "customresourcedefinitions"))
      (verbs (list
          "update"))
      (resourceNames (list
          "ciliumloadbalancerippools.cilium.io"
          "ciliumbgppeeringpolicies.cilium.io"
          "ciliumbgpclusterconfigs.cilium.io"
          "ciliumbgppeerconfigs.cilium.io"
          "ciliumbgpadvertisements.cilium.io"
          "ciliumbgpnodeconfigs.cilium.io"
          "ciliumbgpnodeconfigoverrides.cilium.io"
          "ciliumclusterwideenvoyconfigs.cilium.io"
          "ciliumclusterwidenetworkpolicies.cilium.io"
          "ciliumegressgatewaypolicies.cilium.io"
          "ciliumendpoints.cilium.io"
          "ciliumendpointslices.cilium.io"
          "ciliumenvoyconfigs.cilium.io"
          "ciliumidentities.cilium.io"
          "ciliumlocalredirectpolicies.cilium.io"
          "ciliumnetworkpolicies.cilium.io"
          "ciliumnodes.cilium.io"
          "ciliumnodeconfigs.cilium.io"
          "ciliumcidrgroups.cilium.io"
          "ciliuml2announcementpolicies.cilium.io"
          "ciliumpodippools.cilium.io"
          "ciliumgatewayclassconfigs.cilium.io"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumloadbalancerippools"
          "ciliumpodippools"
          "ciliumbgppeeringpolicies"
          "ciliumbgpclusterconfigs"
          "ciliumbgpnodeconfigoverrides"
          "ciliumbgppeerconfigs"))
      (verbs (list
          "get"
          "list"
          "watch"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumpodippools"))
      (verbs (list
          "create"))
      
      (apiGroups (list
          "cilium.io"))
      (resources (list
          "ciliumloadbalancerippools/status"))
      (verbs (list
          "patch"))
      
      (apiGroups (list
          "coordination.k8s.io"))
      (resources (list
          "leases"))
      (verbs (list
          "create"
          "get"
          "update")))))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "rbac.authorization.k8s.io/v1")
  (kind "ClusterRoleBinding")
  (metadata 
    (name "cilium")
    (labels 
      (app.kubernetes.io/part-of "cilium")))
  (roleRef 
    (apiGroup "rbac.authorization.k8s.io")
    (kind "ClusterRole")
    (name "cilium"))
  (subjects (list
      
      (kind "ServiceAccount")
      (name "cilium")
      (namespace "kube-system"))))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "rbac.authorization.k8s.io/v1")
  (kind "ClusterRoleBinding")
  (metadata 
    (name "cilium-operator")
    (labels 
      (app.kubernetes.io/part-of "cilium")))
  (roleRef 
    (apiGroup "rbac.authorization.k8s.io")
    (kind "ClusterRole")
    (name "cilium-operator"))
  (subjects (list
      
      (kind "ServiceAccount")
      (name "cilium-operator")
      (namespace "kube-system"))))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "rbac.authorization.k8s.io/v1")
  (kind "Role")
  (metadata 
    (name "cilium-config-agent")
    (namespace "kube-system")
    (labels 
      (app.kubernetes.io/part-of "cilium")))
  (rules (list
      
      (apiGroups (list
          ""))
      (resources (list
          "configmaps"))
      (verbs (list
          "get"
          "list"
          "watch")))))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "rbac.authorization.k8s.io/v1")
  (kind "Role")
  (metadata 
    (name "cilium-tlsinterception-secrets")
    (namespace "cilium-secrets")
    (labels 
      (app.kubernetes.io/part-of "cilium")))
  (rules (list
      
      (apiGroups (list
          ""))
      (resources (list
          "secrets"))
      (verbs (list
          "get"
          "list"
          "watch")))))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "rbac.authorization.k8s.io/v1")
  (kind "Role")
  (metadata 
    (name "cilium-operator-tlsinterception-secrets")
    (namespace "cilium-secrets")
    (labels 
      (app.kubernetes.io/part-of "cilium")))
  (rules (list
      
      (apiGroups (list
          ""))
      (resources (list
          "secrets"))
      (verbs (list
          "create"
          "delete"
          "update"
          "patch")))))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "rbac.authorization.k8s.io/v1")
  (kind "RoleBinding")
  (metadata 
    (name "cilium-config-agent")
    (namespace "kube-system")
    (labels 
      (app.kubernetes.io/part-of "cilium")))
  (roleRef 
    (apiGroup "rbac.authorization.k8s.io")
    (kind "Role")
    (name "cilium-config-agent"))
  (subjects (list
      
      (kind "ServiceAccount")
      (name "cilium")
      (namespace "kube-system"))))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "rbac.authorization.k8s.io/v1")
  (kind "RoleBinding")
  (metadata 
    (name "cilium-tlsinterception-secrets")
    (namespace "cilium-secrets")
    (labels 
      (app.kubernetes.io/part-of "cilium")))
  (roleRef 
    (apiGroup "rbac.authorization.k8s.io")
    (kind "Role")
    (name "cilium-tlsinterception-secrets"))
  (subjects (list
      
      (kind "ServiceAccount")
      (name "cilium")
      (namespace "kube-system"))))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "rbac.authorization.k8s.io/v1")
  (kind "RoleBinding")
  (metadata 
    (name "cilium-operator-tlsinterception-secrets")
    (namespace "cilium-secrets")
    (labels 
      (app.kubernetes.io/part-of "cilium")))
  (roleRef 
    (apiGroup "rbac.authorization.k8s.io")
    (kind "Role")
    (name "cilium-operator-tlsinterception-secrets"))
  (subjects (list
      
      (kind "ServiceAccount")
      (name "cilium-operator")
      (namespace "kube-system"))))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "v1")
  (kind "Service")
  (metadata 
    (name "cilium-envoy")
    (namespace "kube-system")
    (annotations 
      (prometheus.io/scrape "true")
      (prometheus.io/port "9964"))
    (labels 
      (k8s-app "cilium-envoy")
      (app.kubernetes.io/name "cilium-envoy")
      (app.kubernetes.io/part-of "cilium")
      (io.cilium/app "proxy")))
  (spec 
    (clusterIP "None")
    (type "ClusterIP")
    (selector 
      (k8s-app "cilium-envoy"))
    (ports (list
        
        (name "envoy-metrics")
        (port "9964")
        (protocol "TCP")
        (targetPort "envoy-metrics")))))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "apps/v1")
  (kind "DaemonSet")
  (metadata 
    (name "cilium")
    (namespace "kube-system")
    (labels 
      (k8s-app "cilium")
      (app.kubernetes.io/part-of "cilium")
      (app.kubernetes.io/name "cilium-agent")))
  (spec 
    (selector 
      (matchLabels 
        (k8s-app "cilium")))
    (updateStrategy 
      (rollingUpdate 
        (maxUnavailable "2"))
      (type "RollingUpdate"))
    (template 
      (metadata 
        (annotations 
          (kubectl.kubernetes.io/default-container "cilium-agent"))
        (labels 
          (k8s-app "cilium")
          (app.kubernetes.io/name "cilium-agent")
          (app.kubernetes.io/part-of "cilium")))
      (spec 
        (securityContext 
          (appArmorProfile 
            (type "Unconfined"))
          (seccompProfile 
            (type "Unconfined")))
        (containers (list
            
            (name "cilium-agent")
            (image "quay.io/cilium/cilium:v1.18.6@sha256:42ec562a5ff6c8a860c0639f5a7611685e253fd9eb2d2fcdade693724c9166a4")
            (imagePullPolicy "IfNotPresent")
            (command (list
                "cilium-agent"))
            (args (list
                "--config-dir=/tmp/cilium/config-map"))
            (startupProbe 
              (httpGet 
                (host "127.0.0.1")
                (path "/healthz")
                (port "9879")
                (scheme "HTTP")
                (httpHeaders (list
                    
                    (name "brief")
                    (value "true"))))
              (failureThreshold "300")
              (periodSeconds "2")
              (successThreshold "1")
              (initialDelaySeconds "5"))
            (livenessProbe 
              (httpGet 
                (host "127.0.0.1")
                (path "/healthz")
                (port "9879")
                (scheme "HTTP")
                (httpHeaders (list
                    
                    (name "brief")
                    (value "true")
                    
                    (name "require-k8s-connectivity")
                    (value "false"))))
              (periodSeconds "30")
              (successThreshold "1")
              (failureThreshold "10")
              (timeoutSeconds "5"))
            (readinessProbe 
              (httpGet 
                (host "127.0.0.1")
                (path "/healthz")
                (port "9879")
                (scheme "HTTP")
                (httpHeaders (list
                    
                    (name "brief")
                    (value "true"))))
              (periodSeconds "30")
              (successThreshold "1")
              (failureThreshold "3")
              (timeoutSeconds "5"))
            (env (list
                
                (name "K8S_NODE_NAME")
                (valueFrom 
                  (fieldRef 
                    (apiVersion "v1")
                    (fieldPath "spec.nodeName")))
                
                (name "CILIUM_K8S_NAMESPACE")
                (valueFrom 
                  (fieldRef 
                    (apiVersion "v1")
                    (fieldPath "metadata.namespace")))
                
                (name "CILIUM_CLUSTERMESH_CONFIG")
                (value "/var/lib/cilium/clustermesh/")
                
                (name "GOMEMLIMIT")
                (valueFrom 
                  (resourceFieldRef 
                    (resource "limits.memory")
                    (divisor "1")))
                
                (name "KUBE_CLIENT_BACKOFF_BASE")
                (value "1")
                
                (name "KUBE_CLIENT_BACKOFF_DURATION")
                (value "120")))
            (lifecycle 
              (postStart 
                (exec 
                  (command (list
                      "bash"
                      "-c"
                      "set -o errexit
set -o pipefail
set -o nounset

# When running in AWS ENI mode, it's likely that 'aws-node' has
# had a chance to install SNAT iptables rules. These can result
# in dropped traffic, so we should attempt to remove them.
# We do it using a 'postStart' hook since this may need to run
# for nodes which might have already been init'ed but may still
# have dangling rules. This is safe because there are no
# dependencies on anything that is part of the startup script
# itself, and can be safely run multiple times per node (e.g. in
# case of a restart).
if [[ \"$(iptables-save | grep -E -c 'AWS-SNAT-CHAIN|AWS-CONNMARK-CHAIN')\" != \"0\" ]];
then
    echo 'Deleting iptables rules created by the AWS CNI VPC plugin'
    iptables-save | grep -E -v 'AWS-SNAT-CHAIN|AWS-CONNMARK-CHAIN' | iptables-restore
fi
echo 'Done!'
"))))
              (preStop 
                (exec 
                  (command (list
                      "/cni-uninstall.sh")))))
            (securityContext 
              (seLinuxOptions 
                (level "s0")
                (type "spc_t"))
              (capabilities 
                (add (list
                    "CHOWN"
                    "KILL"
                    "NET_ADMIN"
                    "NET_RAW"
                    "IPC_LOCK"
                    "SYS_MODULE"
                    "SYS_ADMIN"
                    "SYS_RESOURCE"
                    "DAC_OVERRIDE"
                    "FOWNER"
                    "SETGID"
                    "SETUID"))
                (drop (list
                    "ALL"))))
            (terminationMessagePolicy "FallbackToLogsOnError")
            (volumeMounts (list
                
                (name "envoy-sockets")
                (mountPath "/var/run/cilium/envoy/sockets")
                (readOnly "false")
                
                (mountPath "/host/proc/sys/net")
                (name "host-proc-sys-net")
                
                (mountPath "/host/proc/sys/kernel")
                (name "host-proc-sys-kernel")
                
                (name "bpf-maps")
                (mountPath "/sys/fs/bpf")
                (mountPropagation "HostToContainer")
                
                (name "cilium-run")
                (mountPath "/var/run/cilium")
                
                (name "cilium-netns")
                (mountPath "/var/run/cilium/netns")
                (mountPropagation "HostToContainer")
                
                (name "etc-cni-netd")
                (mountPath "/host/etc/cni/net.d")
                
                (name "clustermesh-secrets")
                (mountPath "/var/lib/cilium/clustermesh")
                (readOnly "true")
                
                (name "lib-modules")
                (mountPath "/lib/modules")
                (readOnly "true")
                
                (name "xtables-lock")
                (mountPath "/run/xtables.lock")
                
                (name "tmp")
                (mountPath "/tmp")))))
        (initContainers (list
            
            (name "config")
            (image "quay.io/cilium/cilium:v1.18.6@sha256:42ec562a5ff6c8a860c0639f5a7611685e253fd9eb2d2fcdade693724c9166a4")
            (imagePullPolicy "IfNotPresent")
            (command (list
                "cilium-dbg"
                "build-config"))
            (env (list
                
                (name "K8S_NODE_NAME")
                (valueFrom 
                  (fieldRef 
                    (apiVersion "v1")
                    (fieldPath "spec.nodeName")))
                
                (name "CILIUM_K8S_NAMESPACE")
                (valueFrom 
                  (fieldRef 
                    (apiVersion "v1")
                    (fieldPath "metadata.namespace")))))
            (volumeMounts (list
                
                (name "tmp")
                (mountPath "/tmp")))
            (terminationMessagePolicy "FallbackToLogsOnError")
            
            (name "mount-cgroup")
            (image "quay.io/cilium/cilium:v1.18.6@sha256:42ec562a5ff6c8a860c0639f5a7611685e253fd9eb2d2fcdade693724c9166a4")
            (imagePullPolicy "IfNotPresent")
            (env (list
                
                (name "CGROUP_ROOT")
                (value "/run/cilium/cgroupv2")
                
                (name "BIN_PATH")
                (value "/opt/cni/bin")))
            (command (list
                "sh"
                "-ec"
                "cp /usr/bin/cilium-mount /hostbin/cilium-mount;
nsenter --cgroup=/hostproc/1/ns/cgroup --mount=/hostproc/1/ns/mnt \"${BIN_PATH}/cilium-mount\" $CGROUP_ROOT;
rm /hostbin/cilium-mount
"))
            (volumeMounts (list
                
                (name "hostproc")
                (mountPath "/hostproc")
                
                (name "cni-path")
                (mountPath "/hostbin")))
            (terminationMessagePolicy "FallbackToLogsOnError")
            (securityContext 
              (seLinuxOptions 
                (level "s0")
                (type "spc_t"))
              (capabilities 
                (add (list
                    "SYS_ADMIN"
                    "SYS_CHROOT"
                    "SYS_PTRACE"))
                (drop (list
                    "ALL"))))
            
            (name "apply-sysctl-overwrites")
            (image "quay.io/cilium/cilium:v1.18.6@sha256:42ec562a5ff6c8a860c0639f5a7611685e253fd9eb2d2fcdade693724c9166a4")
            (imagePullPolicy "IfNotPresent")
            (env (list
                
                (name "BIN_PATH")
                (value "/opt/cni/bin")))
            (command (list
                "sh"
                "-ec"
                "cp /usr/bin/cilium-sysctlfix /hostbin/cilium-sysctlfix;
nsenter --mount=/hostproc/1/ns/mnt \"${BIN_PATH}/cilium-sysctlfix\";
rm /hostbin/cilium-sysctlfix
"))
            (volumeMounts (list
                
                (name "hostproc")
                (mountPath "/hostproc")
                
                (name "cni-path")
                (mountPath "/hostbin")))
            (terminationMessagePolicy "FallbackToLogsOnError")
            (securityContext 
              (seLinuxOptions 
                (level "s0")
                (type "spc_t"))
              (capabilities 
                (add (list
                    "SYS_ADMIN"
                    "SYS_CHROOT"
                    "SYS_PTRACE"))
                (drop (list
                    "ALL"))))
            
            (name "mount-bpf-fs")
            (image "quay.io/cilium/cilium:v1.18.6@sha256:42ec562a5ff6c8a860c0639f5a7611685e253fd9eb2d2fcdade693724c9166a4")
            (imagePullPolicy "IfNotPresent")
            (args (list
                "mount | grep \"/sys/fs/bpf type bpf\" || mount -t bpf bpf /sys/fs/bpf"))
            (command (list
                "/bin/bash"
                "-c"
                "--"))
            (terminationMessagePolicy "FallbackToLogsOnError")
            (securityContext 
              (privileged "true"))
            (volumeMounts (list
                
                (name "bpf-maps")
                (mountPath "/sys/fs/bpf")
                (mountPropagation "Bidirectional")))
            
            (name "clean-cilium-state")
            (image "quay.io/cilium/cilium:v1.18.6@sha256:42ec562a5ff6c8a860c0639f5a7611685e253fd9eb2d2fcdade693724c9166a4")
            (imagePullPolicy "IfNotPresent")
            (command (list
                "/init-container.sh"))
            (env (list
                
                (name "CILIUM_ALL_STATE")
                (valueFrom 
                  (configMapKeyRef 
                    (name "cilium-config")
                    (key "clean-cilium-state")
                    (optional "true")))
                
                (name "CILIUM_BPF_STATE")
                (valueFrom 
                  (configMapKeyRef 
                    (name "cilium-config")
                    (key "clean-cilium-bpf-state")
                    (optional "true")))
                
                (name "WRITE_CNI_CONF_WHEN_READY")
                (valueFrom 
                  (configMapKeyRef 
                    (name "cilium-config")
                    (key "write-cni-conf-when-ready")
                    (optional "true")))))
            (terminationMessagePolicy "FallbackToLogsOnError")
            (securityContext 
              (seLinuxOptions 
                (level "s0")
                (type "spc_t"))
              (capabilities 
                (add (list
                    "NET_ADMIN"
                    "SYS_MODULE"
                    "SYS_ADMIN"
                    "SYS_RESOURCE"))
                (drop (list
                    "ALL"))))
            (volumeMounts (list
                
                (name "bpf-maps")
                (mountPath "/sys/fs/bpf")
                
                (name "cilium-cgroup")
                (mountPath "/run/cilium/cgroupv2")
                (mountPropagation "HostToContainer")
                
                (name "cilium-run")
                (mountPath "/var/run/cilium")))
            
            (name "install-cni-binaries")
            (image "quay.io/cilium/cilium:v1.18.6@sha256:42ec562a5ff6c8a860c0639f5a7611685e253fd9eb2d2fcdade693724c9166a4")
            (imagePullPolicy "IfNotPresent")
            (command (list
                "/install-plugin.sh"))
            (resources 
              (requests 
                (cpu "100m")
                (memory "10Mi")))
            (securityContext 
              (seLinuxOptions 
                (level "s0")
                (type "spc_t"))
              (capabilities 
                (drop (list
                    "ALL"))))
            (terminationMessagePolicy "FallbackToLogsOnError")
            (volumeMounts (list
                
                (name "cni-path")
                (mountPath "/host/opt/cni/bin")))))
        (restartPolicy "Always")
        (priorityClassName "system-node-critical")
        (serviceAccountName "cilium")
        (automountServiceAccountToken "true")
        (terminationGracePeriodSeconds "1")
        (hostNetwork "true")
        (affinity 
          (podAntiAffinity 
            (requiredDuringSchedulingIgnoredDuringExecution (list
                
                (labelSelector 
                  (matchLabels 
                    (k8s-app "cilium")))
                (topologyKey "kubernetes.io/hostname")))))
        (nodeSelector 
          (kubernetes.io/os "linux"))
        (tolerations (list
            
            (operator "Exists")))
        (volumes (list
            
            (name "tmp")
            (emptyDir )
            
            (name "cilium-run")
            (hostPath 
              (path "/var/run/cilium")
              (type "DirectoryOrCreate"))
            
            (name "cilium-netns")
            (hostPath 
              (path "/var/run/netns")
              (type "DirectoryOrCreate"))
            
            (name "bpf-maps")
            (hostPath 
              (path "/sys/fs/bpf")
              (type "DirectoryOrCreate"))
            
            (name "hostproc")
            (hostPath 
              (path "/proc")
              (type "Directory"))
            
            (name "cilium-cgroup")
            (hostPath 
              (path "/run/cilium/cgroupv2")
              (type "DirectoryOrCreate"))
            
            (name "cni-path")
            (hostPath 
              (path "/opt/cni/bin")
              (type "DirectoryOrCreate"))
            
            (name "etc-cni-netd")
            (hostPath 
              (path "/etc/cni/net.d")
              (type "DirectoryOrCreate"))
            
            (name "lib-modules")
            (hostPath 
              (path "/lib/modules"))
            
            (name "xtables-lock")
            (hostPath 
              (path "/run/xtables.lock")
              (type "FileOrCreate"))
            
            (name "envoy-sockets")
            (hostPath 
              (path "/var/run/cilium/envoy/sockets")
              (type "DirectoryOrCreate"))
            
            (name "clustermesh-secrets")
            (projected 
              (defaultMode "0400")
              (sources (list
                  
                  (secret 
                    (name "cilium-clustermesh")
                    (optional "true"))
                  
                  (secret 
                    (name "clustermesh-apiserver-remote-cert")
                    (optional "true")
                    (items (list
                        
                        (key "tls.key")
                        (path "common-etcd-client.key")
                        
                        (key "tls.crt")
                        (path "common-etcd-client.crt")
                        
                        (key "ca.crt")
                        (path "common-etcd-client-ca.crt"))))
                  
                  (secret 
                    (name "clustermesh-apiserver-local-cert")
                    (optional "true")
                    (items (list
                        
                        (key "tls.key")
                        (path "local-etcd-client.key")
                        
                        (key "tls.crt")
                        (path "local-etcd-client.crt")
                        
                        (key "ca.crt")
                        (path "local-etcd-client-ca.crt")))))))
            
            (name "host-proc-sys-net")
            (hostPath 
              (path "/proc/sys/net")
              (type "Directory"))
            
            (name "host-proc-sys-kernel")
            (hostPath 
              (path "/proc/sys/kernel")
              (type "Directory"))))))))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "apps/v1")
  (kind "DaemonSet")
  (metadata 
    (name "cilium-envoy")
    (namespace "kube-system")
    (labels 
      (k8s-app "cilium-envoy")
      (app.kubernetes.io/part-of "cilium")
      (app.kubernetes.io/name "cilium-envoy")
      (name "cilium-envoy")))
  (spec 
    (selector 
      (matchLabels 
        (k8s-app "cilium-envoy")))
    (updateStrategy 
      (rollingUpdate 
        (maxUnavailable "2"))
      (type "RollingUpdate"))
    (template 
      (metadata 
        (annotations null)
        (labels 
          (k8s-app "cilium-envoy")
          (name "cilium-envoy")
          (app.kubernetes.io/name "cilium-envoy")
          (app.kubernetes.io/part-of "cilium")))
      (spec 
        (securityContext 
          (appArmorProfile 
            (type "Unconfined")))
        (containers (list
            
            (name "cilium-envoy")
            (image "quay.io/cilium/cilium-envoy:v1.35.9-1767794330-db497dd19e346b39d81d7b5c0dedf6c812bcc5c9@sha256:81398e449f2d3d0a6a70527e4f641aaa685d3156bea0bb30712fae3fd8822b86")
            (imagePullPolicy "IfNotPresent")
            (command (list
                "/usr/bin/cilium-envoy-starter"))
            (args (list
                "--"
                "-c /var/run/cilium/envoy/bootstrap-config.json"
                "--base-id 0"
                "--log-level info"))
            (startupProbe 
              (httpGet 
                (host "127.0.0.1")
                (path "/healthz")
                (port "9878")
                (scheme "HTTP"))
              (failureThreshold "105")
              (periodSeconds "2")
              (successThreshold "1")
              (initialDelaySeconds "5"))
            (livenessProbe 
              (httpGet 
                (host "127.0.0.1")
                (path "/healthz")
                (port "9878")
                (scheme "HTTP"))
              (periodSeconds "30")
              (successThreshold "1")
              (failureThreshold "10")
              (timeoutSeconds "5"))
            (readinessProbe 
              (httpGet 
                (host "127.0.0.1")
                (path "/healthz")
                (port "9878")
                (scheme "HTTP"))
              (periodSeconds "30")
              (successThreshold "1")
              (failureThreshold "3")
              (timeoutSeconds "5"))
            (env (list
                
                (name "K8S_NODE_NAME")
                (valueFrom 
                  (fieldRef 
                    (apiVersion "v1")
                    (fieldPath "spec.nodeName")))
                
                (name "CILIUM_K8S_NAMESPACE")
                (valueFrom 
                  (fieldRef 
                    (apiVersion "v1")
                    (fieldPath "metadata.namespace")))))
            (ports (list
                
                (name "envoy-metrics")
                (containerPort "9964")
                (hostPort "9964")
                (protocol "TCP")))
            (securityContext 
              (seLinuxOptions 
                (level "s0")
                (type "spc_t"))
              (capabilities 
                (add (list
                    "NET_ADMIN"
                    "SYS_ADMIN"))
                (drop (list
                    "ALL"))))
            (terminationMessagePolicy "FallbackToLogsOnError")
            (volumeMounts (list
                
                (name "envoy-sockets")
                (mountPath "/var/run/cilium/envoy/sockets")
                (readOnly "false")
                
                (name "envoy-artifacts")
                (mountPath "/var/run/cilium/envoy/artifacts")
                (readOnly "true")
                
                (name "envoy-config")
                (mountPath "/var/run/cilium/envoy/")
                (readOnly "true")
                
                (name "bpf-maps")
                (mountPath "/sys/fs/bpf")
                (mountPropagation "HostToContainer")))))
        (restartPolicy "Always")
        (priorityClassName "system-node-critical")
        (serviceAccountName "cilium-envoy")
        (automountServiceAccountToken "true")
        (terminationGracePeriodSeconds "1")
        (hostNetwork "true")
        (affinity 
          (nodeAffinity 
            (requiredDuringSchedulingIgnoredDuringExecution 
              (nodeSelectorTerms (list
                  
                  (matchExpressions (list
                      
                      (key "cilium.io/no-schedule")
                      (operator "NotIn")
                      (values (list
                          "true"))))))))
          (podAffinity 
            (requiredDuringSchedulingIgnoredDuringExecution (list
                
                (labelSelector 
                  (matchLabels 
                    (k8s-app "cilium")))
                (topologyKey "kubernetes.io/hostname"))))
          (podAntiAffinity 
            (requiredDuringSchedulingIgnoredDuringExecution (list
                
                (labelSelector 
                  (matchLabels 
                    (k8s-app "cilium-envoy")))
                (topologyKey "kubernetes.io/hostname")))))
        (nodeSelector 
          (kubernetes.io/os "linux"))
        (tolerations (list
            
            (operator "Exists")))
        (volumes (list
            
            (name "envoy-sockets")
            (hostPath 
              (path "/var/run/cilium/envoy/sockets")
              (type "DirectoryOrCreate"))
            
            (name "envoy-artifacts")
            (hostPath 
              (path "/var/run/cilium/envoy/artifacts")
              (type "DirectoryOrCreate"))
            
            (name "envoy-config")
            (configMap 
              (name "cilium-envoy-config")
              (defaultMode "0400")
              (items (list
                  
                  (key "bootstrap-config.json")
                  (path "bootstrap-config.json"))))
            
            (name "bpf-maps")
            (hostPath 
              (path "/sys/fs/bpf")
              (type "DirectoryOrCreate"))))))))
(playbook "kubespray/tests/files/custom_cni/cilium.yaml"
  (apiVersion "apps/v1")
  (kind "Deployment")
  (metadata 
    (name "cilium-operator")
    (namespace "kube-system")
    (labels 
      (io.cilium/app "operator")
      (name "cilium-operator")
      (app.kubernetes.io/part-of "cilium")
      (app.kubernetes.io/name "cilium-operator")))
  (spec 
    (replicas "2")
    (selector 
      (matchLabels 
        (io.cilium/app "operator")
        (name "cilium-operator")))
    (strategy 
      (rollingUpdate 
        (maxSurge "25%")
        (maxUnavailable "50%"))
      (type "RollingUpdate"))
    (template 
      (metadata 
        (annotations 
          (prometheus.io/port "9963")
          (prometheus.io/scrape "true"))
        (labels 
          (io.cilium/app "operator")
          (name "cilium-operator")
          (app.kubernetes.io/part-of "cilium")
          (app.kubernetes.io/name "cilium-operator")))
      (spec 
        (securityContext 
          (seccompProfile 
            (type "RuntimeDefault")))
        (containers (list
            
            (name "cilium-operator")
            (image "quay.io/cilium/operator-generic:v1.18.6@sha256:34a827ce9ed021c8adf8f0feca131f53b3c54a3ef529053d871d0347ec4d69af")
            (imagePullPolicy "IfNotPresent")
            (command (list
                "cilium-operator-generic"))
            (args (list
                "--config-dir=/tmp/cilium/config-map"
                "--debug=$(CILIUM_DEBUG)"))
            (env (list
                
                (name "K8S_NODE_NAME")
                (valueFrom 
                  (fieldRef 
                    (apiVersion "v1")
                    (fieldPath "spec.nodeName")))
                
                (name "CILIUM_K8S_NAMESPACE")
                (valueFrom 
                  (fieldRef 
                    (apiVersion "v1")
                    (fieldPath "metadata.namespace")))
                
                (name "CILIUM_DEBUG")
                (valueFrom 
                  (configMapKeyRef 
                    (key "debug")
                    (name "cilium-config")
                    (optional "true")))))
            (ports (list
                
                (name "prometheus")
                (containerPort "9963")
                (hostPort "9963")
                (protocol "TCP")))
            (livenessProbe 
              (httpGet 
                (host "127.0.0.1")
                (path "/healthz")
                (port "9234")
                (scheme "HTTP"))
              (initialDelaySeconds "60")
              (periodSeconds "10")
              (timeoutSeconds "3"))
            (readinessProbe 
              (httpGet 
                (host "127.0.0.1")
                (path "/healthz")
                (port "9234")
                (scheme "HTTP"))
              (initialDelaySeconds "0")
              (periodSeconds "5")
              (timeoutSeconds "3")
              (failureThreshold "5"))
            (volumeMounts (list
                
                (name "cilium-config-path")
                (mountPath "/tmp/cilium/config-map")
                (readOnly "true")))
            (securityContext 
              (allowPrivilegeEscalation "false")
              (capabilities 
                (drop (list
                    "ALL"))))
            (terminationMessagePolicy "FallbackToLogsOnError")))
        (hostNetwork "true")
        (restartPolicy "Always")
        (priorityClassName "system-cluster-critical")
        (serviceAccountName "cilium-operator")
        (automountServiceAccountToken "true")
        (affinity 
          (podAntiAffinity 
            (requiredDuringSchedulingIgnoredDuringExecution (list
                
                (labelSelector 
                  (matchLabels 
                    (io.cilium/app "operator")))
                (topologyKey "kubernetes.io/hostname")))))
        (nodeSelector 
          (kubernetes.io/os "linux"))
        (tolerations (list
            
            (key "node-role.kubernetes.io/control-plane")
            (operator "Exists")
            
            (key "node-role.kubernetes.io/master")
            (operator "Exists")
            
            (key "node.kubernetes.io/not-ready")
            (operator "Exists")
            
            (key "node.cloudprovider.kubernetes.io/uninitialized")
            (operator "Exists")
            
            (key "node.cilium.io/agent-not-ready")
            (operator "Exists")))
        (volumes (list
            
            (name "cilium-config-path")
            (configMap 
              (name "cilium-config"))))))))
