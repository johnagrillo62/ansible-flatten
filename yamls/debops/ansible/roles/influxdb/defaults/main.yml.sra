(playbook "debops/ansible/roles/influxdb/defaults/main.yml"
  (influxdb__server "")
  (influxdb__port "8086")
  (influxdb__delegate_to (jinja "{{ inventory_hostname }}"))
  (influxdb__pki (jinja "{{ ansible_local.pki.enabled | d() | bool }}"))
  (influxdb__password_length "48")
  (influxdb__root_password (jinja "{{ lookup(\"password\",
                             secret + \"/influxdb/\" + influxdb__server +
                             \"/credentials/root/password \" +
                             \"length=\" + influxdb__password_length) }}"))
  (influxdb__databases (list))
  (influxdb__dependent_databases (list))
  (influxdb__retention_policies (list))
  (influxdb__dependent_retention_policies (list))
  (influxdb__users (list))
  (influxdb__dependent_users (list))
  (influxdb__python__dependent_packages3 (list
      "python3-influxdb"))
  (influxdb__python__dependent_packages2 (list
      "python-influxdb")))
