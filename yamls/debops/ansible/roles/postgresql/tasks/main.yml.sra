(playbook "debops/ansible/roles/postgresql/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Get default PostgreSQL version"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && apt-cache policy postgresql-client | grep -E '^\\s+Candidate:\\s+' | awk '{print $2}' | cut -d+ -f1")
      (environment 
        (LC_ALL "C"))
      (args 
        (executable "bash"))
      (register "postgresql__register_version")
      (check_mode "False")
      (changed_when "False"))
    (task "Set default PostgreSQL version variable"
      (ansible.builtin.set_fact 
        (postgresql__version (jinja "{{ (ansible_local.postgresql.version
                              if (ansible_local.postgresql.version | d())
                                 else (postgresql__preferred_version
                                       if postgresql__preferred_version | d()
                                       else postgresql__register_version.stdout)) }}"))))
    (task "Install PostgreSQL packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (postgresql__base_packages
                              + postgresql__python_packages
                              + postgresql__packages)) }}"))
        (state "present"))
      (register "postgresql__register_packages")
      (until "postgresql__register_packages is succeeded"))
    (task "Check if database server is installed"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && dpkg-query -W -f='${Version}\\n' 'postgresql' | grep -v '^$'")
      (environment 
        (LC_MESSAGES "C"))
      (args 
        (executable "bash"))
      (register "postgresql__register_server")
      (changed_when "False")
      (check_mode "False")
      (failed_when "False"))
    (task "Configure system-wide user to cluster mapping"
      (ansible.builtin.template 
        (src "etc/postgresql-common/user_clusters.j2")
        (dest "/etc/postgresql-common/user_clusters")
        (owner "root")
        (group "root")
        (mode "0644")))
    (task "Make sure that Ansible local fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save PostgreSQL local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/postgresql.fact.j2")
        (dest "/etc/ansible/facts.d/postgresql.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Drop PostgreSQL roles if requested"
      (community.postgresql.postgresql_user 
        (name (jinja "{{ item.name | d(item.role) }}"))
        (port (jinja "{{ item.port | d(postgresql__port if postgresql__port else omit) }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", postgresql__roles
                           + postgresql_roles | d([])
                           + postgresql__dependent_roles) }}"))
      (become "True")
      (become_user (jinja "{{ postgresql__user }}"))
      (delegate_to (jinja "{{ postgresql__delegate_to }}"))
      (when "item.state | d('present') == 'absent'")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Create PostgreSQL roles"
      (community.postgresql.postgresql_user 
        (name (jinja "{{ item.name | d(item.role) }}"))
        (port (jinja "{{ item.port | d(postgresql__port if postgresql__port else omit) }}"))
        (password (jinja "{{ item.password | d(lookup(\"password\",
                  secret + \"/postgresql/\" + postgresql__password_hostname +
                  \"/\" + (item.port | d(postgresql__port)) +
                  \"/credentials/\" + item.name | d(item.role) + \"/password \" +
                  \"length=\" + postgresql__password_length + \" chars=\" + postgresql__password_characters)) }}"))
        (encrypted (jinja "{{ item.encrypted | d(True) }}"))
        (expires (jinja "{{ item.expires | d(omit) }}"))
        (role_attr_flags (jinja "{{ (item.flags | d() | join(\",\")) | d(omit) }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", postgresql__roles
                           + postgresql_roles | d([])
                           + postgresql__dependent_roles) }}"))
      (become "True")
      (become_user (jinja "{{ postgresql__user }}"))
      (delegate_to (jinja "{{ postgresql__delegate_to }}"))
      (when "item.state | d('present') == 'present'")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Drop PostgreSQL databases if requested"
      (community.postgresql.postgresql_db 
        (name (jinja "{{ item.name | d(item.database) }}"))
        (port (jinja "{{ item.port | d(postgresql__port if postgresql__port else omit) }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", postgresql__databases
                           + postgresql_databases | d([])
                           + postgresql__dependent_databases) }}"))
      (become "True")
      (become_user (jinja "{{ postgresql__user }}"))
      (delegate_to (jinja "{{ postgresql__delegate_to }}"))
      (when "item.state | d('present') == 'absent'"))
    (task "Create PostgreSQL databases"
      (community.postgresql.postgresql_db 
        (name (jinja "{{ item.name | d(item.database) }}"))
        (port (jinja "{{ item.port | d(postgresql__port if postgresql__port else omit) }}"))
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (template (jinja "{{ item.template | d(omit) }}"))
        (encoding (jinja "{{ item.encoding | d(omit) }}"))
        (lc_collate (jinja "{{ item.lc_collate | d(omit) }}"))
        (lc_ctype (jinja "{{ item.lc_ctype | d(omit) }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", postgresql__databases
                           + postgresql_databases | d([])
                           + postgresql__dependent_databases) }}"))
      (become "True")
      (become_user (jinja "{{ postgresql__user }}"))
      (delegate_to (jinja "{{ postgresql__delegate_to }}"))
      (when "(item.state | d('present') == 'present') and item.create_db | d(True)"))
    (task "Enable or disable specified database extensions"
      (community.postgresql.postgresql_ext 
        (db (jinja "{{ item.database }}"))
        (name (jinja "{{ item.extension }}"))
        (port (jinja "{{ item.port | d(postgresql__port if postgresql__port else omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}")))
      (loop (jinja "{{ q(\"flattened\", postgresql__extensions
                           + postgresql__dependent_extensions) }}"))
      (become "True")
      (become_user (jinja "{{ postgresql__user }}"))
      (delegate_to (jinja "{{ postgresql__delegate_to }}"))
      (when "item.state | d('present') in ['present', 'absent']"))
    (task "Grant public schema permissions"
      (community.postgresql.postgresql_privs 
        (roles (jinja "{{ item.owner }}"))
        (port (jinja "{{ item.port | d(postgresql__port if postgresql__port else omit) }}"))
        (type (jinja "{{ item.type | d(\"schema\") }}"))
        (database (jinja "{{ item.name | d(item.database) }}"))
        (objs (jinja "{{ item.objs | d(\"public\") }}"))
        (privs (jinja "{{ item.public_privs | d([\"ALL\"]) | join(\",\") }}"))
        (grant_option (jinja "{{ item.grant_option | d(\"yes\") }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", postgresql__databases
                           + postgresql_databases | d([])
                           + postgresql__dependent_databases) }}"))
      (become "True")
      (become_user (jinja "{{ postgresql__user }}"))
      (delegate_to (jinja "{{ postgresql__delegate_to }}"))
      (when "(item.state | d('present') == 'present') and item.owner | d()"))
    (task "Grant PostgreSQL groups"
      (community.postgresql.postgresql_privs 
        (roles (jinja "{{ item.roles | join(\",\") }}"))
        (port (jinja "{{ item.port | d(postgresql__port if postgresql__port else omit) }}"))
        (type "group")
        (database (jinja "{{ item.database }}"))
        (objs (jinja "{{ item.groups | join(\",\") }}"))
        (grant_option (jinja "{{ item.grant_option | d(omit) }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", postgresql__groups
                           + postgresql_groups | d([])
                           + postgresql__dependent_groups) }}"))
      (become "True")
      (become_user (jinja "{{ postgresql__user }}"))
      (delegate_to (jinja "{{ postgresql__delegate_to }}"))
      (when "(item.state | d('present') == 'present') and item.enabled | d(True) | bool"))
    (task "Grant database privileges to PostgreSQL roles"
      (community.postgresql.postgresql_user 
        (name (jinja "{{ item.name | d(item.role) }}"))
        (port (jinja "{{ item.port | d(postgresql__port if postgresql__port else omit) }}"))
        (db (jinja "{{ item.db }}"))
        (priv (jinja "{{ item.priv | join(\"/\") }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", postgresql__roles
                           + postgresql_roles | d([])
                           + postgresql__dependent_roles) }}"))
      (become "True")
      (become_user (jinja "{{ postgresql__user }}"))
      (delegate_to (jinja "{{ postgresql__delegate_to }}"))
      (when "(item.state | d('present') == 'present') and (item.db | d() and item.priv | d())")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Grant or revoke extra privileges"
      (community.postgresql.postgresql_privs 
        (database (jinja "{{ item.database }}"))
        (port (jinja "{{ item.port | d(postgresql__port if postgresql__port else omit) }}"))
        (grant_option (jinja "{{ item.grant_option | d(omit) }}"))
        (objs (jinja "{{ item.objs | join(\",\") }}"))
        (privs (jinja "{{ item.public_privs | d([\"ALL\"]) | join(\",\") }}"))
        (roles (jinja "{{ item.roles | join(\",\") }}"))
        (schema (jinja "{{ item.schema | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (target_roles (jinja "{{ item.target_roles | d(omit) }}"))
        (type (jinja "{{ item.type }}")))
      (loop (jinja "{{ q(\"flattened\", postgresql__privileges
                           + postgresql__dependent_privileges) }}"))
      (become "True")
      (become_user (jinja "{{ postgresql__user }}"))
      (delegate_to (jinja "{{ postgresql__delegate_to }}"))
      (when "(item.state | d('present') == 'present') and item.enabled | d(True) | bool"))
    (task "Make sure required system groups exist"
      (ansible.builtin.group 
        (name (jinja "{{ item.group | d(item.owner) }}"))
        (state "present")
        (system (jinja "{{ item.system | d(True) }}")))
      (loop (jinja "{{ q(\"flattened\", postgresql__pgpass
                           + postgresql_pgpass | d([])
                           + postgresql__dependent_pgpass) }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Make sure required system accounts exist"
      (ansible.builtin.user 
        (name (jinja "{{ item.owner }}"))
        (group (jinja "{{ item.group | d(item.owner) }}"))
        (home (jinja "{{ item.home | d(omit) }}"))
        (state "present")
        (system (jinja "{{ item.system | d(True) }}")))
      (loop (jinja "{{ q(\"flattened\", postgresql__pgpass
                           + postgresql_pgpass | d([])
                           + postgresql__dependent_pgpass) }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Populate ~/.pgpass file"
      (ansible.builtin.lineinfile 
        (dest (jinja "{{ \"~\" + item.owner }}") "/.pgpass")
        (regexp (jinja "{{ \"^\" + ([((item.server | d(postgresql__server if postgresql__server else \"localhost\")) | replace(\".\", \"\\.\")),
                        (item.port | d(postgresql__port)),
                        (item.database | d(\"\\*\")),
                        (item.name | d(item.role | d(item.owner | d(\"\\*\"))))] | join(\":\")) + \":\" }}"))
        (line (jinja "{{ [(item.server | d(postgresql__server if postgresql__server else \"localhost\")),
               (item.port | d(postgresql__port)),
               (item.database | d(\"*\")),
               (item.role | d(item.owner)),
               (item.password | d(lookup(\"password\",
                                  secret + \"/postgresql/\" + (item.server | d(postgresql__password_hostname))
                                  + \"/\" + (item.port | d(postgresql__port)) + \"/credentials/\"
                                  + item.name | d(item.role | d(item.owner))
                                  + \"/password length=\" + postgresql__password_length))
                                 | regex_replace(\"\\\\\", \"\\\\\\\\\") | regex_replace(\":\", \"\\:\"))]
              | join(\":\") }}"))
        (state "present")
        (create "True")
        (owner (jinja "{{ item.owner }}"))
        (group (jinja "{{ item.owner }}"))
        (mode "0600"))
      (loop (jinja "{{ q(\"flattened\", postgresql__pgpass
                           + postgresql_pgpass | d([])
                           + postgresql__dependent_pgpass) }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))))
