(playbook "debops/ansible/playbooks/layer/env.yml"
  (tasks
    (task "Manage NodeJS environment"
      (import_playbook "../service/nodejs.yml"))
    (task "Manage Ruby environment"
      (import_playbook "../service/ruby.yml"))
    (task "Manage Go language environment"
      (import_playbook "../service/golang.yml"))
    (task "Manage Java environment"
      (import_playbook "../service/java.yml"))
    (task "Manage CRAN APT repositories"
      (import_playbook "../service/cran.yml"))
    (task "Manage PHP environment"
      (import_playbook "../service/php.yml"))
    (task "Manage fcgiwrap service"
      (import_playbook "../service/fcgiwrap.yml"))
    (task "Manage WordPress CLI tool"
      (import_playbook "../service/wpcli.yml"))))
