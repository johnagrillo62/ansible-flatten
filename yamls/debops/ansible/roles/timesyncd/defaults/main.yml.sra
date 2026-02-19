(playbook "debops/ansible/roles/timesyncd/defaults/main.yml"
  (timesyncd__enabled (jinja "{{ True
                       if (ansible_service_mgr == \"systemd\" and
                           timesyncd__fact_service_state == \"present\")
                       else False }}"))
  (timesyncd__deploy_state "absent")
  (timesyncd__base_packages (list
      "systemd-timesyncd"))
  (timesyncd__packages (list))
  (timesyncd__skip_packages (list
      "openntpd"
      "ntpsec"
      "ntp"
      "chrony"))
  (timesyncd__version (jinja "{{ ansible_local.timesyncd.version | d(\"0\") }}"))
  (timesyncd__default_configuration (list
      
      (name "NTP")
      (value (list))
      (state "init")
      
      (name "FallbackNTP")
      (value (list
          "0.debian.pool.ntp.org"
          "1.debian.pool.ntp.org"
          "2.debian.pool.ntp.org"
          "3.debian.pool.ntp.org"))
      (state "init")
      
      (name "RootDistanceMaxSec")
      (value "5")
      (state "init")
      
      (name "PollIntervalMinSec")
      (value "32")
      (state "init")
      
      (name "PollIntervalMaxSec")
      (value "2048")
      (state "init")))
  (timesyncd__configuration (list))
  (timesyncd__group_configuration (list))
  (timesyncd__host_configuration (list))
  (timesyncd__combined_configuration (jinja "{{ timesyncd__default_configuration
                                       + timesyncd__configuration
                                       + timesyncd__group_configuration
                                       + timesyncd__host_configuration }}"))
  (timesyncd__dpkg_cleanup__dependent_packages (list
      
      (name "systemd-timesyncd")
      (ansible_fact "timesyncd"))))
