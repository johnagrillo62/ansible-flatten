(playbook "debops/docs/ansible/roles/avahi/examples/avahi-tasks.yml"
  (tasks
    (task "Ensure that Avahi directories exist"
      (file 
        (path "/etc/avahi/services")
        (state "directory")
        (mode "0755")))
    (task "Generate Avahi service configuration"
      (template 
        (src "etc/avahi/services/application.xml.j2")
        (dest "/etc/avahi/services/application.xml")
        (mode "0644")))
    (task "Add mDNS CNAME resource record for the application"
      (lineinfile 
        (path "/etc/avahi/aliases")
        (regexp "^application\\.local$")
        (line "application.local")
        (state "present")
        (create "True")
        (mode "0644")))))
