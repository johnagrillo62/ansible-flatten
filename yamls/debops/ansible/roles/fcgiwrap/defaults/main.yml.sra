(playbook "debops/ansible/roles/fcgiwrap/defaults/main.yml"
  (fcgiwrap__packages (list
      "fcgiwrap"))
  (fcgiwrap__instances (list))
  (fcgiwrap__disable_default "True")
  (fcgiwrap__threads (jinja "{{ ansible_processor_cores }}"))
  (fcgiwrap__options_map 
    (1.1 "-f -c " (jinja "{{ fcgiwrap__threads }}"))
    (1.0 "-c " (jinja "{{ fcgiwrap__threads }}")))
  (fcgiwrap__user "www-data")
  (fcgiwrap__group "www-data")
  (fcgiwrap__socket_user "www-data")
  (fcgiwrap__socket_group "www-data")
  (fcgiwrap__socket_mode "0660"))
