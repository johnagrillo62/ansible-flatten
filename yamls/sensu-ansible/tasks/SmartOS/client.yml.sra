(playbook "sensu-ansible/tasks/SmartOS/client.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "client"))
    (task "Deploy Sensu client service manifest"
      (template 
        (dest "/opt/local/lib/svc/manifest/sensu-client.xml")
        (src "sensu-client.smartos_smf_manifest.xml.j2")
        (owner "root")
        (group "root")
        (mode "0644"))
      (tags "client")
      (notify (list
          "import sensu-client service"
          "restart sensu-client service")))
    (task
      (meta "flush_handlers")
      (tags "client"))))
