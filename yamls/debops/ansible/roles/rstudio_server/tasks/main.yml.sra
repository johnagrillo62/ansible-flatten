(playbook "debops/ansible/roles/rstudio_server/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Check if rstudio-server package is available"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && apt-cache pkgnames | grep rstudio-server || true")
      (args 
        (executable "bash"))
      (register "rstudio_server__register_package_rstudio")
      (changed_when "False")
      (check_mode "False"))
    (task "Create required system groups"
      (ansible.builtin.group 
        (name (jinja "{{ item }}"))
        (state "present")
        (system "True"))
      (with_items (list
          (jinja "{{ rstudio_server__group }}")
          (jinja "{{ rstudio_server__auth_group }}"))))
    (task "Create system account for RStudio Server"
      (ansible.builtin.user 
        (name (jinja "{{ rstudio_server__user }}"))
        (group (jinja "{{ rstudio_server__group }}"))
        (home (jinja "{{ rstudio_server__home }}"))
        (shell (jinja "{{ rstudio_server__shell }}"))
        (comment (jinja "{{ rstudio_server__comment }}"))
        (system "True")
        (state "present")))
    (task "Get the current user accounts"
      (ansible.builtin.getent 
        (database "passwd")))
    (task "Allow specified user accounts to access RStudio Server"
      (ansible.builtin.user 
        (name (jinja "{{ item.name | d(item) }}"))
        (groups (jinja "{{ rstudio_server__auth_group }}"))
        (append "True"))
      (loop (jinja "{{ q(\"flattened\", rstudio_server__allow_users
                           + rstudio_server__group_allow_users
                           + rstudio_server__host_allow_users) }}"))
      (when "item.name | d(item) in getent_passwd.keys() and item.state | d('present') != 'absent'"))
    (task "Install RStudio Server packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (rstudio_server__base_packages
                              + rstudio_server__packages)) }}"))
        (state "present"))
      (register "rstudio_server__register_packages")
      (until "rstudio_server__register_packages is succeeded"))
    (task "Create source directory"
      (ansible.builtin.file 
        (path (jinja "{{ rstudio_server__src }}"))
        (state "directory")
        (owner (jinja "{{ rstudio_server__user }}"))
        (group (jinja "{{ rstudio_server__group }}"))
        (mode "0755"))
      (when "not rstudio_server__rstudio_in_apt | bool"))
    (task "Download RStudio Server .deb package"
      (ansible.builtin.get_url 
        (url (jinja "{{ rstudio_server__rstudio_deb_url }}"))
        (dest (jinja "{{ rstudio_server__src + \"/\" + rstudio_server__rstudio_deb_url | basename }}"))
        (checksum (jinja "{{ rstudio_server__rstudio_deb_checksum }}"))
        (mode "0644"))
      (become "True")
      (become_user (jinja "{{ rstudio_server__user }}"))
      (register "rstudio_server__register_rstudio_package")
      (until "rstudio_server__register_rstudio_package is succeeded")
      (when "not rstudio_server__rstudio_in_apt | bool"))
    (task "Verify RStudio Server package signature"
      (ansible.builtin.command "dpkg-sig --verify " (jinja "{{ rstudio_server__src + '/' + (rstudio_server__rstudio_deb_url | basename) }}"))
      (become "True")
      (become_user (jinja "{{ rstudio_server__user }}"))
      (changed_when "False")
      (check_mode "False"))
    (task "Install RStudio Server .deb package"
      (ansible.builtin.apt 
        (deb (jinja "{{ rstudio_server__src + \"/\" + rstudio_server__rstudio_deb_url | basename }}"))
        (state "present"))
      (register "rstudio_server__register_rstudio_deb")
      (until "rstudio_server__register_rstudio_deb is succeeded")
      (when "not rstudio_server__rstudio_in_apt | bool"))
    (task "Configure RStudio Server"
      (ansible.builtin.template 
        (src "etc/rstudio/" (jinja "{{ item }}") ".j2")
        (dest "/etc/rstudio/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "rserver.conf"
          "rsession.conf"))
      (notify (list
          "Verify rstudio-server")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save RStudio Server local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/rstudio_server.fact.j2")
        (dest "/etc/ansible/facts.d/rstudio_server.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
