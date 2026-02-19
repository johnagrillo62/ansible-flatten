(playbook "debops/ansible/roles/influxdata/defaults/main.yml"
  (influxdata__key_id "9D53 9D90 D332 8DC7 D6C8 D3B9 D8FF 8E1F 7DF8 B07E")
  (influxdata__repository "deb https://repos.influxdata.com/" (jinja "{{ ansible_distribution | lower }}") " stable main")
  (influxdata__packages (list))
  (influxdata__group_packages (list))
  (influxdata__host_packages (list))
  (influxdata__dependent_packages (list))
  (influxdata__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ influxdata__key_id }}")))))
