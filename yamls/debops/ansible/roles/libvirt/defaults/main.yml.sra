(playbook "debops/ansible/roles/libvirt/defaults/main.yml"
  (libvirt__base_packages (list
      (list
        "gawk"
        "netcat-openbsd"
        "virtinst")
      (jinja "{{ [] if (ansible_distribution_release in [\"bullseye\"])
           else \"virt-top\" }}")
      (jinja "{{ \"virt-goodies\"
        if (ansible_local | d() and ansible_local.python | d() and
            (ansible_local.python.installed2 | d()) | bool)
        else [] }}")))
  (libvirt__packages (list
      "libvirt-clients"))
  (libvirt__packages_map 
    (trusty (list
        "libvirt-bin"))
    (xenial (list
        "libvirt-bin")))
  (libvirt__group_map 
    (Debian "libvirt")
    (Ubuntu "libvirtd"))
  (libvirt__default_uri "qemu:///system")
  (libvirt__connections 
    (localhost (jinja "{{ libvirt__default_uri }}")))
  (libvirt__uri "localhost")
  (libvirt__networks (list
      (jinja "{{ libvirt__networks_default }}")
      (jinja "{{ libvirt__networks_virt_nat }}")))
  (libvirt__networks_default (list
      
      (name "default")
      (type "dnsmasq")
      (bridge "virbr0")
      (addresses (list
          "192.168.122.1/24"))
      (dhcp_range (list
          "2"
          "-2"))
      (state "absent")
      
      (name "external")
      (type "bridge")
      (bridge "br0")
      (interface_present "br0")
      
      (name "internal")
      (type "bridge")
      (bridge "br1")
      (interface_present "br1")
      
      (name "nat")
      (type "bridge")
      (bridge "br2")
      (interface_present "br2")))
  (libvirt__networks_virt_nat (list
      
      (name "virt-nat")
      (type "dnsmasq")
      (bridge "virbr0")
      (addresses (list
          "192.168.122.1/24"))
      (domain "nat." (jinja "{{ ansible_domain }}"))
      (state "active")
      (forward "True")
      (dhcp "True")))
  (libvirt__pools (list
      (jinja "{{ libvirt__pools_default }}")))
  (libvirt__pools_default (list
      
      (name "default")
      (type "dir")
      (path "/var/lib/libvirt/images")))
  (libvirt__python__dependent_packages3 (list
      "python3-libvirt"
      "python3-lxml"))
  (libvirt__python__dependent_packages2 (list
      "python-libvirt"
      "python-lxml")))
