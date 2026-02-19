(playbook "debops/ansible/roles/elastic_co/defaults/main.yml"
  (elastic_co__version (jinja "{{ ansible_local.elastic_co.version | d(\"7.x\") }}"))
  (elastic_co__curator_version (jinja "{{ ansible_local.elastic_co.curator_version | d(\"5\") }}"))
  (elastic_co__key_id "4609 5ACC 8548 582C 1A26 99A9 D27D 666C D88E 42B4")
  (elastic_co__repositories (list
      
      (repo "deb https://artifacts.elastic.co/packages/" (jinja "{{ elastic_co__version }}") "/apt stable main")
      
      (repo "deb https://packages.elastic.co/curator/" (jinja "{{ elastic_co__curator_version }}") "/debian9 stable main")
      (enabled (jinja "{{ ansible_distribution_release in ['stretch'] }}"))))
  (elastic_co__heartbeat_override "True")
  (elastic_co__packages (list))
  (elastic_co__group_packages (list))
  (elastic_co__host_packages (list))
  (elastic_co__dependent_packages (list))
  (elastic_co__apt_preferences__dependent_list (list
      
      (package "heartbeat")
      (pin "origin artifacts.elastic.co")
      (priority "700")
      (reason "Conflicts with \"heartbeat\" package from OS archives")
      (by_role "debops.elastic_co")
      (state (jinja "{{ \"present\" if elastic_co__heartbeat_override | bool else \"absent\" }}"))))
  (elastic_co__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ elastic_co__key_id }}")))))
