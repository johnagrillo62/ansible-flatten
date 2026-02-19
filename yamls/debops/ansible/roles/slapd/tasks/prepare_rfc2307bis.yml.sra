(playbook "debops/ansible/roles/slapd/tasks/prepare_rfc2307bis.yml"
  (tasks
    (task "Install APT packages with rfc2307bis LDAP schema"
      (ansible.builtin.package 
        (name (jinja "{{ slapd__rfc2307bis_packages }}"))
        (state "present"))
      (register "slapd__register_rfc2307bis_packages")
      (until "slapd__register_rfc2307bis_packages is succeeded"))
    (task "Divert the original NIS schema included in Debian"
      (debops.debops.dpkg_divert 
        (path "/etc/ldap/schema/" (jinja "{{ item }}")))
      (loop (list
          "nis.schema"
          "nis.ldif")))
    (task "Convert FusionDirectory rfc2307bis schema to ldif"
      (ansible.builtin.shell "schema2ldif rfc2307bis.schema > rfc2307bis.ldif")
      (args 
        (creates "/etc/ldap/schema/fusiondirectory/rfc2307bis.ldif")
        (chdir "/etc/ldap/schema/fusiondirectory"))
      (when "\"fusiondirectory-schema\" in slapd__rfc2307bis_packages"))
    (task "Symlink the new rfc2307bis schema in place of NIS schema"
      (ansible.builtin.file 
        (state "link")
        (path "/etc/ldap/schema/" (jinja "{{ item | replace(\"rfc2307bis\", \"nis\") }}"))
        (src (jinja "{{ ((\"fusiondirectory-schema\" in slapd__rfc2307bis_packages)
              | ternary(\"fusiondirectory\", \"gosa\")) + \"/\" + item }}"))
        (mode "0644"))
      (loop (list
          "rfc2307bis.schema"
          "rfc2307bis.ldif"))
      (when "not ansible_check_mode | bool"))))
