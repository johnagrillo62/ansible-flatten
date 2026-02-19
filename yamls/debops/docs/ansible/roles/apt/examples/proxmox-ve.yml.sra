(playbook "debops/docs/ansible/roles/apt/examples/proxmox-ve.yml"
  (apt__repositories (list
      
      (name "proxmox-enterprise")
      (filename "pve-enterprise.list")
      (state "divert")
      
      (name "proxmox-ceph-enterprise")
      (filename "ceph.list")
      (repo "deb https://enterprise.proxmox.com/debian/ceph-quincy " (jinja "{{ ansible_distribution_release }}") " enterprise")
      (state "absent")
      
      (name "proxmox-no-subscription")
      (filename "proxmox-community.sources")
      (uris "http://download.proxmox.com/debian/pve")
      (suites (jinja "{{ ansible_distribution_release }}"))
      (signed_by "https://enterprise.proxmox.com/debian/proxmox-release-" (jinja "{{ ansible_distribution_release }}") ".gpg")
      (components "pve-no-subscription")
      (state "present")
      
      (name "proxmox-ceph-no-subscription")
      (filename "proxmox-community-ceph.sources")
      (uris "http://download.proxmox.com/debian/ceph-quincy")
      (suites (jinja "{{ ansible_distribution_release }}"))
      (signed_by "https://enterprise.proxmox.com/debian/proxmox-release-" (jinja "{{ ansible_distribution_release }}") ".gpg")
      (components "no-subscription")
      (state "present"))))
