(playbook "debops/ansible/roles/postwhite/defaults/main.yml"
  (postwhite__base_packages (list
      "curl"))
  (postwhite__packages (list))
  (postwhite__user "postwhite")
  (postwhite__group "postwhite")
  (postwhite__shell "/usr/sbin/nologin")
  (postwhite__gecos "Postscreen SPF Whitelist")
  (postwhite__home (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\"))
                     + \"/\" + postwhite__user }}"))
  (postwhite__src (jinja "{{ (ansible_local.fhs.src | d(\"/usr/local/src\"))
                    + \"/\" + postwhite__user }}"))
  (postwhite__spftools_git_repo "https://github.com/jsarenik/spf-tools")
  (postwhite__spftools_git_version "master")
  (postwhite__spftools_git_dest (jinja "{{ postwhite__src + \"/\"
                                  + postwhite__spftools_git_repo.split(\"://\")[1] }}"))
  (postwhite__git_repo "https://github.com/stevejenkins/postwhite")
  (postwhite__git_version "master")
  (postwhite__git_dest (jinja "{{ postwhite__src + \"/\"
                         + postwhite__git_repo.split(\"://\")[1] }}"))
  (postwhite__software_stack (list
      
      (git_repo (jinja "{{ postwhite__spftools_git_repo }}"))
      (git_dest (jinja "{{ postwhite__spftools_git_dest }}"))
      (git_version (jinja "{{ postwhite__spftools_git_version }}"))
      
      (git_repo (jinja "{{ postwhite__git_repo }}"))
      (git_dest (jinja "{{ postwhite__git_dest }}"))
      (git_version (jinja "{{ postwhite__git_version }}"))))
  (postwhite__spf_whitelist_path (jinja "{{ postwhite__home + \"/postscreen_spf_whitelist.cidr\" }}"))
  (postwhite__spf_blacklist_path (jinja "{{ postwhite__home + \"/postscreen_spf_blacklist.cidr\" }}"))
  (postwhite__whitelist_hosts (list))
  (postwhite__include_yahoo "True")
  (postwhite__blacklist (jinja "{{ True if postwhite__blacklist_hosts | d() else False }}"))
  (postwhite__blacklist_hosts (list))
  (postwhite__invalid_ipv4 "remove")
  (postwhite__simplify "False")
  (postwhite__reload_postfix "False")
  (postwhite__cron_whitelist_update_frequency "daily")
  (postwhite__cron_yahoo_update_frequency "weekly")
  (postwhite__initial_update_method (jinja "{{ \"batch\"
                                     if (ansible_local | d() and ansible_local.atd | d() and
                                         (ansible_local.atd.enabled | d()) | bool)
                                     else \"async\" }}"))
  (postwhite__postfix__dependent_maincf (list
      
      (name "postscreen_access_list")
      (state "append")
      (value (list
          
          (name "cidr:" (jinja "{{ postwhite__spf_whitelist_path }}"))
          (state "present")
          (weight "100")
          
          (name "cidr:" (jinja "{{ postwhite__spf_blacklist_path }}"))
          (weight "110")
          (state (jinja "{{ \"present\" if postwhite__blacklist | bool else \"ignore\" }}")))))))
