(playbook "debops/ansible/roles/python/tasks/main_raw.yml"
  (tasks
    (task "Inject host entries into /etc/hosts"
      (ansible.builtin.raw "if ! grep \"" (jinja "{{ python__raw_etc_hosts.split() | first }}") "\" /etc/hosts ; then
  printf \"%s\\n\" \"" (jinja "{{ python__raw_etc_hosts | regex_replace('\\n$', '') }}") "\" >> /etc/hosts
fi
")
      (register "python__register_etc_hosts")
      (changed_when "python__register_etc_hosts.stdout == ''")
      (when "python__enabled | bool and python__raw_etc_hosts | d()"))
    (task "Detect the OS release manually, no Ansible facts available"
      (ansible.builtin.raw "grep -E '^VERSION=' /etc/os-release | tr -d '(\")' | cut -d\" \" -f2")
      (register "python__register_raw_release")
      (changed_when "False")
      (check_mode "False")
      (tags (list
          "meta::facts")))
    (task "Update APT repositories, install core Python packages"
      (ansible.builtin.raw "if [ -z \"$(find /var/cache/apt/pkgcache.bin -mmin " (jinja "{{ python__raw_apt_cache_valid_time }}") ")\" ]; then
    apt-get -q update
fi
if [ \"" (jinja "{{ python__raw_purge_v2 | bool | lower }}") "\" = \"true\" ] && [ ! -f \"/etc/ansible/facts.d/python.fact\" ] ; then
    LANG=C apt-get --purge -yq remove " (jinja "{{ python__raw_purge_packages2 | join(\" \") }}") "
fi
LANG=C apt-get --no-install-recommends -yq install " (jinja "{{ python__core_packages | join(\" \") }}") "
")
      (register "python__register_raw")
      (when "python__enabled | bool")
      (changed_when "(not python__register_raw.stdout | regex_search('0 upgraded, 0 newly installed, 0 to remove and \\d+ not upgraded\\.') or python__register_raw.stdout | regex_search('.+ set to manually installed\\.'))")
      (tags (list
          "meta::facts")))
    (task "Reset connection to the host"
      (ansible.builtin.meta "reset_connection")
      (tags (list
          "meta::facts")))))
