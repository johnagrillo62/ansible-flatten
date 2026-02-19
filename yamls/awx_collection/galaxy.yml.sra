(playbook "awx_collection/galaxy.yml"
  (authors (list
      "AWX Project Contributors <awx-project@googlegroups.com>"))
  (dependencies )
  (description "Ansible content that interacts with the AWX or Automation Platform Controller API.")
  (documentation "https://github.com/ansible/awx/blob/devel/awx_collection/README.md")
  (homepage "https://www.ansible.com/")
  (issues "https://github.com/ansible/awx/issues?q=is%3Aissue+label%3Acomponent%3Aawx_collection")
  (license (list
      "GPL-3.0-or-later"))
  (name "awx")
  (namespace "awx")
  (readme "README.md")
  (repository "https://github.com/ansible/awx")
  (tags (list
      "cloud"
      "infrastructure"
      "awx"
      "ansible"
      "automation"))
  (version "0.0.1-devel")
  (build_ignore (list
      "tools"
      "setup.cfg"
      "galaxy.yml.j2"
      "template_galaxy.yml"
      "*.tar.gz")))
