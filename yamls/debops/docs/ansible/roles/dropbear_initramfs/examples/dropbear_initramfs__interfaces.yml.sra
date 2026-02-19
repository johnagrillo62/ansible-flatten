(playbook "debops/docs/ansible/roles/dropbear_initramfs/examples/dropbear_initramfs__interfaces.yml"
  (dropbear_initramfs__interfaces 
    (eth0 
      (inet "False")
      (inet6 "static")
      (addresses (list
          "2001:db8::23/64"))
      (gateways (list
          "2001:db8::")))))
