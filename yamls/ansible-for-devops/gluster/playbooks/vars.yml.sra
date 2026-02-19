(playbook "ansible-for-devops/gluster/playbooks/vars.yml"
  (firewall_allowed_tcp_ports (list
      "22"
      "111"
      "24007"
      "24009"
      "24010"
      "49152"
      "49153"
      "38465"
      "38466"))
  (firewall_allowed_udp_ports (list
      "111"))
  (gluster_mount_dir "/mnt/gluster")
  (gluster_brick_dir "/srv/gluster/brick")
  (gluster_brick_name "gluster"))
