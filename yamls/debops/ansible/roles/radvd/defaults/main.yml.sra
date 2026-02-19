(playbook "debops/ansible/roles/radvd/defaults/main.yml"
  (radvd__base_packages (list
      "radvd"))
  (radvd__packages (list))
  (radvd__rdnss (jinja "{{ (ansible_dns.nameservers | d([])) | ansible.utils.ipv6 }}"))
  (radvd__dnssl (jinja "{{ ansible_dns.search | d([]) }}"))
  (radvd__minimum_advertisement_interval "5")
  (radvd__maximum_advertisement_interval "15")
  (radvd__default_interfaces (jinja "{{ lookup(\"template\",
                               \"lookup/radvd__default_interfaces.j2\") }}"))
  (radvd__interfaces (list))
  (radvd__group_interfaces (list))
  (radvd__host_interfaces (list))
  (radvd__combined_interfaces (jinja "{{ radvd__default_interfaces
                                + radvd__interfaces
                                + radvd__group_interfaces
                                + radvd__host_interfaces }}")))
