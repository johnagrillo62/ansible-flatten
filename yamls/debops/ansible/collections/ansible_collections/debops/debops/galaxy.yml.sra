(playbook "debops/ansible/collections/ansible_collections/debops/debops/galaxy.yml"
  (namespace "debops")
  (name "debops")
  (version "1.0.0")
  (description "Your Debian-based data center in a box")
  (authors (list
      "Maciej Delmanowski <drybjed@gmail.com>"
      "DebOps Developers <debops-users@lists.debops.org>"))
  (repository "https://github.com/debops/debops")
  (documentation "https://docs.debops.org/en/master/ansible/role-index.html")
  (homepage "https://debops.org/")
  (issues "https://github.com/debops/debops/issues")
  (readme "README.md")
  (license (list
      "GPL-3.0-or-later"))
  (tags (list
      "debian"
      "ubuntu"
      "linux"
      "infrastructure"
      "debops"
      "sysadmin"
      "cluster"
      "datacenter"))
  (dependencies 
    (ansible.posix "*")
    (ansible.utils "*")
    (community.crypto "*")
    (community.docker "*")
    (community.general "*")
    (community.libvirt "*")
    (community.mysql "*")
    (community.postgresql "*")
    (community.rabbitmq "*")))
