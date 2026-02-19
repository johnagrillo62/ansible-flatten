(playbook "ansible-for-devops/kubernetes/files/manifests/kube-system/kube-flannel-vagrant.yml"
  (kind "ClusterRole")
  (apiVersion "rbac.authorization.k8s.io/v1")
  (metadata 
    (name "flannel"))
  (rules (list
      
      (apiGroups (list
          ""))
      (resources (list
          "pods"))
      (verbs (list
          "get"))
      
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
          "nodes/status"))
      (verbs (list
          "patch")))))
(playbook "ansible-for-devops/kubernetes/files/manifests/kube-system/kube-flannel-vagrant.yml"
  (kind "ClusterRoleBinding")
  (apiVersion "rbac.authorization.k8s.io/v1")
  (metadata 
    (name "flannel"))
  (roleRef 
    (apiGroup "rbac.authorization.k8s.io")
    (kind "ClusterRole")
    (name "flannel"))
  (subjects (list
      
      (kind "ServiceAccount")
      (name "flannel")
      (namespace "kube-system"))))
(playbook "ansible-for-devops/kubernetes/files/manifests/kube-system/kube-flannel-vagrant.yml"
  (apiVersion "v1")
  (kind "ServiceAccount")
  (metadata 
    (name "flannel")
    (namespace "kube-system")))
(playbook "ansible-for-devops/kubernetes/files/manifests/kube-system/kube-flannel-vagrant.yml"
  (kind "ConfigMap")
  (apiVersion "v1")
  (metadata 
    (name "kube-flannel-cfg")
    (namespace "kube-system")
    (labels 
      (tier "node")
      (app "flannel")))
  (data 
    (cni-conf.json "{
  \"name\": \"cbr0\",
  \"plugins\": [
    {
      \"type\": \"flannel\",
      \"delegate\": {
        \"hairpinMode\": true,
        \"isDefaultGateway\": true
      }
    },
    {
      \"type\": \"portmap\",
      \"capabilities\": {
        \"portMappings\": true
      }
    }
  ]
}
")
    (net-conf.json "{
  \"Network\": \"10.244.0.0/16\",
  \"Backend\": {
    \"Type\": \"vxlan\"
  }
}
")))
(playbook "ansible-for-devops/kubernetes/files/manifests/kube-system/kube-flannel-vagrant.yml"
  (apiVersion "apps/v1")
  (kind "DaemonSet")
  (metadata 
    (name "kube-flannel-ds-amd64")
    (namespace "kube-system")
    (labels 
      (tier "node")
      (app "flannel")))
  (spec 
    (selector 
      (matchLabels 
        (app "flannel")))
    (template 
      (metadata 
        (labels 
          (tier "node")
          (app "flannel")))
      (spec 
        (hostNetwork "true")
        (nodeSelector 
          (beta.kubernetes.io/arch "amd64"))
        (tolerations (list
            
            (operator "Exists")
            (effect "NoSchedule")))
        (serviceAccountName "flannel")
        (initContainers (list
            
            (name "install-cni")
            (image "quay.io/coreos/flannel:v0.10.0-amd64")
            (command (list
                "cp"))
            (args (list
                "-f"
                "/etc/kube-flannel/cni-conf.json"
                "/etc/cni/net.d/10-flannel.conflist"))
            (volumeMounts (list
                
                (name "cni")
                (mountPath "/etc/cni/net.d")
                
                (name "flannel-cfg")
                (mountPath "/etc/kube-flannel/")))))
        (containers (list
            
            (name "kube-flannel")
            (image "quay.io/coreos/flannel:v0.10.0-amd64")
            (command (list
                "/opt/bin/flanneld"))
            (args (list
                "--ip-masq"
                "--kube-subnet-mgr"
                "--iface=enp0s8"))
            (resources 
              (requests 
                (cpu "100m")
                (memory "50Mi"))
              (limits 
                (cpu "100m")
                (memory "50Mi")))
            (securityContext 
              (privileged "true"))
            (env (list
                
                (name "POD_NAME")
                (valueFrom 
                  (fieldRef 
                    (fieldPath "metadata.name")))
                
                (name "POD_NAMESPACE")
                (valueFrom 
                  (fieldRef 
                    (fieldPath "metadata.namespace")))))
            (volumeMounts (list
                
                (name "run")
                (mountPath "/run")
                
                (name "flannel-cfg")
                (mountPath "/etc/kube-flannel/")))))
        (volumes (list
            
            (name "run")
            (hostPath 
              (path "/run"))
            
            (name "cni")
            (hostPath 
              (path "/etc/cni/net.d"))
            
            (name "flannel-cfg")
            (configMap 
              (name "kube-flannel-cfg"))))))))
(playbook "ansible-for-devops/kubernetes/files/manifests/kube-system/kube-flannel-vagrant.yml"
  (apiVersion "apps/v1")
  (kind "DaemonSet")
  (metadata 
    (name "kube-flannel-ds-arm64")
    (namespace "kube-system")
    (labels 
      (tier "node")
      (app "flannel")))
  (spec 
    (selector 
      (matchLabels 
        (app "flannel")))
    (template 
      (metadata 
        (labels 
          (tier "node")
          (app "flannel")))
      (spec 
        (hostNetwork "true")
        (nodeSelector 
          (beta.kubernetes.io/arch "arm64"))
        (tolerations (list
            
            (operator "Exists")
            (effect "NoSchedule")))
        (serviceAccountName "flannel")
        (initContainers (list
            
            (name "install-cni")
            (image "quay.io/coreos/flannel:v0.10.0-arm64")
            (command (list
                "cp"))
            (args (list
                "-f"
                "/etc/kube-flannel/cni-conf.json"
                "/etc/cni/net.d/10-flannel.conflist"))
            (volumeMounts (list
                
                (name "cni")
                (mountPath "/etc/cni/net.d")
                
                (name "flannel-cfg")
                (mountPath "/etc/kube-flannel/")))))
        (containers (list
            
            (name "kube-flannel")
            (image "quay.io/coreos/flannel:v0.10.0-arm64")
            (command (list
                "/opt/bin/flanneld"))
            (args (list
                "--ip-masq"
                "--kube-subnet-mgr"))
            (resources 
              (requests 
                (cpu "100m")
                (memory "50Mi"))
              (limits 
                (cpu "100m")
                (memory "50Mi")))
            (securityContext 
              (privileged "true"))
            (env (list
                
                (name "POD_NAME")
                (valueFrom 
                  (fieldRef 
                    (fieldPath "metadata.name")))
                
                (name "POD_NAMESPACE")
                (valueFrom 
                  (fieldRef 
                    (fieldPath "metadata.namespace")))))
            (volumeMounts (list
                
                (name "run")
                (mountPath "/run")
                
                (name "flannel-cfg")
                (mountPath "/etc/kube-flannel/")))))
        (volumes (list
            
            (name "run")
            (hostPath 
              (path "/run"))
            
            (name "cni")
            (hostPath 
              (path "/etc/cni/net.d"))
            
            (name "flannel-cfg")
            (configMap 
              (name "kube-flannel-cfg"))))))))
(playbook "ansible-for-devops/kubernetes/files/manifests/kube-system/kube-flannel-vagrant.yml"
  (apiVersion "apps/v1")
  (kind "DaemonSet")
  (metadata 
    (name "kube-flannel-ds-arm")
    (namespace "kube-system")
    (labels 
      (tier "node")
      (app "flannel")))
  (spec 
    (selector 
      (matchLabels 
        (app "flannel")))
    (template 
      (metadata 
        (labels 
          (tier "node")
          (app "flannel")))
      (spec 
        (hostNetwork "true")
        (nodeSelector 
          (beta.kubernetes.io/arch "arm"))
        (tolerations (list
            
            (operator "Exists")
            (effect "NoSchedule")))
        (serviceAccountName "flannel")
        (initContainers (list
            
            (name "install-cni")
            (image "quay.io/coreos/flannel:v0.10.0-arm")
            (command (list
                "cp"))
            (args (list
                "-f"
                "/etc/kube-flannel/cni-conf.json"
                "/etc/cni/net.d/10-flannel.conflist"))
            (volumeMounts (list
                
                (name "cni")
                (mountPath "/etc/cni/net.d")
                
                (name "flannel-cfg")
                (mountPath "/etc/kube-flannel/")))))
        (containers (list
            
            (name "kube-flannel")
            (image "quay.io/coreos/flannel:v0.10.0-arm")
            (command (list
                "/opt/bin/flanneld"))
            (args (list
                "--ip-masq"
                "--kube-subnet-mgr"))
            (resources 
              (requests 
                (cpu "100m")
                (memory "50Mi"))
              (limits 
                (cpu "100m")
                (memory "50Mi")))
            (securityContext 
              (privileged "true"))
            (env (list
                
                (name "POD_NAME")
                (valueFrom 
                  (fieldRef 
                    (fieldPath "metadata.name")))
                
                (name "POD_NAMESPACE")
                (valueFrom 
                  (fieldRef 
                    (fieldPath "metadata.namespace")))))
            (volumeMounts (list
                
                (name "run")
                (mountPath "/run")
                
                (name "flannel-cfg")
                (mountPath "/etc/kube-flannel/")))))
        (volumes (list
            
            (name "run")
            (hostPath 
              (path "/run"))
            
            (name "cni")
            (hostPath 
              (path "/etc/cni/net.d"))
            
            (name "flannel-cfg")
            (configMap 
              (name "kube-flannel-cfg"))))))))
(playbook "ansible-for-devops/kubernetes/files/manifests/kube-system/kube-flannel-vagrant.yml"
  (apiVersion "apps/v1")
  (kind "DaemonSet")
  (metadata 
    (name "kube-flannel-ds-ppc64le")
    (namespace "kube-system")
    (labels 
      (tier "node")
      (app "flannel")))
  (spec 
    (selector 
      (matchLabels 
        (app "flannel")))
    (template 
      (metadata 
        (labels 
          (tier "node")
          (app "flannel")))
      (spec 
        (hostNetwork "true")
        (nodeSelector 
          (beta.kubernetes.io/arch "ppc64le"))
        (tolerations (list
            
            (operator "Exists")
            (effect "NoSchedule")))
        (serviceAccountName "flannel")
        (initContainers (list
            
            (name "install-cni")
            (image "quay.io/coreos/flannel:v0.10.0-ppc64le")
            (command (list
                "cp"))
            (args (list
                "-f"
                "/etc/kube-flannel/cni-conf.json"
                "/etc/cni/net.d/10-flannel.conflist"))
            (volumeMounts (list
                
                (name "cni")
                (mountPath "/etc/cni/net.d")
                
                (name "flannel-cfg")
                (mountPath "/etc/kube-flannel/")))))
        (containers (list
            
            (name "kube-flannel")
            (image "quay.io/coreos/flannel:v0.10.0-ppc64le")
            (command (list
                "/opt/bin/flanneld"))
            (args (list
                "--ip-masq"
                "--kube-subnet-mgr"))
            (resources 
              (requests 
                (cpu "100m")
                (memory "50Mi"))
              (limits 
                (cpu "100m")
                (memory "50Mi")))
            (securityContext 
              (privileged "true"))
            (env (list
                
                (name "POD_NAME")
                (valueFrom 
                  (fieldRef 
                    (fieldPath "metadata.name")))
                
                (name "POD_NAMESPACE")
                (valueFrom 
                  (fieldRef 
                    (fieldPath "metadata.namespace")))))
            (volumeMounts (list
                
                (name "run")
                (mountPath "/run")
                
                (name "flannel-cfg")
                (mountPath "/etc/kube-flannel/")))))
        (volumes (list
            
            (name "run")
            (hostPath 
              (path "/run"))
            
            (name "cni")
            (hostPath 
              (path "/etc/cni/net.d"))
            
            (name "flannel-cfg")
            (configMap 
              (name "kube-flannel-cfg"))))))))
(playbook "ansible-for-devops/kubernetes/files/manifests/kube-system/kube-flannel-vagrant.yml"
  (apiVersion "apps/v1")
  (kind "DaemonSet")
  (metadata 
    (name "kube-flannel-ds-s390x")
    (namespace "kube-system")
    (labels 
      (tier "node")
      (app "flannel")))
  (spec 
    (selector 
      (matchLabels 
        (app "flannel")))
    (template 
      (metadata 
        (labels 
          (tier "node")
          (app "flannel")))
      (spec 
        (hostNetwork "true")
        (nodeSelector 
          (beta.kubernetes.io/arch "s390x"))
        (tolerations (list
            
            (operator "Exists")
            (effect "NoSchedule")))
        (serviceAccountName "flannel")
        (initContainers (list
            
            (name "install-cni")
            (image "quay.io/coreos/flannel:v0.10.0-s390x")
            (command (list
                "cp"))
            (args (list
                "-f"
                "/etc/kube-flannel/cni-conf.json"
                "/etc/cni/net.d/10-flannel.conflist"))
            (volumeMounts (list
                
                (name "cni")
                (mountPath "/etc/cni/net.d")
                
                (name "flannel-cfg")
                (mountPath "/etc/kube-flannel/")))))
        (containers (list
            
            (name "kube-flannel")
            (image "quay.io/coreos/flannel:v0.10.0-s390x")
            (command (list
                "/opt/bin/flanneld"))
            (args (list
                "--ip-masq"
                "--kube-subnet-mgr"))
            (resources 
              (requests 
                (cpu "100m")
                (memory "50Mi"))
              (limits 
                (cpu "100m")
                (memory "50Mi")))
            (securityContext 
              (privileged "true"))
            (env (list
                
                (name "POD_NAME")
                (valueFrom 
                  (fieldRef 
                    (fieldPath "metadata.name")))
                
                (name "POD_NAMESPACE")
                (valueFrom 
                  (fieldRef 
                    (fieldPath "metadata.namespace")))))
            (volumeMounts (list
                
                (name "run")
                (mountPath "/run")
                
                (name "flannel-cfg")
                (mountPath "/etc/kube-flannel/")))))
        (volumes (list
            
            (name "run")
            (hostPath 
              (path "/run"))
            
            (name "cni")
            (hostPath 
              (path "/etc/cni/net.d"))
            
            (name "flannel-cfg")
            (configMap 
              (name "kube-flannel-cfg"))))))))
