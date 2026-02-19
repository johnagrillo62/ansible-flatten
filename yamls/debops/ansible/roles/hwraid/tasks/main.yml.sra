(playbook "debops/ansible/roles/hwraid/tasks/main.yml"
  (tasks
    (task "Select supported release for current distribution"
      (ansible.builtin.set_fact 
        (hwraid_register_release (jinja "{{ hwraid_release }}")))
      (when "hwraid_release in hwraid_distribution_releases[hwraid_distribution]"))
    (task "Select latest release for current distribution if no match found"
      (ansible.builtin.set_fact 
        (hwraid_register_release (jinja "{{ hwraid_distribution_releases[hwraid_distribution][0] }}")))
      (when "hwraid_register_release is undefined"))
    (task "Configure HWRaid APT repository"
      (ansible.builtin.apt_repository 
        (repo "deb http://hwraid.le-vert.net/" (jinja "{{ hwraid_distribution | lower }}") " " (jinja "{{ hwraid_register_release | lower }}") " main")
        (state "present")
        (update_cache "True"))
      (when "hwraid_register_release is defined and hwraid_register_release"))
    (task "Get list of active kernel modules"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && lsmod | awk '{print $1}'")
      (args 
        (executable "bash"))
      (register "hwraid_register_modules")
      (changed_when "False"))
    (task "Install packages for recognized RAID devices"
      (ansible.builtin.apt 
        (name (jinja "{{ item.1 }}"))
        (state "present")
        (install_recommends "False"))
      (with_subelements (list
          (jinja "{{ hwraid_device_database }}")
          "packages"))
      (register "hwraid__register_packages")
      (until "hwraid__register_packages is succeeded")
      (when "((hwraid_register_release is defined and hwraid_register_release) and item.0.module not in hwraid_blacklist and item.0.module in hwraid_register_modules.stdout_lines)"))
    (task "Make sure service starts at boot"
      (ansible.builtin.service 
        (name (jinja "{{ item.1 }}"))
        (state "started")
        (enabled "yes"))
      (with_subelements (list
          (jinja "{{ hwraid_device_database }}")
          "daemons"))
      (when "((hwraid_register_release is defined and hwraid_register_release) and item.0.module not in hwraid_blacklist and item.0.module in hwraid_register_modules.stdout_lines)"))))
