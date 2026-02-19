(playbook "debops/ansible/roles/tcpwrappers/defaults/main.yml"
  (tcpwrappers__enabled "True")
  (tcpwrappers__base_packages (list
      "libwrap0"))
  (tcpwrappers__packages (list))
  (tcpwrappers__ansible_controllers (list))
  (tcpwrappers__deny_all "True")
  (tcpwrappers__divert_hosts_allow "/etc/hosts.allow.d/05_debian_hosts.allow")
  (tcpwrappers__allow (list))
  (tcpwrappers__group_allow (list))
  (tcpwrappers__host_allow (list))
  (tcpwrappers__dependent_allow (list))
  (tcpwrappers__localhost_allow (list
      
      (daemon "ALL")
      (client (list
          "127.0.0.0/8"
          "::1/128"))
      (comment "Access from localhost")
      (filename "allow_localhost")
      (weight "06"))))
