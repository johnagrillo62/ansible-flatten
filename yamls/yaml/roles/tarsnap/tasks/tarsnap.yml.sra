(playbook "yaml/roles/tarsnap/tasks/tarsnap.yml"
  (tasks
    (task "Check if Tarsnap " (jinja "{{ tarsnap_version }}") " is installed"
      (shell "tarsnap --version | grep " (jinja "{{ tarsnap_version }}") " --color=never")
      (register "tarsnap_installed")
      (changed_when "tarsnap_installed.rc != 0")
      (ignore_errors "yes")
      (tags (list
          "dependencies")))
    (task "Install dependencies for Tarsnap"
      (apt "pkg=" (jinja "{{ item }}") " state=present")
      (when "tarsnap_installed is failed")
      (with_items (list
          "e2fslibs-dev"
          "libssl-dev"
          "zlib1g-dev"))
      (tags (list
          "dependencies")))
    (task "Download the current tarsnap code signing key"
      (get_url "url=https://www.tarsnap.com/tarsnap-signing-key.asc dest=/root/tarsnap-signing-key.asc")
      (when "tarsnap_installed is failed"))
    (task "Add the tarsnap code signing key to your list of keys"
      (command "gpg --import tarsnap-signing-key.asc chdir=/root/")
      (when "tarsnap_installed is failed"))
    (task "Download tarsnap SHA file"
      (get_url "url=\"https://www.tarsnap.com/download/tarsnap-sigs-" (jinja "{{ tarsnap_version }}") ".asc\" dest=\"/root/tarsnap-sigs-" (jinja "{{ tarsnap_version }}") ".asc\"")
      (when "tarsnap_installed is failed"))
    (task "Make the command that gets the current SHA"
      (template "src=getSha.sh dest=/root/getSha.sh mode=0755")
      (when "tarsnap_installed is failed"))
    (task "Get the SHA256sum for this tarsnap release"
      (command "./getSha.sh chdir=/root")
      (when "tarsnap_installed is failed")
      (register "tarsnap_sha"))
    (task "Download Tarsnap source"
      (get_url "url=\"https://www.tarsnap.com/download/tarsnap-autoconf-" (jinja "{{ tarsnap_version }}") ".tgz\" dest=\"/root/tarsnap-autoconf-" (jinja "{{ tarsnap_version }}") ".tgz\" sha256sum=" (jinja "{{ tarsnap_sha.stdout_lines[0] }}"))
      (when "tarsnap_installed is failed"))
    (task "Decompress Tarsnap source"
      (unarchive "src=/root/tarsnap-autoconf-" (jinja "{{ tarsnap_version }}") ".tgz dest=/root copy=no creates=/root/tarsnap-autoconf-" (jinja "{{ tarsnap_version }}") "/COPYING")
      (when "tarsnap_installed is failed"))
    (task "Configure Tarsnap for local build"
      (command "./configure chdir=/root/tarsnap-autoconf-" (jinja "{{ tarsnap_version }}") " creates=/root/tarsnap-autoconf-" (jinja "{{ tarsnap_version }}") "/Makefile")
      (when "tarsnap_installed is failed"))
    (task "Build and install Tarsnap"
      (command "make all install clean chdir=/root/tarsnap-autoconf-" (jinja "{{ tarsnap_version }}") " creates=/usr/local/bin/tarsnap")
      (when "tarsnap_installed is failed"))
    (task "Copy Tarsnap key file into place"
      (copy "src=decrypted_tarsnap.key dest=/decrypted/tarsnap.key owner=root group=root mode=\"0600\" force=no"))
    (task "Create Tarsnap cache directory"
      (file "state=directory path=/usr/tarsnap-cache"))
    (task "Install Tarsnap configuration file"
      (copy "src=tarsnaprc dest=/root/.tarsnaprc mode=\"0644\""))
    (task "Install Tarsnap backup handler script"
      (copy "src=tarsnap.sh dest=/root/tarsnap.sh mode=\"0755\""))
    (task "Install nightly Tarsnap-generations cronjob"
      (cron "name=\"Tarsnap backup\" hour=\"3\" minute=\"0\" job=\"sh /root/tarsnap.sh >> /var/log/tarsnap.log\""))))
