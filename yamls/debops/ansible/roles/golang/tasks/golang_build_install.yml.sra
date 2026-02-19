(playbook "debops/ansible/roles/golang/tasks/golang_build_install.yml"
  (tasks
    (task "Check package availability for " (jinja "{{ build.name }}")
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && apt-cache madison \\ " (jinja "{{ ([build.apt_packages] if build.apt_packages is string else build.apt_packages) | join(' ') }}") " \\ | awk '{print $1}' | sort | uniq")
      (args 
        (executable "/bin/bash"))
      (register "golang__register_build_apt_packages")
      (when "build.apt_packages | d()")
      (changed_when "False")
      (check_mode "False"))
    (task "Install packages for " (jinja "{{ build.name }}")
      (ansible.builtin.package 
        (name (jinja "{{ build.apt_packages }}"))
        (state "present"))
      (register "golang__register_install_apt_packages")
      (until "golang__register_install_apt_packages is succeeded")
      (when "(not (build.upstream | d()) | bool and (build.apt_packages is defined and (([build.apt_packages] if (build.apt_packages is string) else build.apt_packages) | intersect(golang__register_build_apt_packages.stdout_lines))))"))
    (task "Prepare Go UNIX environment"
      (block (list
          
          (name "Ensure that the UNIX group for Go environment exists")
          (ansible.builtin.group 
            (name (jinja "{{ golang__group }}"))
            (state "present")
            (system "True"))
          
          (name "Ensure that the UNIX account for Go environment exists")
          (ansible.builtin.user 
            (name (jinja "{{ golang__user }}"))
            (group (jinja "{{ golang__group }}"))
            (home (jinja "{{ golang__home }}"))
            (comment (jinja "{{ golang__comment }}"))
            (shell (jinja "{{ golang__shell }}"))
            (state "present")
            (system "True"))))
      (when "((build.git | d() or build.url | d()) and ((build.upstream | d()) | bool or (build.apt_packages is undefined or (not (([build.apt_packages] if (build.apt_packages is string) else build.apt_packages) | intersect(golang__register_build_apt_packages.stdout_lines))))))"))
    (task "Install required packages for " (jinja "{{ build.name }}")
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (build.apt_required_packages | d([]))) }}"))
        (state "present"))
      (register "golang__register_install_apt_required_packages")
      (until "golang__register_install_apt_required_packages is succeeded")
      (when "(build.url | d() and build.upstream_type | d('git') == 'url' and (((build.upstream | d()) | bool or (build.apt_packages is undefined or (not (([build.apt_packages] if (build.apt_packages is string) else build.apt_packages) | intersect(golang__register_build_apt_packages.stdout_lines)))))))"))
    (task "Download Go binaries directly"
      (block (list
          
          (name "Create the required directories for " (jinja "{{ build.name }}"))
          (ansible.builtin.file 
            (dest (jinja "{{ (golang__gosrc + \"/\" + url_item.dest) | dirname }}"))
            (state "directory")
            (mode "0755"))
          (loop (jinja "{{ build.url }}"))
          (loop_control 
            (loop_var "url_item"))
          
          (name "Download files for " (jinja "{{ build.name }}"))
          (ansible.builtin.get_url 
            (url (jinja "{{ url_item.src }}"))
            (dest (jinja "{{ golang__gosrc + \"/\" + url_item.dest }}"))
            (checksum (jinja "{{ url_item.checksum | d(omit) }}"))
            (mode "0644"))
          (loop (jinja "{{ build.url }}"))
          (loop_control 
            (loop_var "url_item"))
          (register "golang__register_get_url")
          (until "golang__register_get_url is succeeded")
          
          (name "Extract archive for " (jinja "{{ build.name }}"))
          (ansible.builtin.unarchive 
            (src (jinja "{{ golang__gosrc + \"/\" + url_item.dest }}"))
            (dest (jinja "{{ golang__gosrc + \"/\" + (url_item.unarchive_dest | d(url_item.dest | dirname)) }}"))
            (remote_src "True")
            (creates (jinja "{{ golang__gosrc + \"/\" + url_item.unarchive_creates }}"))
            (mode "u=rwX,g=rwX,o=rX"))
          (loop (jinja "{{ build.url }}"))
          (loop_control 
            (loop_var "url_item"))
          (when "(url_item.unarchive | d()) | bool")
          
          (name "Verify files for " (jinja "{{ build.name }}"))
          (ansible.builtin.command "gpg --verify " (jinja "{{ golang__gosrc + \"/\" + url_item.dest }}"))
          (args 
            (chdir (jinja "{{ (golang__gosrc + \"/\" + url_item.dest) | dirname }}")))
          (loop (jinja "{{ build.url }}"))
          (loop_control 
            (loop_var "url_item"))
          (register "golang__register_verify")
          (changed_when "False")
          (failed_when "golang__register_verify.rc != 0")
          (when "(url_item.gpg_verify | d()) | bool")))
      (when "(build.url | d() and build.upstream_type | d('git') == 'url' and ((build.upstream | d()) | bool or (build.apt_packages is undefined or (not (([build.apt_packages] if (build.apt_packages is string) else build.apt_packages) | intersect(golang__register_build_apt_packages.stdout_lines))))))")
      (become "True")
      (become_user (jinja "{{ golang__user }}")))
    (task "Install binaries for " (jinja "{{ build.name }}")
      (ansible.builtin.copy 
        (src (jinja "{{ (\"\"
              if ((binary_item.src | d(binary_item)).startswith(\"/\"))
              else (golang__gosrc + \"/\"))
             + (binary_item.src | d(binary_item)) }}"))
        (dest (jinja "{{ ((binary_item.dest | dirname)
               if (binary_item.dest | d() and \"/\" in binary_item.dest)
               else \"/usr/local/bin\") + \"/\"
              + ((binary_item.dest | d(binary_item.src | d(binary_item))) | basename) }}"))
        (remote_src "True")
        (mode (jinja "{{ binary_item.mode | d(\"0755\") }}")))
      (register "golang__register_download_install")
      (notify (jinja "{{ binary_item.notify if binary_item.notify | d() else omit }}"))
      (loop (jinja "{{ build.url_binaries | d([]) }}"))
      (loop_control 
        (loop_var "binary_item"))
      (when "(build.url_binaries | d() and build.upstream_type | d('git') == 'url' and ((build.upstream | d()) | bool or (build.apt_packages is undefined or (not (([build.apt_packages] if (build.apt_packages is string) else build.apt_packages) | intersect(golang__register_build_apt_packages.stdout_lines))))))"))
    (task "Install dev packages for " (jinja "{{ build.name }}")
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (golang__apt_dev_packages + (build.apt_dev_packages | d([])))) }}"))
        (state "present"))
      (register "golang__register_install_apt_dev_packages")
      (until "golang__register_install_apt_dev_packages is succeeded")
      (when "(build.git | d() and build.upstream_type | d('git') == 'git' and (((build.upstream | d()) | bool or (build.apt_packages is undefined or (not (([build.apt_packages] if (build.apt_packages is string) else build.apt_packages) | intersect(golang__register_build_apt_packages.stdout_lines)))))))"))
    (task "Build Go applications from source"
      (block (list
          
          (name "Clone repo for " (jinja "{{ build.name }}"))
          (ansible.builtin.git 
            (repo (jinja "{{ git_item.repo }}"))
            (dest (jinja "{{ golang__gosrc + \"/\" + (git_item.dest | d(git_item.repo.split(\"://\")[1])) }}"))
            (version (jinja "{{ git_item.version | d(git_item.branch | d(omit)) }}"))
            (depth (jinja "{{ git_item.depth | d(golang__git_depth | d(omit)) }}"))
            (verify_commit (jinja "{{ True if build.gpg | d() else omit }}")))
          (loop (jinja "{{ build.git }}"))
          (loop_control 
            (loop_var "git_item"))
          (register "golang__register_build_source")
          
          (name "Build binaries for " (jinja "{{ build.name }}"))
          (environment 
            (GOPATH (jinja "{{ golang__env_gopath }}"))
            (GOCACHE (jinja "{{ golang__env_gocache }}"))
            (PATH (jinja "{{ golang__env_path }}")))
          (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && " (jinja "{{ git_item.build_script }}"))
          (args 
            (executable "/bin/bash")
            (chdir (jinja "{{ golang__gosrc + \"/\" + (git_item.dest | d(git_item.repo.split(\"://\")[1])) }}")))
          (loop (jinja "{{ build.git }}"))
          (loop_control 
            (loop_var "git_item"))
          (when "git_item.build_script | d() and golang__register_build_source is changed")
          (register "golang__register_build")
          (changed_when "golang__register_build.changed | bool")))
      (when "(build.git | d() and build.upstream_type | d('git') == 'git' and (((build.upstream | d()) | bool or (build.apt_packages is undefined or (not (([build.apt_packages] if (build.apt_packages is string) else build.apt_packages) | intersect(golang__register_build_apt_packages.stdout_lines)))))))")
      (become "True")
      (become_user (jinja "{{ golang__user }}")))
    (task "Install binaries for " (jinja "{{ build.name }}")
      (ansible.builtin.copy 
        (src (jinja "{{ (\"\"
              if ((binary_item.src | d(binary_item)).startswith(\"/\"))
              else (golang__gosrc + \"/\"))
             + (binary_item.src | d(binary_item)) }}"))
        (dest (jinja "{{ ((binary_item.dest | dirname)
               if (binary_item.dest | d() and \"/\" in binary_item.dest)
               else \"/usr/local/bin\") + \"/\"
              + ((binary_item.dest | d(binary_item.src | d(binary_item))) | basename) }}"))
        (remote_src "True")
        (mode (jinja "{{ binary_item.mode | d(\"0755\") }}")))
      (register "golang__register_build_install")
      (notify (jinja "{{ binary_item.notify if binary_item.notify | d() else omit }}"))
      (loop (jinja "{{ build.git_binaries | d([]) }}"))
      (loop_control 
        (loop_var "binary_item"))
      (when "(build.git_binaries | d() and build.upstream_type | d('git') == 'git' and ((build.upstream | d()) | bool or (build.apt_packages is undefined or (not (([build.apt_packages] if (build.apt_packages is string) else build.apt_packages) | intersect(golang__register_build_apt_packages.stdout_lines))))))"))
    (task "Create the initial Go binaries database file"
      (ansible.builtin.copy 
        (content "# This is a database of the applications installed by the 'debops.golang'
# Ansible role and used by the '/etc/ansible/facts.d/golang.fact' script
# to provide paths to the correct binaries.
")
        (dest (jinja "{{ golang__bin_database }}"))
        (mode "0644")
        (force "False"))
      (when "build.url_binaries | d() or build.git_binaries | d()"))
    (task "Register binaries for " (jinja "{{ build.name }}")
      (ansible.builtin.lineinfile 
        (path (jinja "{{ golang__bin_database }}"))
        (regexp (jinja "{{ '^' + (((binary_item.dest | d(binary_item.src | d(binary_item))) | basename)
                       | regex_replace('-', '\\\\-')
                       | regex_replace('\\\\.', '\\\\\\\\.')) + '$' }}"))
        (line (jinja "{{ (binary_item.dest | d(binary_item.src | d(binary_item))) | basename }}"))
        (state "present")
        (mode "0644"))
      (loop (jinja "{{ build.url_binaries | d([]) + build.git_binaries | d([]) }}"))
      (loop_control 
        (loop_var "binary_item"))
      (register "golang__register_build_database")
      (when "build.url_binaries | d() or build.git_binaries | d()"))
    (task "Update Ansible local facts if they were modified"
      (ansible.builtin.setup null)
      (when "(ansible_local | d() and ansible_local.golang | d() and (ansible_local.golang.configured | d()) | bool and (golang__register_build_database is changed or golang__register_download_install is changed or golang__register_build_install is changed))"))))
