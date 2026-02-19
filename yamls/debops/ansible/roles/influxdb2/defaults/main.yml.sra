(playbook "debops/ansible/roles/influxdb2/defaults/main.yml"
  (influxdb2__base_packages (list
      "influxdb2"
      "influxdb2-cli"))
  (influxdb2__packages (list))
  (influxdb2__fqdn (jinja "{{ ansible_fqdn }}"))
  (influxdb2__port "8086")
  (influxdb2__allow (list))
  (influxdb2__default_configuration (list
      
      (name "default")
      (config 
        (bolt-path "/var/lib/influxdb/influxd.bolt")
        (engine-path "/var/lib/influxdb/engine"))))
  (influxdb2__configuration (list))
  (influxdb2__combined_configuration (jinja "{{ influxdb2__default_configuration +
                                       influxdb2__configuration }}"))
  (influxdb2__influxdata__dependent_packages (list
      (jinja "{{ influxdb2__base_packages }}")
      (jinja "{{ influxdb2__packages }}")))
  (influxdb2__etc_services__dependent_list (list
      
      (name "influxdb2-http")
      (port (jinja "{{ influxdb2__port }}"))
      (protocol (list
          "tcp"))))
  (influxdb2__nginx__dependent_upstreams (list
      
      (name "influxdb2_upstream")
      (server (jinja "{{ \"127.0.0.1:\" + influxdb2__port }}"))
      (state "present")))
  (influxdb2__nginx__dependent_servers (list
      
      (name (jinja "{{ influxdb2__fqdn }}"))
      (by_role "debops.influxdb2")
      (filename "debops.influxdb2")
      (state "present")
      (type "proxy")
      (proxy_pass "http://influxdb2_upstream")
      (allow (jinja "{{ influxdb2__allow }}")))))
