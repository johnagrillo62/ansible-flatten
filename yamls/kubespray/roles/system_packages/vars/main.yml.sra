(playbook "kubespray/roles/system_packages/vars/main.yml"
  (pkgs_to_remove 
    (systemd-timesyncd (list
        (jinja "{{ ntp_enabled }}")
        (jinja "{{ ntp_package == 'ntp' }}")
        (jinja "{{ ansible_os_family == 'Debian' }}"))))
  (pkgs 
    (apparmor (list
        (jinja "{{ ansible_os_family == 'Debian' }}")))
    (apparmor-parser (list
        (jinja "{{ ansible_os_family == 'Suse' }}")))
    (apt-transport-https (list
        (jinja "{{ ansible_os_family == 'Debian' }}")))
    (aufs-tools (list
        (jinja "{{ ansible_os_family == 'Debian' }}")
        (jinja "{{ ansible_distribution_major_version == '10' }}")
        (jinja "{{ 'k8s_cluster' in group_names }}")))
    (bash-completion (list))
    (chrony (list
        (jinja "{{ ntp_enabled }}")
        (jinja "{{ ntp_package == 'chrony' }}")))
    (conntrack (list
        (jinja "{{ ansible_os_family in ['Debian', 'RedHat'] }}")
        (jinja "{{ ansible_distribution != 'openEuler' }}")
        (jinja "{{ 'k8s_cluster' in group_names }}")))
    (conntrack-tools (list
        (jinja "{{ ansible_os_family == 'Suse' or ansible_distribution in ['Amazon', 'openEuler'] }}")
        (jinja "{{ 'k8s_cluster' in group_names }}")))
    (container-selinux (list
        (jinja "{{ ansible_os_family == 'RedHat' }}")
        (jinja "{{ 'k8s_cluster' in group_names }}")))
    (containers-basic (list
        (jinja "{{ ansible_os_family == 'ClearLinux' }}")
        (jinja "{{ 'k8s_cluster' in group_names }}")))
    (curl (list))
    (device-mapper (list
        (jinja "{{ ansible_os_family == 'Suse' or ansible_distribution == 'openEuler' }}")
        (jinja "{{ 'k8s_cluster' in group_names }}")))
    (device-mapper-libs (list
        (jinja "{{ ansible_os_family == 'RedHat' }}")
        (jinja "{{ ansible_distribution != 'openEuler' }}")))
    (e2fsprogs (list))
    (ebtables (list))
    (gnupg (list
        (jinja "{{ ansible_distribution == 'Debian' }}")
        (jinja "{{ ansible_distribution_major_version in ['11', '12'] }}")
        (jinja "{{ 'k8s_cluster' in group_names }}")))
    (iproute (list
        (jinja "{{ ansible_os_family == 'RedHat' }}")))
    (iproute2 (list
        (jinja "{{ ansible_os_family != 'RedHat' }}")))
    (ipset (list
        (jinja "{{ kube_proxy_mode != 'ipvs' }}")
        (jinja "{{ 'k8s_cluster' in group_names }}")))
    (iptables (list
        (jinja "{{ ansible_os_family in ['Debian', 'RedHat', 'Suse'] }}")))
    (iputils (list
        (jinja "{{ not ansible_os_family in ['Flatcar', 'Flatcar Container Linux by Kinvolk', 'Debian'] }}")
        (jinja "{{ main_access_ip is defined }}")
        (jinja "{{ ping_access_ip }}")
        (jinja "{{ not is_fedora_coreos }}")))
    (iputils-ping (list
        (jinja "{{ ansible_os_family == 'Debian' }}")
        (jinja "{{ main_access_ip is defined }}")
        (jinja "{{ ping_access_ip }}")))
    (ipvsadm (list
        (jinja "{{ kube_proxy_mode == 'ipvs' }}")
        (jinja "{{ 'k8s_cluster' in group_names }}")))
    (libseccomp (list
        (jinja "{{ ansible_os_family == 'RedHat' }}")))
    (libseccomp2 (list
        (jinja "{{ ansible_os_family in ['Debian', 'Suse'] }}")
        (jinja "{{ 'k8s_cluster' in group_names }}")))
    (libselinux-python (list
        (jinja "{{ ansible_distribution == 'Amazon' }}")))
    (libselinux-python3 (list
        (jinja "{{ ansible_distribution == 'Fedora' }}")))
    (mergerfs (list
        (jinja "{{ ansible_distribution == 'Debian' }}")
        (jinja "{{ ansible_distribution_major_version == '12' }}")))
    (nftables (list
        (jinja "{{ kube_proxy_mode == 'nftables' }}")
        (jinja "{{ 'k8s_cluster' in group_names }}")))
    (nss (list
        (jinja "{{ ansible_os_family == 'RedHat' }}")))
    (ntp (list
        (jinja "{{ ntp_enabled }}")
        (jinja "{{ ntp_package == 'ntp' }}")))
    (ntpsec (list
        (jinja "{{ ntp_enabled }}")
        (jinja "{{ ntp_package == 'ntpsec' }}")))
    (openssl (list))
    (python-apt (list
        (jinja "{{ ansible_os_family == 'Debian' }}")
        (jinja "{{ ansible_distribution_major_version == '10' }}")))
    (python-cryptography (list
        (jinja "{{ ansible_os_family == 'Suse' and ansible_distribution_version is version('15.4', '<') }}")))
    (python3-apt (list
        (jinja "{{ ansible_os_family == 'Debian' }}")
        (jinja "{{ ansible_distribution_major_version != '10' }}")))
    (python3-cryptography (list
        (jinja "{{ ansible_os_family == 'Suse' and ansible_distribution_version is version('15.4', '>=') }}")))
    (python3-libselinux (list
        (jinja "{{ ansible_distribution in ['RedHat', 'CentOS'] }}")))
    (rsync (list))
    (socat (list))
    (software-properties-common (list
        (jinja "{{ ansible_os_family == 'Debian' }}")
        (jinja "{{ ansible_distribution_major_version != '13' }}")))
    (tar (list))
    (unzip (list))
    (xfsprogs (list))))
