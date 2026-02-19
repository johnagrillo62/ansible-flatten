(playbook "yaml/roles/common/tasks/main.yml"
  (tasks
    (task "Update apt cache"
      (apt "update_cache=yes")
      (tags (list
          "dependencies")))
    (task "Upgrade all safe packages"
      (apt "upgrade=safe")
      (tags (list
          "dependencies")))
    (task "Install necessities and nice-to-haves"
      (apt "pkg=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "apache2"
          "apt-transport-https"
          "apticron"
          "build-essential"
          "debian-goodies"
          "git"
          "htop"
          "iftop"
          "iotop"
          "molly-guard"
          "mosh"
          "python3-software-properties"
          "ruby"
          "screen"
          "sudo"
          "unattended-upgrades"
          "vim"
          "zsh"))
      (tags (list
          "dependencies")))
    (task "timezone - configure /etc/timezone"
      (copy 
        (content (jinja "{{ common_timezone | regex_replace('$', '\\n') }}"))
        (dest "/etc/timezone")
        (owner "root")
        (group "root")
        (mode "0644"))
      (register "common_timezone_config"))
    (task "timezone - Set localtime to UTC"
      (file "src=/usr/share/zoneinfo/Etc/UTC dest=/etc/localtime")
      (when "common_timezone_config.changed")
      (tags (list
          "skip_ansible_lint")))
    (task "timezone - reconfigure tzdata"
      (command "dpkg-reconfigure --frontend noninteractive tzdata")
      (when "common_timezone_config.changed")
      (tags (list
          "skip_ansible_lint")))
    (task "Apticron email configuration"
      (template "src=apticron.conf.j2 dest=/etc/apticron/apticron.conf"))
    (task "Create decrypted directory (even if encfs isn't used)"
      (file "state=directory path=/decrypted"))
    (task "Set decrypted directory permissions"
      (file "state=directory path=/decrypted group=mail mode=0775"))
    (task "Ensure locale en_US.UTF-8 locale is present"
      (locale_gen 
        (name "en_US.UTF-8")
        (state "present")))
    (task
      (import_tasks "encfs.yml")
      (tags "encfs"))
    (task
      (import_tasks "users.yml")
      (tags "users"))
    (task
      (import_tasks "apache.yml")
      (tags "apache"))
    (task
      (import_tasks "ssl.yml")
      (tags "ssl"))
    (task
      (import_tasks "letsencrypt.yml")
      (tags "letsencrypt"))
    (task
      (import_tasks "ufw.yml")
      (tags "ufw"))
    (task
      (import_tasks "security.yml")
      (tags "security"))
    (task
      (import_tasks "ntp.yml")
      (tags "ntp"))
    (task
      (import_tasks "google_auth.yml")
      (tags "google_auth"))
    (task
      (import_tasks "postgres.yml"))))
