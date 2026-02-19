(playbook "kubespray/roles/network_plugin/macvlan/handlers/main.yml"
  (tasks
    (task "Macvlan | reload network"
      (service 
        (name (jinja "{% if ansible_os_family == \"RedHat\" -%}") " network " (jinja "{%- elif ansible_distribution == \"Ubuntu\" and ansible_distribution_release == \"bionic\" -%}") " systemd-networkd " (jinja "{%- elif ansible_os_family == \"Debian\" -%}") " networking " (jinja "{%- endif %}"))
        (state "restarted"))
      (listen "Macvlan | restart network")
      (when "not ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"] and kube_network_plugin not in ['calico']"))))
