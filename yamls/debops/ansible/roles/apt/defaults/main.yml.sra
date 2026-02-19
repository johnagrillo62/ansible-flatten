(playbook "debops/ansible/roles/apt/defaults/main.yml"
  (apt__enabled (jinja "{{ True if (ansible_pkg_mgr == \"apt\") else False }}"))
  (apt__deploy_state (jinja "{{ \"present\"
                       if (ansible_facts.distribution in [\"Debian\", \"Raspbian\", \"Ubuntu\", \"Devuan\"])
                       else \"absent\" }}"))
  (apt__cache_valid_time (jinja "{{ ansible_local.core.cache_valid_time | d(60 * 60 * 24) }}"))
  (apt__base_packages (list
      "lsb-release"
      "ca-certificates"
      (jinja "{{ \"apt-transport-https\"
        if (ansible_distribution_release in
            [\"stretch\", \"trusty\", \"xenial\"])
        else [] }}")
      "gnupg"))
  (apt__packages (list))
  (apt__archive_types (list
      "deb"
      "deb-src"))
  (apt__archive_sources_disabled "True")
  (apt__architecture (jinja "{{ apt__architecture_map[ansible_facts.architecture]
                       | d(ansible_facts.architecture) }}"))
  (apt__architecture_map 
    (x86_64 "amd64")
    (armv7l "armhf")
    (aarch64 "arm64"))
  (apt__distribution (jinja "{{ ansible_facts.lsb.id | d(ansible_facts.distribution) }}"))
  (apt__distribution_release (jinja "{{ ansible_facts.lsb.codename
                               | d(ansible_facts.distribution_release) }}"))
  (apt__distribution_version (jinja "{{ ansible_facts.distribution_version }}"))
  (apt__nonfree (jinja "{{ ansible_facts.ansible_local.apt.nonfree
                  | d(True
                      if (ansible_facts.virtualization_role is undefined or
                          ansible_facts.virtualization_role != \"guest\")
                      else False) }}"))
  (apt__nonfree_firmware (jinja "{{ True
                           if (ansible_facts.virtualization_role is undefined or
                               ansible_facts.virtualization_role != \"guest\")
                           else False }}"))
  (apt__distribution_repository_map 
    (Debian "http://deb.debian.org/debian")
    (Devuan "http://deb.devuan.org/merged")
    (Ubuntu (jinja "{{ \"http://archive.ubuntu.com/ubuntu\"
                if (apt__architecture in [\"amd64\", \"i386\"])
                else \"http://ports.ubuntu.com/ubuntu-ports\" }}")))
  (apt__debian_archived_releases (list
      "wheezy"
      "jessie"
      "stretch"
      "buster"))
  (apt__debian_sources (list
      
      (name "debian-release")
      (types (jinja "{{ apt__archive_types }}"))
      (uri (jinja "{{ apt__distribution_repository_map.Debian | d() }}"))
      (suites (list
          (jinja "{{ apt__distribution_release }}")))
      (components (list
          "main"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Debian\")
               else \"ignore\" }}"))
      
      (name "debian-release")
      (uri "http://archive.debian.org/debian")
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Debian\" and
                   apt__distribution_release in apt__debian_archived_releases)
               else \"ignore\" }}"))
      
      (name "debian-release")
      (suites (list
          (jinja "{{ apt__distribution_release + \"-updates\" }}")))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Debian\" and
                   apt__distribution_release not in apt__debian_archived_releases and
                   apt__distribution_version != \"n/a\")
               else \"ignore\" }}"))
      
      (name "debian-release")
      (suites (list
          (jinja "{{ apt__distribution_release + \"-backports\" }}")))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Debian\" and
                   apt__distribution_version != \"n/a\")
               else \"ignore\" }}"))
      
      (name "debian-release")
      (components (list
          "non-free-firmware"))
      (state (jinja "{{ \"ignore\"
               if (apt__distribution == \"Debian\" and
                   apt__distribution_release in [\"wheezy\", \"jessie\", \"stretch\",
                                                 \"buster\", \"bullseye\"])
               else (\"present\"
                     if (apt__distribution == \"Debian\" and
                         apt__nonfree_firmware | bool)
                     else \"ignore\") }}"))
      
      (name "debian-release")
      (components (list
          "contrib"
          "non-free"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Debian\" and
                   apt__nonfree | bool)
               else \"ignore\" }}"))
      
      (name "debian-release-security")
      (types (jinja "{{ apt__archive_types }}"))
      (uri "http://deb.debian.org/debian-security/")
      (suites (list
          (jinja "{{ apt__distribution_release + \"-security\" }}")))
      (components (list
          "main"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Debian\" and
                   apt__distribution_release not in apt__debian_archived_releases and
                   apt__distribution_version != \"n/a\")
               else \"ignore\" }}"))
      
      (name "debian-release-security")
      (uri "http://security.debian.org/")
      (suites (list
          
          (name (jinja "{{ apt__distribution_release + \"-security\" }}"))
          (state "absent")
          (jinja "{{ apt__distribution_release + \"/updates\" }}")))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Debian\" and
                   apt__distribution_release not in apt__debian_archived_releases and
                   apt__distribution_release in [\"buster\"] and
                   apt__distribution_version != \"n/a\")
               else \"ignore\" }}"))
      
      (name "debian-release-security")
      (components (list
          "non-free-firmware"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Debian\" and
                   apt__distribution_release not in apt__debian_archived_releases and
                   apt__distribution_release not in [\"buster\", \"bullseye\"] and
                   apt__distribution_version != \"n/a\" and
                   apt__nonfree_firmware | bool)
               else \"ignore\" }}"))
      
      (name "debian-release-security")
      (components (list
          "contrib"
          "non-free"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Debian\" and
                   apt__distribution_release not in apt__debian_archived_releases and
                   apt__distribution_version != \"n/a\" and
                   apt__nonfree | bool)
               else \"ignore\" }}"))))
  (apt__devuan_sources (list
      
      (name "devuan-release")
      (types (jinja "{{ apt__archive_types }}"))
      (uri (jinja "{{ apt__distribution_repository_map.Devuan | d() }}"))
      (suites (list
          (jinja "{{ apt__distribution_release }}")))
      (components (list
          "main"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Devuan\")
               else \"ignore\" }}"))
      
      (name "devuan-release")
      (uri "http://archive.devuan.org/merged")
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Devuan\" and
                   apt__distribution_release in [\"jessie\", \"ascii\"])
               else \"ignore\" }}"))
      
      (name "devuan-release")
      (suites (list
          (jinja "{{ apt__distribution_release + \"-updates\" }}")))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Devuan\" and
                   apt__distribution_release not in [\"jessie\", \"ascii\"] and
                   apt__distribution_version != \"n/a\")
               else \"ignore\" }}"))
      
      (name "devuan-release")
      (suites (list
          (jinja "{{ apt__distribution_release + \"-backports\" }}")))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Devuan\" and
                   apt__distribution_release not in [\"jessie\"] and
                   apt__distribution_version != \"n/a\")
               else \"ignore\" }}"))
      
      (name "devuan-release")
      (components (list
          "contrib"
          "non-free"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Devuan\" and
                   apt__nonfree | bool)
               else \"ignore\" }}"))
      
      (name "devuan-release-security")
      (types (jinja "{{ apt__archive_types }}"))
      (uri "http://pkgmaster.devuan.org/merged")
      (suites (list
          (jinja "{{ apt__distribution_release + \"-security\" }}")))
      (components (list
          "main"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Devuan\" and
                   apt__distribution_release not in [\"jessie\", \"ascii\"] and
                   apt__distribution_version != \"n/a\")
               else \"ignore\" }}"))
      
      (name "devuan-release-security")
      (components (list
          "contrib"
          "non-free"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Devuan\" and
                   apt__distribution_release not in [\"jessie\", \"ascii\"] and
                   apt__distribution_version != \"n/a\" and
                   apt__nonfree | bool)
               else \"ignore\" }}"))))
  (apt__ubuntu_sources (list
      
      (name "ubuntu-release")
      (comment "See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
newer versions of the distribution.
")
      (types (jinja "{{ apt__archive_types }}"))
      (uri (jinja "{{ apt__distribution_repository_map.Ubuntu | d() }}"))
      (suites (list
          (jinja "{{ apt__distribution_release }}")))
      (components (list
          "main"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Ubuntu\")
               else \"ignore\" }}"))
      
      (name "ubuntu-release")
      (components (list
          "restricted"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Ubuntu\" and
                   apt__nonfree | bool)
               else \"ignore\" }}"))
      
      (name "ubuntu-release-updates")
      (comment "Major bug fix updates produced after the final release of the
distribution.
")
      (types (jinja "{{ apt__archive_types }}"))
      (uri (jinja "{{ apt__distribution_repository_map.Ubuntu | d() }}"))
      (suites (list
          (jinja "{{ apt__distribution_release + \"-updates\" }}")))
      (components (list
          "main"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Ubuntu\" and
                   apt__distribution_version != \"n/a\")
               else \"ignore\" }}"))
      
      (name "ubuntu-release-updates")
      (components (list
          "restricted"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Ubuntu\" and
                   apt__distribution_version != \"n/a\" and
                   apt__nonfree | bool)
               else \"ignore\" }}"))
      
      (name "ubuntu-release-universe")
      (comment "N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
team. Also, please note that software in universe WILL NOT receive any
review or updates from the Ubuntu security team.
")
      (types (jinja "{{ apt__archive_types }}"))
      (uri (jinja "{{ apt__distribution_repository_map.Ubuntu | d() }}"))
      (suites (list
          (jinja "{{ apt__distribution_release }}")
          (jinja "{{ apt__distribution_release + \"-updates\" }}")))
      (components (list
          "universe"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Ubuntu\")
               else \"ignore\" }}"))
      
      (name "ubuntu-release-multiverse")
      (comment "N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
team, and may not be under a free licence. Please satisfy yourself as to
your rights to use the software. Also, please note that software in
multiverse WILL NOT receive any review or updates from the Ubuntu
security team.
")
      (types (jinja "{{ apt__archive_types }}"))
      (uri (jinja "{{ apt__distribution_repository_map.Ubuntu | d() }}"))
      (suites (list
          (jinja "{{ apt__distribution_release }}")
          (jinja "{{ apt__distribution_release + \"-updates\" }}")))
      (components (list
          "multiverse"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Ubuntu\" and
                   apt__nonfree | bool)
               else \"ignore\" }}"))
      
      (name "ubuntu-release-backports")
      (comment "N.B. software from this repository may not have been tested as
extensively as that contained in the main release, although it includes
newer versions of some applications which may provide useful features.
Also, please note that software in backports WILL NOT receive any review
or updates from the Ubuntu security team.
")
      (types (jinja "{{ apt__archive_types }}"))
      (uri (jinja "{{ apt__distribution_repository_map.Ubuntu | d() }}"))
      (suites (list
          (jinja "{{ apt__distribution_release + \"-backports\" }}")))
      (components (list
          "main"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Ubuntu\" and
                   apt__distribution_version != \"n/a\")
               else \"ignore\" }}"))
      
      (name "ubuntu-release-backports")
      (components (list
          "restricted"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Ubuntu\" and
                   apt__distribution_version != \"n/a\" and
                   apt__nonfree | bool)
               else \"ignore\" }}"))
      
      (name "ubuntu-release-backports")
      (components (list
          "universe"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Ubuntu\" and
                   apt__distribution_version != \"n/a\")
               else \"ignore\" }}"))
      
      (name "ubuntu-release-backports")
      (components (list
          "multiverse"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Ubuntu\" and
                   apt__distribution_version != \"n/a\" and
                   apt__nonfree | bool)
               else \"ignore\" }}"))
      
      (name "ubuntu-release-partner")
      (comment "Uncomment the following two lines to add software from Canonical's
'partner' repository.
This software is not part of Ubuntu, but is offered by Canonical and the
respective vendors as a service to Ubuntu users.
")
      (types (jinja "{{ apt__archive_types }}"))
      (uri "http://archive.canonical.com/ubuntu")
      (suites (list
          (jinja "{{ apt__distribution_release }}")))
      (components (list
          "partner"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Ubuntu\" and
                   apt__distribution_version != \"n/a\" and
                   apt__nonfree | bool)
               else \"ignore\" }}"))
      
      (name "ubuntu-release-security")
      (types (jinja "{{ apt__archive_types }}"))
      (uri (jinja "{{ apt__distribution_repository_map.Ubuntu | d() }}"))
      (suites (list
          (jinja "{{ apt__distribution_release + \"-security\" }}")))
      (components (list
          "main"))
      (separate "False")
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Ubuntu\" and
                   apt__distribution_version != \"n/a\")
               else \"ignore\" }}"))
      
      (name "ubuntu-release-security")
      (components (list
          "restricted"))
      (separate "False")
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Ubuntu\" and
                   apt__distribution_version != \"n/a\" and
                   apt__nonfree | bool)
               else \"ignore\" }}"))
      
      (name "ubuntu-release-universe-security")
      (types (jinja "{{ apt__archive_types }}"))
      (uri (jinja "{{ apt__distribution_repository_map.Ubuntu | d() }}"))
      (suites (list
          (jinja "{{ apt__distribution_release + \"-security\" }}")))
      (components (list
          "universe"))
      (separate "False")
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Ubuntu\" and
                   apt__distribution_version != \"n/a\")
               else \"ignore\" }}"))
      
      (name "ubuntu-release-multiverse-security")
      (types (jinja "{{ apt__archive_types }}"))
      (uri (jinja "{{ apt__distribution_repository_map.Ubuntu | d() }}"))
      (suites (list
          (jinja "{{ apt__distribution_release + \"-security\" }}")))
      (components (list
          "multiverse"))
      (state (jinja "{{ \"present\"
               if (apt__distribution == \"Ubuntu\" and
                   apt__distribution_version != \"n/a\" and
                   apt__nonfree | bool)
               else \"ignore\" }}"))))
  (apt__sources (list))
  (apt__group_sources (list))
  (apt__host_sources (list))
  (apt__combined_sources (jinja "{{ apt__debian_sources
                           + apt__devuan_sources
                           + apt__ubuntu_sources
                           + apt__sources
                           + apt__group_sources
                           + apt__host_sources }}"))
  (apt__extra_architectures (list))
  (apt__group_extra_architectures (list))
  (apt__host_extra_architectures (list))
  (apt__purge_packages (list))
  (apt__purge_group_packages (list))
  (apt__purge_host_packages (list))
  (apt__keys (list))
  (apt__group_keys (list))
  (apt__host_keys (list))
  (apt__repositories (list))
  (apt__group_repositories (list))
  (apt__host_repositories (list))
  (apt__combined_repositories (jinja "{{ apt__repositories
                                + apt__group_repositories
                                + apt__host_repositories }}"))
  (apt__auth_files (list))
  (apt__group_auth_files (list))
  (apt__host_auth_files (list))
  (apt__default_configuration (list
      
      (name "non-free-firmware-note")
      (filename "non-free-firmware-note.conf")
      (comment "Disable note about Debian Bookworm moving firmware to a separate section")
      (raw "APT::Get::Update::SourceListWarnings::NonFreeFirmware \"false\";
")
      (state (jinja "{{ \"ignore\"
               if (apt__distribution == \"Debian\" and
                   apt__distribution_release in [\"wheezy\", \"jessie\", \"stretch\",
                                                 \"buster\", \"bullseye\"])
               else \"present\" }}"))
      
      (name "no-recommends")
      (filename "25no-recommends.conf")
      (comment "Should APT install recommended or suggested packages?")
      (raw "APT::Install-Recommends \"false\";
APT::Install-Suggests \"false\";
")
      (state "present")))
  (apt__configuration (list))
  (apt__group_configuration (list))
  (apt__host_configuration (list))
  (apt__combined_configuration (jinja "{{ apt__default_configuration
                                 + apt__configuration
                                 + apt__group_configuration
                                 + apt__host_configuration }}")))
