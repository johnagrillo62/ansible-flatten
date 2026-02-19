(playbook "debops/ansible/roles/gitusers/defaults/main.yml"
  (gitusers_list (list))
  (gitusers_group_list (list))
  (gitusers_host_list (list))
  (gitusers_name_suffix "")
  (gitusers_default_shell "/usr/bin/git-shell")
  (gitusers_default_groups_list (list
      "sshusers"))
  (gitusers_default_groups_append "yes")
  (gitusers_default_home_prefix (jinja "{{ (ansible_local.fhs.data | d(\"/srv\"))
                                  + \"/gitusers\" }}"))
  (gitusers_default_home_mode "0750")
  (gitusers_git_scripts (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\"))
                          + \"/gitusers\" }}"))
  (gitusers_default_www_prefix (jinja "{{ ansible_local.nginx.www if (ansible_local is defined and ansible_local.nginx is defined and ansible_local.nginx.www is defined) else \"/srv/www\" }}"))
  (gitusers_default_www_group (jinja "{{ ansible_local.nginx.user if (ansible_local is defined and ansible_local.nginx is defined and ansible_local.nginx.user is defined) else \"www-data\" }}"))
  (gitusers_default_domain (jinja "{{ ansible_domain }}"))
  (gitusers_default_user_domain (jinja "{{ ansible_fqdn }}"))
  (gitusers_default_permissions (list))
  (gitusers_default_hook_list "jekyll")
  (gitusers_default_hooks 
    (jekyll (list
        "post-receive.d/00_checkout"
        "post-checkout.d/00_submodule"
        "post-checkout.d/jekyll"))
    (deploy (list
        "post-receive.d/00_checkout"
        "post-checkout.d/00_submodule"
        "post-checkout.d/deploy"))))
