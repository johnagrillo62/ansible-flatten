(playbook "debops/ansible/roles/homeassistant/tasks/main.yml"
  (tasks
    (task "Ensure specified packages are in there desired state"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", homeassistant__combined_packages) }}")))
      (when "(homeassistant__deploy_state == \"present\")")
      (register "homeassistant__register_packages")
      (until "homeassistant__register_packages is succeeded")
      (tags (list
          "role::homeassistant:pkgs")))
    (task "Create Home Assistant system group"
      (ansible.builtin.group 
        (name (jinja "{{ homeassistant__group }}"))
        (state (jinja "{{ \"present\" if (homeassistant__deploy_state == \"present\") else \"absent\" }}"))
        (system "True")))
    (task "Create Home Assistant system user"
      (ansible.builtin.user 
        (name (jinja "{{ homeassistant__user }}"))
        (group (jinja "{{ homeassistant__group }}"))
        (groups (jinja "{{ homeassistant__groups | join(\",\") | default(omit) }}"))
        (append "False")
        (home (jinja "{{ homeassistant__home_path }}"))
        (comment (jinja "{{ homeassistant__gecos }}"))
        (shell (jinja "{{ homeassistant__shell }}"))
        (state (jinja "{{ \"present\" if (homeassistant__deploy_state == \"present\") else \"absent\" }}"))
        (system "True")))
    (task "Clone Home Assistant git repository"
      (ansible.builtin.git 
        (repo (jinja "{{ homeassistant__git_repo }}"))
        (dest (jinja "{{ homeassistant__git_dest }}"))
        (depth (jinja "{{ homeassistant__git_depth }}"))
        (version (jinja "{{ homeassistant__git_version }}"))
        (recursive (jinja "{{ homeassistant__git_recursive | bool }}"))
        (update (jinja "{{ homeassistant__git_update | bool }}")))
      (become "True")
      (become_user (jinja "{{ homeassistant__user }}"))
      (register "homeassistant__register_git")
      (when "(homeassistant__deploy_state == \"present\")"))
    (task "Install hass without virtualenv"
      (ansible.builtin.pip 
        (name ".")
        (chdir (jinja "{{ homeassistant__git_dest }}"))
        (executable "pip3")
        (extra_args "--user --upgrade"))
      (become "True")
      (become_user (jinja "{{ homeassistant__user }}"))
      (when "not homeassistant__virtualenv | bool and homeassistant__register_git is changed")
      (notify (list
          "Restart Home Assistant")))
    (task "Install hass in virtualenv"
      (ansible.builtin.pip 
        (name ".")
        (chdir (jinja "{{ homeassistant__git_dest }}"))
        (extra_args "--upgrade")
        (virtualenv (jinja "{{ homeassistant__virtualenv_path }}"))
        (virtualenv_python "python3"))
      (become "True")
      (become_user (jinja "{{ homeassistant__user }}"))
      (when "homeassistant__virtualenv | bool and homeassistant__register_git is changed")
      (notify (list
          "Restart Home Assistant")))
    (task "Ensure Home Assistant config dir exists"
      (ansible.builtin.file 
        (path (jinja "{{ homeassistant__home_path }}") "/.homeassistant")
        (mode "0750")
        (state "directory"))
      (become "True")
      (become_user (jinja "{{ homeassistant__user }}"))
      (when "(homeassistant__deploy_state == \"present\")"))
    (task "Ensure Home Assistant www dir exists"
      (ansible.builtin.file 
        (path (jinja "{{ homeassistant__home_path }}") "/www")
        (owner (jinja "{{ homeassistant__user }}"))
        (group (jinja "{{ homeassistant__webserver_user }}"))
        (mode "0750")
        (state "directory"))
      (when "(homeassistant__deploy_state == \"present\")"))
    (task "Ensure Home Assistant www in config dir is a symlink"
      (ansible.builtin.file 
        (src (jinja "{{ homeassistant__home_path }}") "/www")
        (dest (jinja "{{ homeassistant__home_path }}") "/.homeassistant/www")
        (state "link")
        (mode "0755"))
      (become "True")
      (become_user (jinja "{{ homeassistant__user }}"))
      (when "(homeassistant__deploy_state == \"present\")"))
    (task "Configure systemd unit file"
      (ansible.builtin.template 
        (src "etc/systemd/system/home-assistant.service.j2")
        (dest "/etc/systemd/system/home-assistant.service")
        (owner "root")
        (group "root")
        (mode "0644"))
      (register "homeassistant__register_systemd_unit_file")
      (when "(homeassistant__deploy_state == \"present\")"))
    (task "Set Home Assistant state using systemd"
      (ansible.builtin.systemd 
        (name "home-assistant")
        (state (jinja "{{ \"started\" if (homeassistant__deploy_state == \"present\") else \"stopped\" }}"))
        (enabled "True")
        (masked "False")
        (daemon_reload (jinja "{{ homeassistant__register_systemd_unit_file is changed }}")))
      (when "(homeassistant__deploy_state == \"present\" and ansible_distribution_release not in [\"trusty\"])"))))
