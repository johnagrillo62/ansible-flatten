(playbook "yaml/roles/common/tasks/letsencrypt.yml"
  (tasks
    (task "Add group name ssl-cert for SSL certificates"
      (group 
        (name "ssl-cert")
        (state "present")))
    (task "Download LetsEncrypt release"
      (git "repo=https://github.com/letsencrypt/letsencrypt dest=/root/letsencrypt version=master force=yes"))
    (task "Create directory for LetsEncrypt configuration and certificates"
      (file "state=directory path=/etc/letsencrypt group=root owner=root"))
    (task "Configure LetsEncrypt"
      (template "src=etc_letsencrypt_cli.conf.j2 dest=/etc/letsencrypt/cli.conf owner=root group=root"))
    (task "Install LetsEncrypt package dependencies"
      (command "/root/letsencrypt/letsencrypt-auto --help")
      (register "le_deps_result")
      (changed_when "'Bootstrapping dependencies' in le_deps_result.stdout"))
    (task "Create directory for pre-renewal scripts"
      (file "state=directory path=/etc/letsencrypt/prerenew group=root owner=root"))
    (task "Create directory for post-renewal scripts"
      (file "state=directory path=/etc/letsencrypt/postrenew group=root owner=root"))
    (task "Create pre-renew hook to stop apache"
      (copy 
        (content "#!/bin/bash

service apache2 stop
")
        (dest "/etc/letsencrypt/prerenew/apache")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Create post-renew hook to start apache"
      (copy 
        (content "#!/bin/bash

service apache2 start
")
        (dest "/etc/letsencrypt/postrenew/apache")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Install crontab entry for LetsEncrypt"
      (copy 
        (src "etc_cron-daily_letsencrypt-renew")
        (dest "/etc/cron.daily/letsencrypt-renew")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Create live directory for LetsEncrypt cron job"
      (file "state=directory path=/etc/letsencrypt/live group=root owner=root"))
    (task "Get an SSL certificate for " (jinja "{{ domain }}") " from Let's Encrypt"
      (script "letsencrypt-gencert " (jinja "{{ domain }}") " creates=/etc/letsencrypt/live/" (jinja "{{ domain }}") "/privkey.pem")
      (when "ansible_ssh_user != \"vagrant\""))
    (task "Modify permissions to allow ssl-cert group access"
      (file "path=/etc/letsencrypt/archive owner=root group=ssl-cert mode=0750")
      (when "ansible_ssh_user != \"vagrant\""))
    (task "Create live directory for testing keys"
      (file "dest=/etc/letsencrypt/live/" (jinja "{{ domain }}") " state=directory owner=root group=root mode=0755")
      (when "ansible_ssh_user == \"vagrant\""))
    (task "Copy SSL wildcard private key for testing"
      (copy "src=wildcard_private.key dest=/etc/letsencrypt/live/" (jinja "{{ domain }}") "/privkey.pem owner=root group=ssl-cert mode=0640")
      (register "private_key")
      (when "ansible_ssh_user == \"vagrant\""))
    (task "Copy SSL public certificate into place for testing"
      (copy "src=wildcard_public_cert.crt dest=/etc/letsencrypt/live/" (jinja "{{ domain }}") "/cert.pem group=root owner=root mode=0644")
      (register "certificate")
      (notify "restart apache")
      (when "ansible_ssh_user == \"vagrant\""))
    (task "Copy SSL CA combined certificate into place for testing"
      (copy "src=wildcard_ca.pem dest=/etc/letsencrypt/live/" (jinja "{{ domain }}") "/chain.pem group=root owner=root mode=0644")
      (register "ca_certificate")
      (notify "restart apache")
      (when "ansible_ssh_user == \"vagrant\""))
    (task "Create a combined SSL cert for testing"
      (shell "cat /etc/letsencrypt/live/" (jinja "{{ domain }}") "/cert.pem /etc/letsencrypt/live/" (jinja "{{ domain }}") "/chain.pem > /etc/letsencrypt/live/" (jinja "{{ domain }}") "/fullchain.pem")
      (when "(private_key.changed or certificate.changed or ca_certificate.changed) and ansible_ssh_user == \"vagrant\"")
      (tags (list
          "skip_ansible_lint")))
    (task "Set permissions on combined SSL public cert"
      (file "name=/etc/letsencrypt/live/" (jinja "{{ domain }}") "/fullchain.pem mode=0644")
      (notify "restart apache")
      (when "ansible_ssh_user == \"vagrant\""))))
