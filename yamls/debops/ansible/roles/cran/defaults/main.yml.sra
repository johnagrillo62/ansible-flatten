(playbook "debops/ansible/roles/cran/defaults/main.yml"
  (cran__upstream "True")
  (cran__upstream_mirror "https://cloud.r-project.org/")
  (cran__upstream_apt_key_map 
    (Debian "E19F5F87128899B192B1A2C2AD5F960A256A04AF")
    (Ubuntu "E298A3A825C0D65DFD57CBB651716619E084DAB9"))
  (cran__upstream_apt_key (jinja "{{ cran__upstream_apt_key_map[ansible_distribution] }}"))
  (cran__upstream_apt_suite_map 
    (Debian (jinja "{{ ansible_distribution_release + \"-cran35/\" }}"))
    (Ubuntu (jinja "{{ ansible_distribution_release + \"-cran35/\" }}")))
  (cran__upstream_apt_suite (jinja "{{ cran__upstream_apt_suite_map[ansible_distribution] }}"))
  (cran__upstream_apt_repo (jinja "{{ \"deb \" + cran__upstream_mirror + \"bin/linux/\"
                             + ansible_distribution | lower + \" \"
                             + cran__upstream_apt_suite }}"))
  (cran__base_packages (list
      "r-base"
      "r-base-dev"
      "r-recommended"))
  (cran__packages (list))
  (cran__group_packages (list))
  (cran__host_packages (list))
  (cran__dependent_packages (list))
  (cran__r_packages (list))
  (cran__group_r_packages (list))
  (cran__host_r_packages (list))
  (cran__dependent_r_packages (list))
  (cran__java_integration (jinja "{{ True
                            if (ansible_local | d() and ansible_local.java | d() and
                                (ansible_local.java.installed | d()) | bool)
                            else False }}"))
  (cran__apt_preferences__dependent_list (list
      
      (packages (list
          "r-cran-coda"
          "rkward"))
      (pin "release o=CRAN")
      (priority "600")
      (by_role "debops_cran")
      (reason "Packages in Debian Archive incompatible with upstream CRAN packages
https://cran.r-project.org/bin/linux/debian/#debian-stretch-stable
")
      (filename "debops_cran.pref")
      (state (jinja "{{ \"present\"
               if (ansible_distribution == \"Debian\" and cran__upstream | bool)
               else \"absent\" }}"))))
  (cran__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ cran__upstream_apt_key }}"))
      (repo (jinja "{{ cran__upstream_apt_repo }}"))
      (state (jinja "{{ \"present\" if cran__upstream | bool else \"absent\" }}")))))
