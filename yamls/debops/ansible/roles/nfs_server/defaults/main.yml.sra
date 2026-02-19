(playbook "debops/ansible/roles/nfs_server/defaults/main.yml"
  (nfs_server__base_packages (list
      "nfs-kernel-server"
      "acl"))
  (nfs_server__packages (list))
  (nfs_server__allow (list))
  (nfs_server__accept_any "False")
  (nfs_server__firewall_protocols (jinja "{{ [\"tcp\", \"udp\"] if nfs_server__v3 | bool else \"tcp\" }}"))
  (nfs_server__anchor_port "3550")
  (nfs_server__service_ports 
    (rpc.nfs-cb (jinja "{{ (nfs_server__anchor_port | int + 0) }}"))
    (rpc.lockd (jinja "{{ (nfs_server__anchor_port | int + 1) }}"))
    (rpc.mountd (jinja "{{ (nfs_server__anchor_port | int + 2) }}"))
    (rpc.statd (jinja "{{ (nfs_server__anchor_port | int + 3) }}"))
    (rpc.statd-bc (jinja "{{ (nfs_server__anchor_port | int + 4) }}")))
  (nfs_server__firewall_ports (jinja "{{ ([\"nfs\", \"sunrpc\"] + (nfs_server__service_ports.keys() | list))
                                if nfs_server__v3 | bool else [\"nfs\"] }}"))
  (nfs_server__v3 "False")
  (nfs_server__threads (jinja "{{ ansible_processor_vcpus | int * 2 }}"))
  (nfs_server__priority "0")
  (nfs_server__mountd_options "--manage-gids --port " (jinja "{{ nfs_server__service_ports[\"rpc.mountd\"] }}"))
  (nfs_server__kerberos "False")
  (nfs_server__svcgssd_options "")
  (nfs_server__root_path (jinja "{{ (ansible_local.fhs.data | d(\"/srv\"))
                           + \"/nfs\" }}"))
  (nfs_server__root_options (list
      "rw"
      "fsid=root"
      "sync"
      "subtree_check"
      "crossmnt"))
  (nfs_server__root_security_options (jinja "{{ [\"sec=krb5p\"] if nfs_server__kerberos | bool else [] }}"))
  (nfs_server__root_acl (jinja "{{ \"*\" if nfs_server__accept_any | bool else nfs_server__allow }}"))
  (nfs_server__default_exports (list
      
      (path (jinja "{{ nfs_server__root_path }}"))
      (acl (jinja "{{ nfs_server__root_acl }}"))
      (options (jinja "{{ (nfs_server__root_security_options.split(\",\")
                  if nfs_server__root_security_options is string
                  else nfs_server__root_security_options) +
                 (nfs_server__root_options.split(\",\")
                  if nfs_server__root_options is string
                  else nfs_server__root_options) }}"))))
  (nfs_server__exports (list))
  (nfs_server__group_exports (list))
  (nfs_server__host_exports (list))
  (nfs_server__combined_exports (jinja "{{ lookup(\"flattened\", nfs_server__default_exports
                                  + nfs_server__exports + nfs_server__group_exports
                                  + nfs_server__host_exports) }}"))
  (nfs_server__etc_services__dependent_list (list
      
      (name "rpc.nfs-cb")
      (port (jinja "{{ nfs_server__service_ports[\"rpc.nfs-cb\"] }}"))
      (comment "RPC NFS callback")
      
      (name "rpc.lockd")
      (port (jinja "{{ nfs_server__service_ports[\"rpc.lockd\"] }}"))
      (comment "RPC lockd")
      
      (name "rpc.mountd")
      (port (jinja "{{ nfs_server__service_ports[\"rpc.mountd\"] }}"))
      (comment "RPC mountd")
      
      (name "rpc.statd")
      (port (jinja "{{ nfs_server__service_ports[\"rpc.statd\"] }}"))
      (comment "RPC statd")
      
      (name "rpc.statd-bc")
      (port (jinja "{{ nfs_server__service_ports[\"rpc.statd-bc\"] }}"))
      (comment "RPC statd broadcast")))
  (nfs_server__tcpwrappers__dependent_allow (list
      
      (daemon (list
          "rpcbind"
          "mountd"
          "lockd"
          "statd"))
      (client (jinja "{{ nfs_server__allow }}"))
      (accept_any (jinja "{{ nfs_server__accept_any }}"))
      (filename "nfs-server")
      (state (jinja "{{ \"present\" if nfs_server__v3 | bool else \"absent\" }}"))))
  (nfs_server__ferm__dependent_rules (list
      
      (name "nfs_server")
      (type "accept")
      (dport (jinja "{{ nfs_server__firewall_ports }}"))
      (protocol (jinja "{{ nfs_server__firewall_protocols }}"))
      (saddr (jinja "{{ nfs_server__allow }}"))
      (accept_any (jinja "{{ nfs_server__accept_any }}")))))
