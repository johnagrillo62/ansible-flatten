(playbook "yaml/roles/git/defaults/main.yml"
  (cgit_version "1.1")
  (cgit_domain "git." (jinja "{{ domain }}"))
  (gitolite_version "3.6.4"))
