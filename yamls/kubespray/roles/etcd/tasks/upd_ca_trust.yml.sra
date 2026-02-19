(playbook "kubespray/roles/etcd/tasks/upd_ca_trust.yml"
  (tasks
    (task "Gen_certs | target ca-certificate store file"
      (set_fact 
        (ca_cert_path (jinja "{% if ansible_os_family == \"Debian\" -%}") "
/usr/local/share/ca-certificates/etcd-ca.crt
" (jinja "{%- elif ansible_os_family == \"RedHat\" -%}") "
/etc/pki/ca-trust/source/anchors/etcd-ca.crt
" (jinja "{%- elif ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"] -%}") "
/etc/ssl/certs/etcd-ca.pem
" (jinja "{%- elif ansible_os_family == \"Suse\" -%}") "
/etc/pki/trust/anchors/etcd-ca.pem
" (jinja "{%- elif ansible_os_family == \"ClearLinux\" -%}") "
/usr/share/ca-certs/etcd-ca.pem
" (jinja "{%- endif %}")))
      (tags (list
          "facts")))
    (task "Gen_certs | add CA to trusted CA dir"
      (copy 
        (src (jinja "{{ etcd_cert_dir }}") "/ca.pem")
        (dest (jinja "{{ ca_cert_path }}"))
        (remote_src "true")
        (mode "0640"))
      (register "etcd_ca_cert"))
    (task "Gen_certs | update ca-certificates (Debian/Ubuntu/SUSE/Flatcar)"
      (command "update-ca-certificates")
      (when "etcd_ca_cert.changed and ansible_os_family in [\"Debian\", \"Flatcar\", \"Flatcar Container Linux by Kinvolk\", \"Suse\"]"))
    (task "Gen_certs | update ca-certificates (RedHat)"
      (command "update-ca-trust extract")
      (when "etcd_ca_cert.changed and ansible_os_family == \"RedHat\""))
    (task "Gen_certs | update ca-certificates (ClearLinux)"
      (command "clrtrust add \"" (jinja "{{ ca_cert_path }}") "\"")
      (when "etcd_ca_cert.changed and ansible_os_family == \"ClearLinux\""))))
