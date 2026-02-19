(playbook "debops/ansible/roles/apt_preferences/defaults/main.yml"
  (apt_preferences__list (list))
  (apt_preferences__group_list (list))
  (apt_preferences__host_list (list))
  (apt_preferences__dependent_list (list))
  (apt_preferences__debian_stable_default_preset_list (list
      
      (package "*")
      (by_role "debops.apt_preferences")
      (suffix "_Debian")
      (raw "Explanation: Configure the installed release explicitly to slightly higher than the default priority of 500 so that release packages are preferred over third party repos.
Package: *
Pin: release o=Debian,n=" (jinja "{{ ansible_distribution_release }}") "
Pin-Priority: 550

Explanation: Configure the security updates explicitly to slightly higher than the default priority of 500 so that security updates are not missing
Package: *
Pin: release o=Debian,n=" (jinja "{{ ansible_distribution_release }}") "-security
Pin-Priority: 550

Explanation: Configure the stable-updates explicitly to slightly higher than the default priority of 500 so that stable-updates are not missing
Package: *
Pin: release o=Debian,n=" (jinja "{{ ansible_distribution_release }}") "-updates
Pin-Priority: 550

Explanation: Configure the installed release explicitly to slightly higher than the default priority of 500 so that release packages are preferred over third party repos.
Package: *
Pin: release o=Qubes Debian,n=" (jinja "{{ ansible_distribution_release }}") "
Pin-Priority: 550

Explanation: The default priority of packages from backports is 100 which is even lower then testing and unstable (500).
Explanation: Prefer backports over testing and unstable but don’t automatically upgrade to them.
Package: *
Pin: release o=Debian Backports,n=" (jinja "{{ ansible_distribution_release }}") "-backports
Pin-Priority: 400

Explanation: Pin NeuroDebian with priority 80 which is lower then the official Debian backports (100).
Explanation: This also works with this pinning configuration where Debian backports is
Explanation: set to 400 and Debian testing is decreased to 50.
Explanation: It is done here additionally to the neurodebian role to allow soft migration to extrepo.
Package: *
Pin: release o=NeuroDebian
Pin-Priority: 80

Explanation: In case ansible_distribution_release is not (anymore) the current stable release don’t automatically upgrade to it.
Package: *
Pin: release o=Debian,a=stable
Pin-Priority: 60

Explanation: Install packages from testing if no package with the same name is available in release archives or backports or other archives.
Package: *
Pin: release o=Debian,a=testing
Pin-Priority: 50

Explanation: Only install packages from unstable if explicitly asked for or the package is pinned.
Package: *
Pin: release o=Debian,a=unstable
Pin-Priority: -1

Explanation: Only install packages from experimental if explicitly asked for or the package is pinned.
Package: *
Pin: release o=Debian,a=experimental
Pin-Priority: -1
")))
  (apt_preferences__preset_list (jinja "{{
    ((apt_preferences__debian_stable_default_preset_list | list) if (ansible_distribution == \"Debian\") else [])
  }}"))
  (apt_preferences__priority_default "500")
  (apt_preferences__priority_version "1001")
  (apt_preferences__next_release 
    (stretch "buster")
    (buster "bullseye")
    (bullseye "bookworm")
    (bookworm "trixie")
    (trixie "forky")
    (trusty "utopic")
    (utopic "vivid")
    (vivid "wily")
    (wily "xenial")
    (xenial "yakkety")))
