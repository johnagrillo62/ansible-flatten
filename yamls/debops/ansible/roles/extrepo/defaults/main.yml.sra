(playbook "debops/ansible/roles/extrepo/defaults/main.yml"
  (extrepo__enabled (jinja "{{ False
                      if (ansible_distribution != \"Debian\" or
                          ansible_distribution_release in [\"stretch\"])
                      else True }}"))
  (extrepo__base_packages (list
      "extrepo"))
  (extrepo__packages (list))
  (extrepo__default_configuration (list
      
      (name "defaults")
      (config 
        (url "https://extrepo-team.pages.debian.net/extrepo-data")
        (dist (jinja "{{ ansible_distribution | lower }}"))
        (version (jinja "{{ ansible_distribution_release }}")))
      
      (name "policies")
      (config 
        (enabled_policies (jinja "{{ ansible_local.apt.components | d([\"main\"]) }}")))))
  (extrepo__configuration (list))
  (extrepo__combined_configuration (jinja "{{ extrepo__default_configuration
                                     + extrepo__configuration }}"))
  (extrepo__sources (list))
  (extrepo__group_sources (list))
  (extrepo__host_sources (list))
  (extrepo__dependent_sources (list))
  (extrepo__combined_sources (jinja "{{ extrepo__dependent_sources
                               + extrepo__sources
                               + extrepo__group_sources
                               + extrepo__host_sources }}")))
