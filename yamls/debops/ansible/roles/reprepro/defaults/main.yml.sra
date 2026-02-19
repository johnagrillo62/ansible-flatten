(playbook "debops/ansible/roles/reprepro/defaults/main.yml"
  (reprepro__base_packages (list
      "reprepro"
      "dpkg-dev"))
  (reprepro__packages (list))
  (reprepro__user "reprepro")
  (reprepro__group "reprepro")
  (reprepro__additional_groups (list
      (jinja "{{ ansible_local.system_groups.local_prefix + \"sshusers\" }}")))
  (reprepro__home (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\"))
                    + \"/\" + reprepro__user }}"))
  (reprepro__comment "Local APT repositories")
  (reprepro__data_root (jinja "{{ reprepro__home + \"/repositories\" }}"))
  (reprepro__public_root (jinja "{{ (ansible_local.fhs.www | d(\"/srv/www\"))
                           + \"/reprepro\" }}"))
  (reprepro__spool_root (jinja "{{ (ansible_local.fhs.spool | d(\"/var/spool\"))
                          + \"/reprepro\" }}"))
  (reprepro__admin_sshkeys (list
      (jinja "{{ lookup(\"pipe\", \"ssh-add -L | grep ^\\\\\\(sk-\\\\\\)\\\\\\?ssh || cat ~/.ssh/*.pub || cat ~/.ssh/authorized_keys || true\") }}")))
  (reprepro__fqdn (jinja "{{ ansible_fqdn }}"))
  (reprepro__domain (jinja "{{ ansible_domain }}"))
  (reprepro__origin (jinja "{{ ansible_local.machine.organization
                      | d(reprepro__domain.split(\".\")[0] | capitalize) }}"))
  (reprepro__mail_from (jinja "{{ reprepro__user + \"@\" + reprepro__fqdn }}"))
  (reprepro__mail_to (jinja "{{ \"root@\" + reprepro__domain }}"))
  (reprepro__max_body_size "50M")
  (reprepro__auth_realm "Access to this APT repository is restricted")
  (reprepro__gpg_snapshot_name "gnupg.tar")
  (reprepro__gpg_snapshot_path (jinja "{{ secret + \"/reprepro/snapshots/\" + inventory_hostname }}"))
  (reprepro__gpg_key_type "RSA")
  (reprepro__gpg_key_length "4096")
  (reprepro__gpg_name (jinja "{{ reprepro__origin + \" Automatic Signing Key\" }}"))
  (reprepro__gpg_email (jinja "{{ \"apt-packages@\" + reprepro__domain }}"))
  (reprepro__gpg_expire_days (jinja "{{ (365 * 10) }}"))
  (reprepro__gpg_public_filename (jinja "{{ reprepro__domain + \".asc\" }}"))
  (reprepro__gpg_uploaders_keys (list))
  (reprepro__default_instances (list
      
      (name "main")
      (fqdn (jinja "{{ reprepro__fqdn }}"))
      (incoming (list
          
          (name "incoming")
          (Allow (list
              "forky"
              "testing>forky"
              "trixie"
              "stable>trixie"
              "bookworm"
              "oldstable>bookworm"
              "bullseye"
              "oldoldstable>bullseye"))
          (Options (list
              "multiple_distributions"))
          (Cleanup (list
              "on_deny"
              "on_error"))))
      (distributions (list
          
          (name "forky")
          (Description "Packages for Debian GNU/Linux 14 (Forky)")
          (Origin (jinja "{{ reprepro__origin }}"))
          (Codename "forky")
          (Suite "testing")
          (Architectures (list
              "source"
              "amd64"
              "arm64"
              "armhf"
              "ppc64el"
              "riscv64"
              "s390x"))
          (Components (list
              "main"
              "contrib"
              "non-free"
              "non-free-firmware"))
          (Uploaders "uploaders/anybody")
          (SignWith "default")
          (DebIndices (list
              "Packages"
              "Release"
              "."
              ".gz"
              ".xz"))
          (DscIndices (list
              "Sources"
              "Release"
              ".gz"
              ".xz"))
          (Log "packages.forky.log
--type=dsc email-changes.sh
")
          (state "present")
          
          (name "trixie")
          (Description "Packages for Debian GNU/Linux 13 (Trixie)")
          (Origin (jinja "{{ reprepro__origin }}"))
          (Codename "trixie")
          (Suite "stable")
          (Architectures (list
              "source"
              "amd64"
              "arm64"
              "armel"
              "armhf"
              "ppc64el"
              "riscv64"
              "s390x"))
          (Components (list
              "main"
              "contrib"
              "non-free"
              "non-free-firmware"))
          (Uploaders "uploaders/anybody")
          (SignWith "default")
          (DebIndices (list
              "Packages"
              "Release"
              "."
              ".gz"
              ".xz"))
          (DscIndices (list
              "Sources"
              "Release"
              ".gz"
              ".xz"))
          (Log "packages.trixie.log
--type=dsc email-changes.sh
")
          (state "present")
          
          (name "bookworm")
          (Description "Packages for Debian GNU/Linux 12 (Bookworm)")
          (Origin (jinja "{{ reprepro__origin }}"))
          (Codename "bookworm")
          (Suite "oldstable")
          (Architectures (list
              "source"
              "amd64"
              "arm64"
              "armel"
              "armhf"
              "i386"
              "mips64el"
              "mipsel"
              "ppc64el"
              "riscv64"
              "s390x"))
          (Components (list
              "main"
              "contrib"
              "non-free"
              "non-free-firmware"))
          (Uploaders "uploaders/anybody")
          (SignWith "default")
          (DebIndices (list
              "Packages"
              "Release"
              "."
              ".gz"
              ".xz"))
          (DscIndices (list
              "Sources"
              "Release"
              ".gz"
              ".xz"))
          (Log "packages.bookworm.log
--type=dsc email-changes.sh
")
          (state "present")
          
          (name "bullseye")
          (Description "Packages for Debian GNU/Linux 11 (Bullseye)")
          (Origin (jinja "{{ reprepro__origin }}"))
          (Codename "bullseye")
          (Suite "oldoldstable")
          (Architectures (list
              "source"
              "amd64"
              "arm64"
              "armel"
              "armhf"
              "i386"
              "mips64el"
              "mipsel"
              "ppc64el"
              "s390x"))
          (Components (list
              "main"
              "contrib"
              "non-free"))
          (Uploaders "uploaders/anybody")
          (SignWith "default")
          (DebIndices (list
              "Packages"
              "Release"
              "."
              ".gz"
              ".xz"))
          (DscIndices (list
              "Sources"
              "Release"
              ".gz"
              ".xz"))
          (Log "packages.bullseye.log
--type=dsc email-changes.sh
")
          (state "present")))
      (uploaders (list
          
          (name "anybody")
          (raw "allow * by any key
")
          (state "present")))))
  (reprepro__instances (list))
  (reprepro__group_instances (list))
  (reprepro__host_instances (list))
  (reprepro__combined_instances (jinja "{{ reprepro__default_instances
                                     + reprepro__instances
                                     + reprepro__group_instances
                                     + reprepro__host_instances }}"))
  (reprepro__keyring__dependent_gpg_user (jinja "{{ reprepro__user }}"))
  (reprepro__keyring__dependent_gpg_keys (list
      
      (user (jinja "{{ reprepro__user }}"))
      (group (jinja "{{ reprepro__group }}"))
      (home (jinja "{{ reprepro__home }}"))
      (jinja "{{ q(\"flattened\", reprepro__gpg_uploaders_keys) }}")))
  (reprepro__nginx__dependent_servers (jinja "{{ reprepro__env_nginx_servers }}")))
