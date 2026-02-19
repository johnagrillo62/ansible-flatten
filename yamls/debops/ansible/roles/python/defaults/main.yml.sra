(playbook "debops/ansible/roles/python/defaults/main.yml"
  (python__enabled "True")
  (python__raw_apt_cache_valid_time "-" (jinja "{{ 60 * 60 * 12 }}"))
  (python__raw_etc_hosts "")
  (python__v3 "True")
  (python__core_packages3 (list
      "python3"
      "python3-apt"
      "python3-debian"))
  (python__base_packages3 (list
      "python3-httplib2"
      "python3-pip"
      "python3-setuptools"
      "python3-pycurl"
      "python3-virtualenv"
      "python3-wheel"
      "virtualenv"))
  (python__packages3 (list))
  (python__group_packages3 (list))
  (python__host_packages3 (list))
  (python__dependent_packages3 (list))
  (python__v2 (jinja "{{ ansible_local.python.installed2
                if (ansible_local | d() and ansible_local.python | d() and
                    ansible_local.python.installed2 is defined)
                else (True
                      if ((ansible_python_interpreter | d(\"\")).endswith(\"python\") or
                          (discovered_interpreter_python | d(\"\")).endswith(\"python\") or
                           (python__register_raw_release | d() and
                            (python__register_raw_release.stdout | d(\"\")).strip() in
                            [\"stretch\", \"trusty\", \"xenial\"]))
                      else False) }}"))
  (python__core_packages2 (list
      "python"
      "python-apt-common"))
  (python__base_packages2 (list
      "python-httplib2"
      (jinja "{{ \"python-pip\"
        if (ansible_distribution_release in
            [\"stretch\", \"buster\",
             \"trusty\", \"xenial\", \"bionic\"])
           else [] }}")
      "python-setuptools"
      "python-pycurl"
      "python-virtualenv"
      "python-wheel"))
  (python__packages2 (list))
  (python__group_packages2 (list))
  (python__host_packages2 (list))
  (python__dependent_packages2 (list))
  (python__core_packages (jinja "{{ (python__core_packages3
                            if (python__v3 | bool) else [])
                           + (python__core_packages2
                              if (python__v2 | bool) else []) }}"))
  (python__combined_packages (jinja "{{ python__core_packages
                               + ((python__base_packages3
                                   + python__packages3
                                   + python__group_packages3
                                   + python__host_packages3
                                   + python__dependent_packages3)
                                  if python__v3 | bool else [])
                               + ((python__base_packages2
                                   + python__packages2
                                   + python__group_packages2
                                   + python__host_packages2
                                   + python__dependent_packages2)
                                  if python__v2 | bool else []) }}"))
  (python__raw_purge_v2 (jinja "{{ False
                          if (python__v2 | bool)
                          else True }}"))
  (python__raw_purge_packages2 (list
      "python"
      "python2.7"
      "libpython2.7-minimal"))
  (python__pip_version_check "False"))
