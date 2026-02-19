(playbook "debops/ansible/roles/proc_hidepid/defaults/main.yml"
  (proc_hidepid__enabled "True")
  (proc_hidepid__base_packages (list
      "libcap2-bin"))
  (proc_hidepid__packages (list))
  (proc_hidepid__skip_packages (list
      "policykit-1"
      "polkitd"))
  (proc_hidepid__remount (jinja "{{ True
                           if ((((ansible_system_capabilities_enforced | d()) | bool and
                                 \"cap_sys_admin\" in ansible_system_capabilities) or
                                not (ansible_system_capabilities_enforced | d(True)) | bool) and
                               (ansible_local | d() and ansible_local.proc_hidepid | d() and
                                (ansible_local.proc_hidepid.proc_owner | d(\"root\")) == \"root\"))
                           else False }}"))
  (proc_hidepid__level (jinja "{{ \"0\"
                          if ((\"debops_service_libvirtd\" in group_names) or
                              (ansible_local.libvirtd.installed | d() | bool))
                          else (proc_hidepid__fact_default_level | d(\"2\")) }}"))
  (proc_hidepid__group "procadmins")
  (proc_hidepid__gid "70")
  (proc_hidepid__secure_scheduler_enabled (jinja "{{ True
                                            if (proc_hidepid__register_sched.stat.exists | bool and
                                                proc_hidepid__register_sched.stat.uid == 0)
                                            else False }}"))
  (proc_hidepid__secure_scheduler_group (jinja "{{ proc_hidepid__group }}")))
