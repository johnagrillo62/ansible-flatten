(playbook "debops/ansible/roles/lldpd/defaults/main.yml"
  (lldpd__enabled "True")
  (lldpd__base_packages (list
      "lldpd"))
  (lldpd__packages (list))
  (lldpd__version (jinja "{{ ansible_local.lldpd.version | d(\"0.0.0\") }}"))
  (lldpd__default_daemon_arguments (list
      (jinja "{{ \"-x\" if (ansible_local.snmpd.installed | d()) | bool else [] }}")))
  (lldpd__daemon_arguments (list))
  (lldpd__default_configuration (list
      
      (name "chassisid")
      (comment "Override the default ChassisID value in virtual machines and containers
to disthinguish them from physical hosts. The value needs to be unique
across all neighbors, otherwise LLDP information is mangled.
")
      (options (list
          
          (name "chassis-container")
          (option "configure system chassisid")
          (value "Container (" (jinja "{{ ansible_hostname }}") ")")
          (state (jinja "{{ \"present\"
                   if (ansible_virtualization_type == \"container\")
                   else \"absent\" }}"))
          
          (name "chassis-docker")
          (option "configure system chassisid")
          (value "Docker container (" (jinja "{{ ansible_hostname }}") ")")
          (state (jinja "{{ \"present\"
                   if (ansible_virtualization_type == \"docker\")
                   else \"absent\" }}"))
          
          (name "chassis-kvm")
          (option "configure system chassisid")
          (value "KVM virtual machine (" (jinja "{{ ansible_hostname }}") ")")
          (state (jinja "{{ \"present\"
                   if (ansible_virtualization_type == \"kvm\")
                   else \"absent\" }}"))
          
          (name "chassis-lxc")
          (option "configure system chassisid")
          (value "LXC container (" (jinja "{{ ansible_hostname }}") ")")
          (state (jinja "{{ \"present\"
                   if (ansible_virtualization_type == \"lxc\")
                   else \"absent\" }}"))
          
          (name "chassis-openstack")
          (option "configure system chassisid")
          (value "Openstack virtual machine (" (jinja "{{ ansible_hostname }}") ")")
          (state (jinja "{{ \"present\"
                   if (ansible_virtualization_type == \"openstack\")
                   else \"absent\" }}"))
          
          (name "chassis-openvz")
          (option "configure system chassisid")
          (value "OpenVZ container (" (jinja "{{ ansible_hostname }}") ")")
          (state (jinja "{{ \"present\"
                   if (ansible_virtualization_type == \"openvz\")
                   else \"absent\" }}"))
          
          (name "chassis-podman")
          (option "configure system chassisid")
          (value "Podman container (" (jinja "{{ ansible_hostname }}") ")")
          (state (jinja "{{ \"present\"
                   if (ansible_virtualization_type == \"podman\")
                   else \"absent\" }}"))
          
          (name "chassis-virtualbox")
          (option "configure system chassisid")
          (value "VirtualBox virtual machine (" (jinja "{{ ansible_hostname }}") ")")
          (state (jinja "{{ \"present\"
                   if (ansible_virtualization_type == \"virtualbox\")
                   else \"absent\" }}"))
          
          (name "chassis-virtualpc")
          (option "configure system chassisid")
          (value "VirtualPC virtual machine (" (jinja "{{ ansible_hostname }}") ")")
          (state (jinja "{{ \"present\"
                   if (ansible_virtualization_type == \"VirtualPC\")
                   else \"absent\" }}"))
          
          (name "chassis-vmware")
          (option "configure system chassisid")
          (value "VMware virtual machine (" (jinja "{{ ansible_hostname }}") ")")
          (state (jinja "{{ \"present\"
                   if (ansible_virtualization_type == \"VMware\")
                   else \"absent\" }}"))
          
          (name "chassis-xen")
          (option "configure system chassisid")
          (value "Xen virtual machine (" (jinja "{{ ansible_hostname }}") ")")
          (state (jinja "{{ \"present\"
                   if (ansible_virtualization_type == \"xen\")
                   else \"absent\" }}"))))
      (state (jinja "{{ \"present\"
               if (ansible_virtualization_role == \"guest\" and
                   lldpd__version is version(\"1.0.0\", \">=\"))
               else \"absent\" }}"))))
  (lldpd__configuration (list))
  (lldpd__group_configuration (list))
  (lldpd__host_configuration (list))
  (lldpd__combined_configuration (jinja "{{ lldpd__default_configuration
                                   + lldpd__configuration
                                   + lldpd__group_configuration
                                   + lldpd__host_configuration }}")))
