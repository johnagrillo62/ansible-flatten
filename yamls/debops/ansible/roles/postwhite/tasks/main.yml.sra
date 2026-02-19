(playbook "debops/ansible/roles/postwhite/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (postwhite__base_packages
                              + postwhite__packages)) }}"))
        (state "present"))
      (register "postwhite__register_packages")
      (until "postwhite__register_packages is succeeded"))
    (task "Create the UNIX system group"
      (ansible.builtin.group 
        (name (jinja "{{ postwhite__group }}"))
        (state "present")
        (system "True")))
    (task "Create the UNIX system account"
      (ansible.builtin.user 
        (name (jinja "{{ postwhite__user }}"))
        (group (jinja "{{ postwhite__group }}"))
        (home (jinja "{{ postwhite__home }}"))
        (comment (jinja "{{ postwhite__gecos }}"))
        (shell (jinja "{{ postwhite__shell }}"))
        (state "present")
        (system "True")))
    (task "Create the source directory"
      (ansible.builtin.file 
        (path (jinja "{{ postwhite__src }}"))
        (state "directory")
        (owner (jinja "{{ postwhite__user }}"))
        (group (jinja "{{ postwhite__group }}"))
        (mode "0755")))
    (task "Clone and install the software stack"
      (ansible.builtin.git 
        (repo (jinja "{{ item.git_repo }}"))
        (dest (jinja "{{ item.git_dest }}"))
        (version (jinja "{{ item.git_version }}"))
        (update "True"))
      (with_items (jinja "{{ postwhite__software_stack }}"))
      (become "True")
      (become_user (jinja "{{ postwhite__user }}")))
    (task "Generate Postwhite configuration"
      (ansible.builtin.template 
        (src "etc/postwhite.conf.j2")
        (dest "/etc/postwhite.conf")
        (owner "root")
        (group "root")
        (mode "0644")))
    (task "Install the Postwhite wrapper script"
      (ansible.builtin.template 
        (src "usr/local/lib/postwhite.j2")
        (dest "/usr/local/lib/postwhite")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Update Yahoo! static host list"
      (ansible.builtin.command "bash " (jinja "{{ postwhite__git_dest }}") "/scrape_yahoo")
      (become "True")
      (become_user (jinja "{{ postwhite__user }}"))
      (notify (list
          "Update Postwhite in the background using async"
          "Update Postwhite in the background using batch"))
      (register "postwhite__register_scrape_yahoo")
      (changed_when "postwhite__register_scrape_yahoo.changed | bool")
      (when "(ansible_local is undefined or (ansible_local | d() and ansible_local.postwhite is undefined or (ansible_local.postwhite | d() and not (ansible_local.postwhite.installed | d()) | bool)))"))
    (task "Initialize whitelist/blacklist files"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "touch")
        (owner (jinja "{{ postwhite__user }}"))
        (group (jinja "{{ postwhite__group }}"))
        (mode "0644"))
      (with_items (list
          (jinja "{{ postwhite__spf_whitelist_path }}")
          (jinja "{{ postwhite__spf_blacklist_path }}")))
      (when "(ansible_local is undefined or (ansible_local | d() and ansible_local.postwhite is undefined or (ansible_local.postwhite | d() and not (ansible_local.postwhite.installed | d()) | bool)))"))
    (task "Update Postwhite access lists daily"
      (ansible.builtin.cron 
        (job "/usr/local/lib/postwhite")
        (cron_file "postwhite")
        (name "Update Postwhite access lists")
        (special_time (jinja "{{ postwhite__cron_whitelist_update_frequency }}"))
        (user "root")
        (state "present")))
    (task "Update Yahoo IP address list weekly"
      (ansible.builtin.cron 
        (job "bash " (jinja "{{ postwhite__git_dest + \"/scrape_yahoo\" }}") " > /dev/null")
        (cron_file "postwhite")
        (name "Update Yahoo IP address list")
        (special_time (jinja "{{ postwhite__cron_yahoo_update_frequency }}"))
        (user "postwhite")
        (state "present")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save Postwhite local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/postwhite.fact.j2")
        (dest "/etc/ansible/facts.d/postwhite.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
