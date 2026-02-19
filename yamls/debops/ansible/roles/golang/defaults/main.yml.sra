(playbook "debops/ansible/roles/golang/defaults/main.yml"
  (golang__user "_golang")
  (golang__group "_golang")
  (golang__home (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\"))
                  + \"/\" + golang__user }}"))
  (golang__shell "/usr/sbin/nologin")
  (golang__comment "Go build environment")
  (golang__apt_dev_packages (list
      "golang-go"
      "make"))
  (golang__env_gopath (jinja "{{ golang__home + \"/go\" }}") ":/usr/share/gocode")
  (golang__env_gocache (jinja "{{ golang__home + \"/.cache/go\" }}"))
  (golang__env_path (jinja "{{ golang__home + \"/go/bin:\" + ansible_env.PATH }}"))
  (golang__gosrc (jinja "{{ golang__home + \"/go/src\" }}"))
  (golang__git_depth "0")
  (golang__bin_database "/usr/local/etc/golang-binaries")
  (golang__default_packages (list
      
      (name "golang-go")
      (apt_packages "golang-go")
      (state (jinja "{{ \"ignore\" if golang__dependent_packages | d() else \"present\" }}"))))
  (golang__packages (list))
  (golang__group_packages (list))
  (golang__host_packages (list))
  (golang__dependent_packages (list))
  (golang__combined_packages (jinja "{{ golang__default_packages
                               + golang__dependent_packages
                               + golang__packages
                               + golang__group_packages
                               + golang__host_packages }}"))
  (golang__keyring__dependent_gpg_user (jinja "{{ golang__user }}"))
  (golang__keyring__dependent_gpg_keys (list
      
      (user (jinja "{{ golang__user }}"))
      (group (jinja "{{ golang__group }}"))
      (home (jinja "{{ golang__home }}"))
      (state (jinja "{{ \"present\"
               if (q(\"flattened\", golang__combined_packages) | debops.debops.parse_kv_items
                   | selectattr(\"gpg\", \"defined\") | selectattr(\"state\", \"equalto\", \"present\")
                   | map(attribute=\"gpg\") | list)
               else \"absent\" }}"))
      (jinja "{{ q(\"flattened\", golang__combined_packages) | debops.debops.parse_kv_items
        | selectattr(\"gpg\", \"defined\") | selectattr(\"state\", \"equalto\", \"present\")
        | map(attribute=\"gpg\") | list }}")))
  (golang__apt_preferences__dependent_list (list
      
      (packages (list
          "golang"
          "golang-*"
          "dh-golang"))
      (backports (list
          "stretch"
          "buster"
          "trusty"))
      (reason "Closer feature parity with upstream")
      (by_role "debops.golang"))))
