(playbook "debops/docs/ansible/roles/unbound/examples/forward-all-to-google.yml"
  (unbound__zones (list
      
      (name "forward-all-to-google")
      (comment "Forward all DNS queries to Google Public DNS")
      (zone ".")
      (nameservers (list
          "8.8.8.8"
          "8.8.4.4"
          "2001:4860:4860::8888"
          "2001:4860:4860::8844")))))
