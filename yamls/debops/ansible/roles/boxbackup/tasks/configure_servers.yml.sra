(playbook "debops/ansible/roles/boxbackup/tasks/configure_servers.yml"
  (tasks
    (task "Install Box Backup server packages"
      (ansible.builtin.package 
        (name "boxbackup-server")
        (state "present"))
      (register "boxbackup__register_server_packages")
      (until "boxbackup__register_server_packages is succeeded"))
    (task "Make sure that boxbackup server directories exists"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner "bbstored")
        (group "bbstored")
        (mode "0700"))
      (with_items (list
          "/etc/boxbackup"
          "/etc/boxbackup/bbstored"
          (jinja "{{ boxbackup_storage }}")
          (jinja "{{ boxbackup_storage }}") "/backup")))
    (task "Check block size of storage device"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && dumpe2fs -h $(df " (jinja "{{ boxbackup_storage }}") " | tail -n 1 | awk '{ print $1 }') | grep 'Block size' | awk '{ print $3 }'")
      (args 
        (executable "bash"))
      (register "boxbackup_storage_blocksize")
      (changed_when "False"))
    (task "Make sure accounts.txt file exists"
      (ansible.builtin.copy 
        (force "false")
        (dest "/etc/boxbackup/bbstored/accounts.txt")
        (content "")
        (owner "bbstored")
        (group "bbstored")
        (mode "0600")))
    (task "Configure boxbackup server"
      (ansible.builtin.template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/" (jinja "{{ item }}"))
        (owner "bbstored")
        (group "bbstored")
        (mode "0640"))
      (with_items (list
          "etc/boxbackup/raidfile.conf"
          "etc/boxbackup/bbstored.conf"))
      (notify (list
          "Restart boxbackup-server")))))
