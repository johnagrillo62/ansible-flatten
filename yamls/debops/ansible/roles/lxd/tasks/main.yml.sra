(playbook "debops/ansible/roles/lxd/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Check if custom libraries exist"
      (ansible.builtin.stat 
        (path (jinja "{{ lxd__golang_gosrc + \"/../deps/raft/.libs\" }}")))
      (register "lxd__register_libraries"))
    (task "Copy custom dependent libraries to system directory"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit &&
mkdir -p /usr/local/lib/x86_64-linux-gnu &&
cp -Pf ../deps/raft/.libs/libraft.so* \\
       ../deps/dqlite/.libs/libdqlite.so* \\
       /usr/local/lib/x86_64-linux-gnu &&
ldconfig
")
      (args 
        (chdir (jinja "{{ lxd__golang_gosrc }}"))
        (creates "/usr/local/lib/x86_64-linux-gnu/libraft.so.0")
        (executable "bash"))
      (when "lxd__upstream_enabled | bool and lxd__upstream_type == 'git' and lxd__register_libraries.stat.exists | bool"))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ (lxd__base_packages + lxd__packages) | flatten }}"))
        (state "present")))
    (task "Create required POSIX system group"
      (ansible.builtin.group 
        (name (jinja "{{ lxd__group }}"))
        (state "present")
        (system "True")))
    (task "Add selected UNIX accounts to LXD system group"
      (ansible.builtin.user 
        (name (jinja "{{ item }}"))
        (groups (jinja "{{ lxd__group }}"))
        (append "True"))
      (loop (jinja "{{ lxd__admin_accounts }}")))
    (task "Create the log directory"
      (ansible.builtin.file 
        (state "directory")
        (path "/var/log/lxd")
        (mode "0700")))
    (task "Check if lxc-apparmor-load binary exists"
      (ansible.builtin.stat 
        (path "/usr/lib/x86_64-linux-gnu/lxc/lxc-apparmor-load"))
      (register "lxd__register_apparmor_load"))
    (task "Create lxc-apparmor-load symlink if needed"
      (ansible.builtin.file 
        (path "/usr/lib/x86_64-linux-gnu/lxc/lxc-apparmor-load")
        (src "/usr/libexec/lxc/lxc-apparmor-load")
        (state "link"))
      (when "not lxd__register_apparmor_load.stat.exists | bool and ansible_distribution_release in [ 'bookworm' ]"))
    (task "Generate systemd units"
      (ansible.builtin.template 
        (src "etc/systemd/system/" (jinja "{{ item }}") ".j2")
        (dest "/etc/systemd/system/" (jinja "{{ item }}"))
        (mode "0644"))
      (loop (list
          "lxd.socket"
          "lxd.service"
          "lxd-containers.service"
          "lxd-net.service"))
      (register "lxd__register_systemd")
      (when "lxd__upstream_enabled | bool and ansible_service_mgr == 'systemd'"))
    (task "Enable systemd units"
      (ansible.builtin.systemd 
        (daemon_reload "True")
        (name (jinja "{{ item }}"))
        (state "started")
        (enabled "True"))
      (loop (list
          "lxd.socket"
          "lxd-containers.service"
          "lxd-net.service"))
      (when "lxd__register_systemd is changed"))
    (task "Apply preseed configuration"
      (ansible.builtin.command "lxd init --preseed")
      (args 
        (stdin (jinja "{{ lxd__preseed_data }}")))
      (changed_when "False")
      (when "lxd__init_preseed | bool")
      (tags (list
          "role::lxd:init")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save LXD local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/lxd.fact.j2")
        (dest "/etc/ansible/facts.d/lxd.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
