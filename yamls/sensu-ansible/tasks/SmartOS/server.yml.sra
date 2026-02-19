(playbook "sensu-ansible/tasks/SmartOS/server.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "server"))
    (task "Deploy Sensu server service manifest"
      (template 
        (dest "/opt/local/lib/svc/manifest/sensu-server.xml")
        (src "sensu-server.smartos_smf_manifest.xml.j2")
        (owner "root")
        (group "root")
        (mode "0644"))
      (tags "server")
      (notify "import sensu-server service"))
    (task "Deploy Sensu API service manifest"
      (template 
        (dest "/opt/local/lib/svc/manifest/sensu-api.xml")
        (src "sensu-api.smartos_smf_manifest.xml.j2")
        (owner "root")
        (group "root")
        (mode "0644"))
      (tags "server")
      (notify "import sensu-api service"))
    (task
      (meta "flush_handlers")
      (tags "server"))))
