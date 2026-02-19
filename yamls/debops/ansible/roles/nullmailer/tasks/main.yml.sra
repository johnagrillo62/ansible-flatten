(playbook "debops/ansible/roles/nullmailer/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (nullmailer__base_packages
                              + nullmailer__smtpd_packages
                              + nullmailer__packages)) }}"))
        (state "present"))
      (register "nullmailer__register_packages")
      (until "nullmailer__register_packages is succeeded")
      (when "nullmailer__deploy_state | d('present') != 'absent'"))
    (task "Purge other SMTP servers"
      (ansible.builtin.apt 
        (name (jinja "{{ nullmailer__purge_mta_packages | flatten }}"))
        (state "absent")
        (purge "True"))
      (when "(nullmailer__deploy_state | d('present') != 'absent' and nullmailer__purge_mta_packages)"))
    (task "Generate configuration files"
      (ansible.builtin.copy 
        (dest (jinja "{{ item.dest }}"))
        (content (jinja "{{ (item.content + '\\n') if item.content | d() else ('' if item.content is defined else omit) }}"))
        (src (jinja "{{ item.src | d(omit) }}"))
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (group (jinja "{{ item.group | d(omit) }}"))
        (mode (jinja "{{ item.mode | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", nullmailer__configuration_files) }}"))
      (notify (list
          "Restart nullmailer"))
      (when "(nullmailer__deploy_state | d('present') != 'absent' and (item.dest | d() and (item.src | d() or item.content is defined) and item.state | d('present') != 'absent'))"))
    (task "Generate private configuration files"
      (ansible.builtin.copy 
        (dest (jinja "{{ item.dest }}"))
        (content (jinja "{{ (item.content + '\\n') if item.content | d() else omit }}"))
        (src (jinja "{{ item.src | d(omit) }}"))
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (group (jinja "{{ item.group | d(omit) }}"))
        (mode (jinja "{{ item.mode | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", nullmailer__private_configuration_files) }}"))
      (notify (list
          "Restart nullmailer"))
      (when "(nullmailer__deploy_state | d('present') != 'absent' and (item.dest | d() and (item.src | d() or item.content | d()) and item.state | d('present') != 'absent'))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Remove configuration files if requested"
      (ansible.builtin.file 
        (path (jinja "{{ item.dest }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", nullmailer__configuration_files) }}"))
      (notify (list
          "Restart nullmailer"))
      (when "(nullmailer__deploy_state | d('present') != 'absent' and (item.dest | d() and (item.src | d() or item.content is defined) and item.state | d('present') == 'absent'))"))
    (task "Remove private configuration files if requested"
      (ansible.builtin.file 
        (path (jinja "{{ item.dest }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", nullmailer__private_configuration_files) }}"))
      (notify (list
          "Restart nullmailer"))
      (when "(nullmailer__deploy_state | d('present') != 'absent' and (item.dest | d() and (item.src | d() or item.content is defined) and item.state | d('present') == 'absent'))")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Configure nullmailer services in xinetd"
      (ansible.builtin.template 
        (src "etc/xinetd.d/" (jinja "{{ item }}") ".j2")
        (dest "/etc/xinetd.d/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (list
          "nullmailer-smtpd"
          "nullmailer-smtpd6"))
      (notify (list
          "Reload xinetd"))
      (when "(nullmailer__deploy_state | d('present') != 'absent' and nullmailer__smtpd | bool)"))
    (task "Disable nullmailer-smtpd service in xinetd"
      (ansible.builtin.file 
        (path "/etc/xinetd.d/" (jinja "{{ item }}"))
        (state "absent"))
      (loop (list
          "nullmailer-smtpd"
          "nullmailer-smtpd6"))
      (notify (list
          "Reload xinetd"))
      (when "((nullmailer__deploy_state | d() and nullmailer__deploy_state == 'absent') or not nullmailer__smtpd | bool)"))
    (task "Remove old dpkg cleanup hook and script"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "absent"))
      (loop (list
          "/etc/dpkg/dpkg.cfg.d/debops-nullmailer"
          "/usr/local/lib/debops-nullmailer-dpkg-cleanup"))
      (when "nullmailer__deploy_state | d('present') != 'absent'"))
    (task "Prepare cleanup during package removal"
      (ansible.builtin.import_role 
        (name "dpkg_cleanup"))
      (vars 
        (dpkg_cleanup__dependent_packages (list
            (jinja "{{ nullmailer__dpkg_cleanup__dependent_packages }}"))))
      (when "nullmailer__deploy_state | d('present') != 'absent'")
      (tags (list
          "role::dpkg_cleanup"
          "skip::dpkg_cleanup"
          "role::nullmailer:dpkg_cleanup")))))
