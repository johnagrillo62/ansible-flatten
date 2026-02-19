(playbook "sensu-ansible/tasks/FreeBSD/dashboard.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "dashboard"))
    (task "Ensure Uchiwa (dashboard) dependencies are installed"
      (pkgng 
        (name (jinja "{{ item }}"))
        (state "present"))
      (tags "dashboard")
      (loop (list
          "go"
          "git"
          "npm")))
    (task "Ensure Uchiwa directory exists"
      (file 
        (dest (jinja "{{ sensu_uchiwa_path }}"))
        (state "directory")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}"))
        (recurse "true"))
      (tags "dashboard"))
    (task "Ensure Uchiwa Go/config directory exists"
      (file 
        (dest (jinja "{{ sensu_uchiwa_path }}") "/" (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}"))
        (recurse "true"))
      (tags "dashboard")
      (loop (list
          "etc"
          "go")))
    (task "Ensure Uchiwa GOPATH exists"
      (file 
        (dest (jinja "{{ sensu_uchiwa_path }}") "/go/" (jinja "{{ item }}"))
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}"))
        (state "directory")
        (recurse "true"))
      (tags "dashboard")
      (loop (list
          "bin"
          "pkg"
          "src")))
    (task "Fetch Uchiwa from GitHub"
      (command "go get github.com/sensu/uchiwa")
      (tags "dashboard")
      (environment 
        (GOPATH (jinja "{{ sensu_uchiwa_path }}") "/go"))
      (args 
        (creates (jinja "{{ sensu_uchiwa_path }}") "/go/src/github.com/sensu/uchiwa"))
      (notify "Build and deploy Uchiwa")
      (become "true")
      (become_user (jinja "{{ sensu_user_name }}")))
    (task
      (meta "flush_handlers")
      (tags "dashboard"))
    (task "Deploy Uchiwa config"
      (template 
        (src "uchiwa_config.json.j2")
        (dest (jinja "{{ sensu_uchiwa_path }}") "/etc/config.json")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}")))
      (tags "dashboard")
      (notify "restart uchiwa service"))
    (task "Deploy Uchiwa service file"
      (template 
        (src "uchiwa_freebsd.j2")
        (dest "/usr/local/etc/rc.d/uchiwa")
        (mode "0755"))
      (tags "dashboard"))
    (task "Ensure Uchiwa server service is running"
      (service "name=uchiwa state=started enabled=yes")
      (tags "dashboard"))))
