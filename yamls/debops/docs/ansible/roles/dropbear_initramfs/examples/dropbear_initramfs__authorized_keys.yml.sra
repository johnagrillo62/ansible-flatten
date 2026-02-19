(playbook "debops/docs/ansible/roles/dropbear_initramfs/examples/dropbear_initramfs__authorized_keys.yml"
  (dropbear_initramfs__authorized_keys (list
      
      (sshkeys (jinja "{{ lookup(\"file\", \"/path/to/admin23.pub\") }}"))
      (exclusive "True"))))
