(playbook "debops/ansible/roles/controller/defaults/main.yml"
  (controller__base_packages (list
      "git"
      "uuid-runtime"))
  (controller__packages (list))
  (controller__pip_packages (list
      "debops"))
  (controller__install_systemwide "True")
  (controller__update_method (jinja "{{ (\"batch\"
                                if (ansible_local | d() and ansible_local.atd | d() and
                                    ansible_local.atd.enabled | bool)
                                else \"async\") }}"))
  (controller__async_timeout (jinja "{{ (60 * 20) }}"))
  (controller__data_path (jinja "{{ (ansible_local.fhs.share | d(\"/usr/local/share\"))
                            + \"/debops\" }}"))
  (controller__project_git_repo "")
  (controller__project_name "")
  (controller__python__dependent_packages3 (list
      "python3-dev"
      "python3-dnspython"
      "python3-netaddr"
      "python3-passlib"
      "python3-setuptools"
      (jinja "{{ ([]
         if (ansible_distribution_release in
             [\"stretch\", \"trusty\", \"xenial\"])
         else \"python3-ldap\") }}")))
  (controller__python__dependent_packages2 (list
      "python-dev"
      "python-dnspython"
      "python-ldap"
      "python-netaddr"
      "python-passlib"
      "python-setuptools")))
