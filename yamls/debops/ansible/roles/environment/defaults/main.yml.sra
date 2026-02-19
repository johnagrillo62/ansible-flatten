(playbook "debops/ansible/roles/environment/defaults/main.yml"
  (environment__enabled (jinja "{{ lookup(\"template\", \"lookup/environment__enabled.j2\")
                          | from_yaml | bool }}"))
  (environment__file "/etc/environment")
  (environment__case "preserve")
  (environment__placement "before")
  (environment__default_variables (list
      (jinja "{{ inventory__environment | d({}) }}")
      (jinja "{{ inventory__group_environment | d({}) }}")
      (jinja "{{ inventory__host_environment | d({}) }}")))
  (environment__variables (list))
  (environment__group_variables (list))
  (environment__host_variables (list))
  (environment__dependent_variables (list)))
