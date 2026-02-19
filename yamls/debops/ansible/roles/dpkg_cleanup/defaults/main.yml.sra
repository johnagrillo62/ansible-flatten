(playbook "debops/ansible/roles/dpkg_cleanup/defaults/main.yml"
  (dpkg_cleanup__enabled (jinja "{{ True if (ansible_pkg_mgr == \"apt\") else False }}"))
  (dpkg_cleanup__facts_path "/etc/ansible/facts.d")
  (dpkg_cleanup__scripts_path "/usr/local/lib/dpkg-cleanup")
  (dpkg_cleanup__hooks_path "/etc/dpkg/dpkg.cfg.d")
  (dpkg_cleanup__dependent_packages (list)))
