(playbook "debops/ansible/roles/tftpd/defaults/main.yml"
  (tftpd__base_packages (list
      "tftpd-hpa"))
  (tftpd__packages (list))
  (tftpd__address "[::]:69")
  (tftpd__directory "/srv/tftp")
  (tftpd__username "tftp")
  (tftpd__options (list
      "--secure"
      (jinja "{{ [\"--permissive\", \"--create\", (\"--umask \" + tftpd__upload_umask)]
        if tftpd__upload_enabled | bool else [] }}")))
  (tftpd__upload_enabled (jinja "{{ True if tftpd__allow | d() else False }}"))
  (tftpd__upload_directory "upload")
  (tftpd__upload_group "tftp")
  (tftpd__upload_mode "0751")
  (tftpd__upload_umask "0002")
  (tftpd__allow (list))
  (tftpd__ferm__dependent_rules (list
      
      (type "accept")
      (protocols (list
          "udp"))
      (dport (list
          "tftp"))
      (saddr (jinja "{{ tftpd__allow }}"))
      (accept_any "True")
      (weight "50")
      (filename "tftpd_dependency_accept")))
  (tftpd__tcpwrappers__dependent_allow (list
      
      (daemon "in.tftpd")
      (client (jinja "{{ tftpd__allow }}"))
      (accept_any "True")
      (weight "50")
      (filename "tftpd_dependency_allow")
      (comment "Allow remote connections to TFTP server"))))
