(playbook "debops/ansible/roles/gitlab_runner/defaults/main.yml"
  (gitlab_runner__apt_upstream "True")
  (gitlab_runner__apt_key "F6403F6544A38863DAA0B6E03F01618A51312F3F")
  (gitlab_runner__apt_repo "deb https://packages.gitlab.com/runner/gitlab-runner/" (jinja "{{ ansible_distribution | lower }}") "/ " (jinja "{{ ansible_distribution_release }}") " main")
  (gitlab_runner__base_packages (list
      "gitlab-runner"
      (jinja "{{ [\"vagrant-libvirt\", \"libguestfs-tools\", \"busybox\", \"patch\"]
        if gitlab_runner__vagrant_libvirt | bool
        else [] }}")
      (jinja "{{ \"vagrant-lxc\" if gitlab_runner__vagrant_lxc | bool else [] }}")))
  (gitlab_runner__packages (list))
  (gitlab_runner__user "gitlab-runner")
  (gitlab_runner__group "gitlab-runner")
  (gitlab_runner__additional_groups (list))
  (gitlab_runner__system "True")
  (gitlab_runner__home (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\"))
	                 + \"/\" + gitlab_runner__user }}"))
  (gitlab_runner__comment "GitLab Runner")
  (gitlab_runner__shell "/bin/bash")
  (gitlab_runner__concurrent (jinja "{{ ansible_processor_vcpus
                               if (ansible_local | d() and
                                   ansible_local.docker_server | d() and
                                   (ansible_local.docker_server.installed | d()) | bool)
                               else \"1\" }}"))
  (gitlab_runner__domain (jinja "{{ ansible_domain }}"))
  (gitlab_runner__fqdn (jinja "{{ ansible_fqdn }}"))
  (gitlab_runner__gitlab_srv_rr (jinja "{{ q(\"debops.debops.dig_srv\", \"_gitlab._tcp.\" + gitlab_runner__domain,
                                    ansible_fqdn
                                    if (ansible_local | d() and ansible_local.gitlab | d() and
                                       (ansible_local.gitlab.installed | d()) | bool)
                                    else (\"code.\" + gitlab_runner__domain), 443) }}"))
  (gitlab_runner__api_fqdn (jinja "{{ gitlab_runner__gitlab_srv_rr[0][\"target\"] }}"))
  (gitlab_runner__api_url "https://" (jinja "{{ gitlab_runner__api_fqdn }}") "/")
  (gitlab_runner__api_token (jinja "{{ lookup(\"env\", \"GITLAB_API_TOKEN\") }}"))
  (gitlab_runner__runner_type "instance_type")
  (gitlab_runner__group_id null)
  (gitlab_runner__project_id null)
  (gitlab_runner__executor "shell")
  (gitlab_runner__metrics_server "")
  (gitlab_runner__environment )
  (gitlab_runner__shell_tags (jinja "{{ lookup(\"template\",
                               \"lookup/gitlab_runner__shell_tags.j2\") }}"))
  (gitlab_runner__default_tags (list
      "managed-by-debops"))
  (gitlab_runner__tags (list))
  (gitlab_runner__group_tags (list))
  (gitlab_runner__host_tags (list))
  (gitlab_runner__combined_tags (jinja "{{ gitlab_runner__default_tags
                                  + gitlab_runner__tags
                                  + gitlab_runner__group_tags
                                  + gitlab_runner__host_tags }}"))
  (gitlab_runner__default_instances (list
      
      (name (jinja "{{ ansible_hostname + \"-shell\" }}"))
      (executor "shell")
      (run_untagged "False")
      (state (jinja "{{ \"absent\"
               if (ansible_local | d() and ansible_local.docker_server | d() and
                   (ansible_local.docker_server.installed | d()) | bool)
               else \"present\" }}"))
      
      (name (jinja "{{ ansible_hostname + \"-docker\" }}"))
      (executor "docker")
      (tags (list
          "docker"))
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.docker_server | d() and
                   (ansible_local.docker_server.installed | d()) | bool)
               else \"absent\" }}"))
      
      (name (jinja "{{ ansible_hostname + \"-docker-root\" }}"))
      (executor "docker")
      (concurrent (jinja "{{ ansible_processor_vcpus }}"))
      (docker_privileged "True")
      (run_untagged "False")
      (tags (list
          "docker-privileged"))
      (state (jinja "{{ \"present\"
               if (ansible_local | d() and ansible_local.docker_server | d() and
                   (ansible_local.docker_server.installed | d()) | bool)
               else \"absent\" }}"))))
  (gitlab_runner__instances (list))
  (gitlab_runner__group_instances (list))
  (gitlab_runner__host_instances (list))
  (gitlab_runner__custom_files (list))
  (gitlab_runner__group_custom_files (list))
  (gitlab_runner__host_custom_files (list))
  (gitlab_runner__vagrant_libvirt (jinja "{{ True
                                    if (ansible_local | d() and ansible_local.libvirtd | d() and
                                        (ansible_local.libvirtd.installed | d()) | bool and
                                        (ansible_distribution_release not in
                                         [\"trusty\"]))
                                    else False }}"))
  (gitlab_runner__vagrant_libvirt_patch (jinja "{{ True
                                          if (gitlab_runner__vagrant_libvirt | bool and
                                              ansible_distribution_release in
                                              [\"stretch\", \"buster\"])
                                          else False }}"))
  (gitlab_runner__vagrant_libvirt_patch_state "present")
  (gitlab_runner__vagrant_lxc (jinja "{{ True
                                if (ansible_local | d() and ansible_local.lxc | d() and
                                    (ansible_local.lxc.installed | d()) | bool and
                                    (ansible_distribution_release not in
                                     [\"trusty\"]))
                                else False }}"))
  (gitlab_runner__ssh_generate "False")
  (gitlab_runner__ssh_generate_bits "4096")
  (gitlab_runner__ssh_install_to (list))
  (gitlab_runner__ssh_known_hosts (list
      (jinja "{{ gitlab_runner__fqdn }}")))
  (gitlab_runner__ssh_host "")
  (gitlab_runner__ssh_port "22")
  (gitlab_runner__ssh_user "")
  (gitlab_runner__ssh_identity_file "")
  (gitlab_runner__ssh_password "")
  (gitlab_runner__docker_host "")
  (gitlab_runner__docker_tls_cert_path "")
  (gitlab_runner__docker_image "debian")
  (gitlab_runner__docker_privileged "False")
  (gitlab_runner__docker_disable_cache "False")
  (gitlab_runner__docker_cache_dir "")
  (gitlab_runner__docker_cap_add (list))
  (gitlab_runner__docker_cap_drop (list
      "NET_ADMIN"
      "SYS_ADMIN"
      "DAC_OVERRIDE"))
  (gitlab_runner__docker_devices (list))
  (gitlab_runner__docker_extra_hosts (list))
  (gitlab_runner__docker_links (list))
  (gitlab_runner__docker_services (list))
  (gitlab_runner__docker_volumes (list))
  (gitlab_runner__docker_allowed_images (list))
  (gitlab_runner__docker_allowed_services (list))
  (gitlab_runner__machine_idle_count (jinja "{{ ansible_processor_cores }}"))
  (gitlab_runner__machine_idle_time "600")
  (gitlab_runner__machine_max_builds "100")
  (gitlab_runner__machine_name "auto-scale-%s." (jinja "{{ gitlab_runner__domain }}"))
  (gitlab_runner__machine_driver "generic")
  (gitlab_runner__machine_offpeakperiods (list
      "* * 0-7,19-23 * * mon-fri *"
      "* * * * * sat,sun *"))
  (gitlab_runner__machine_offpeakidlecount "0")
  (gitlab_runner__machine_offpeakidletime "1200")
  (gitlab_runner__machine_options (list))
  (gitlab_runner__cache "False")
  (gitlab_runner__cache_type "s3")
  (gitlab_runner__cache_server_address "")
  (gitlab_runner__cache_access_key "")
  (gitlab_runner__cache_secret_key "")
  (gitlab_runner__cache_bucket_name "")
  (gitlab_runner__cache_bucket_location "")
  (gitlab_runner__cache_insecure "False")
  (gitlab_runner__cache_shared "False")
  (gitlab_runner__run_untagged "True")
  (gitlab_runner__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ gitlab_runner__apt_key }}"))
      (repo (jinja "{{ gitlab_runner__apt_repo }}"))
      (state (jinja "{{ \"present\" if gitlab_runner__apt_upstream | bool else \"absent\" }}")))))
