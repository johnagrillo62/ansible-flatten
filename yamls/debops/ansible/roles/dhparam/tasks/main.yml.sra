(playbook "debops/ansible/roles/dhparam/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Check Ansible Controller library version"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit &&
" (jinja "{% if dhparam__source_library == 'gnutls' %}") "
certtool --version | head -n 1 | awk '{print $NF}'
" (jinja "{% elif dhparam__source_library == 'openssl' %}") "
openssl version | awk '{print $2}'
" (jinja "{% endif %}") "
")
      (args 
        (executable "bash"))
      (changed_when "False")
      (register "dhparam__register_version")
      (delegate_to "localhost")
      (become "False")
      (run_once "True")
      (check_mode "False")
      (tags (list
          "meta::provision")))
    (task "Assert that required software is installed"
      (ansible.builtin.assert 
        (that (list
            "dhparam__register_version is defined and dhparam__register_version.stdout")))
      (delegate_to "localhost")
      (become "False")
      (run_once "True")
      (tags (list
          "meta::provision")))
    (task "Create required directories on Ansible Controller"
      (ansible.builtin.file 
        (path (jinja "{{ dhparam__source_path }}"))
        (state "directory")
        (mode "0755"))
      (delegate_to "localhost")
      (become "False")
      (run_once "True")
      (tags (list
          "meta::provision")))
    (task "Generate Diffie-Hellman params on Ansible Controller"
      (ansible.builtin.command (jinja "{% if dhparam__source_library == 'gnutls' %}") "
certtool --generate-dh-params
         --outfile " (jinja "{{ dhparam__source_path + \"/\" + dhparam__prefix + item + dhparam__suffix }}") "
         --bits " (jinja "{{ item }}") "
" (jinja "{% elif dhparam__source_library == 'openssl' %}") "
openssl dhparam " (jinja "{{ dhparam__openssl_options }}") " -out " (jinja "{{ dhparam__source_path + \"/\" + dhparam__prefix + item + dhparam__suffix }}") " " (jinja "{{ item }}") "
" (jinja "{% endif %}") "
")
      (args 
        (creates (jinja "{{ dhparam__source_path + \"/\" + dhparam__prefix + item + dhparam__suffix }}")))
      (with_items (jinja "{{ dhparam__bits }}"))
      (delegate_to "localhost")
      (become "False")
      (run_once "True")
      (tags (list
          "meta::provision")))
    (task "Install encryption software"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (dhparam__base_packages + dhparam__packages)) }}"))
        (state "present"))
      (when "dhparam__deploy_state in ['present']")
      (register "dhparam__register_packages")
      (until "dhparam__register_packages is succeeded")
      (tags (list
          "meta::provision")))
    (task "Create required directories"
      (ansible.builtin.file 
        (path (jinja "{{ dhparam__hook_path }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "dhparam__deploy_state in ['present']")
      (notify (list
          "Regenerate DH parameters on first install")))
    (task "Preseed Diffie-Hellman parameters"
      (ansible.builtin.copy 
        (src (jinja "{{ dhparam__source_path + \"/\" }}"))
        (dest (jinja "{{ dhparam__path + \"/params/\" + dhparam__set_prefix + item + \"/\" }}"))
        (owner "root")
        (group "root")
        (mode "0644")
        (force "False"))
      (with_sequence "start=0 count=" (jinja "{{ dhparam__sets }}"))
      (when "dhparam__deploy_state in ['present']")
      (notify (list
          "Execute DH parameter hooks")))
    (task "Create default symlinks for all sets"
      (ansible.builtin.file 
        (src (jinja "{{ \"params/\" + dhparam__set_prefix + item + \"/\"
             + dhparam__prefix + dhparam__default_length + dhparam__suffix }}"))
        (path (jinja "{{ dhparam__path + \"/\" + dhparam__set_prefix + item }}"))
        (state "link")
        (mode "0644"))
      (with_sequence "start=0 count=" (jinja "{{ dhparam__sets }}"))
      (when "dhparam__deploy_state in ['present'] and not ansible_check_mode"))
    (task "Install DHE generation script"
      (ansible.builtin.template 
        (src "usr/local/lib/dhparam-generate-params.j2")
        (dest (jinja "{{ dhparam__generate_params }}"))
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "dhparam__deploy_state in ['present']"))
    (task "Enable periodic DH parameters generation via cron"
      (ansible.builtin.cron 
        (name "Generate new Diffie-Hellman ephemeral parameters")
        (job "test -x " (jinja "{{ dhparam__generate_params }}") " && " (jinja "{{ dhparam__generate_params }}") " schedule")
        (cron_file "dhparam-generate-params")
        (user "root")
        (special_time (jinja "{{ dhparam__generate_cron_period }}"))
        (state (jinja "{{ \"present\"
               if (ansible_service_mgr != \"systemd\" and
                   dhparam__generate_cron | bool and
                   dhparam__deploy_state in [\"present\"])
               else \"absent\" }}")))
      (when "not ansible_check_mode"))
    (task "Setup systemd timer for periodic DH parameter regeneration"
      (ansible.builtin.template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "etc/systemd/system/dhparam-generate-params.service"
          "etc/systemd/system/dhparam-generate-params.timer"))
      (register "dhparam__register_systemd")
      (when "dhparam__deploy_state in ['present'] and ansible_service_mgr == 'systemd'"))
    (task "Enable systemd timer"
      (ansible.builtin.systemd 
        (daemon_reload "True")
        (name "dhparam-generate-params.timer")
        (enabled (jinja "{{ True
                 if (dhparam__generate_cron | bool)
                 else False }}"))
        (state (jinja "{{ \"started\"
                 if (dhparam__generate_cron | bool)
                 else \"stopped\" }}")))
      (when "dhparam__deploy_state in ['present'] and ansible_service_mgr == 'systemd' and not ansible_check_mode"))
    (task "Make sure the Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "dhparam__deploy_state in ['present']"))
    (task "Save dhparam local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/dhparam.fact.j2")
        (dest "/etc/ansible/facts.d/dhparam.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Gather facts if they changed"
      (ansible.builtin.meta "flush_handlers"))))
