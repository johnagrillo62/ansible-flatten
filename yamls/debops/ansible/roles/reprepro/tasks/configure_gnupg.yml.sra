(playbook "debops/ansible/roles/reprepro/tasks/configure_gnupg.yml"
  (tasks
    (task "Check if GnuPG directory exists"
      (ansible.builtin.stat 
        (path (jinja "{{ reprepro__home + \"/.gnupg/gpg.conf\" }}")))
      (register "reprepro__register_gpg"))
    (task "Check if GnuPG snapshot exists on Ansible Controller"
      (ansible.builtin.stat 
        (path (jinja "{{ reprepro__gpg_snapshot_path + \"/\" + reprepro__gpg_snapshot_name }}")))
      (register "reprepro__register_gpg_snapshot")
      (delegate_to "localhost")
      (become "False"))
    (task "Restore GnuPG snapshots"
      (ansible.builtin.unarchive 
        (src (jinja "{{ reprepro__gpg_snapshot_path + \"/\" + reprepro__gpg_snapshot_name }}"))
        (dest (jinja "{{ reprepro__home }}"))
        (mode "u=rwX,g=,o="))
      (when "reprepro__register_gpg_snapshot.stat.exists and not reprepro__register_gpg.stat.exists"))
    (task "Ensure that ~/.gnupg directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ reprepro__home + \"/.gnupg\" }}"))
        (state "directory")
        (owner (jinja "{{ reprepro__user }}"))
        (group (jinja "{{ reprepro__group }}"))
        (mode "0700")))
    (task "Configure reprepro GnuPG instance"
      (ansible.builtin.template 
        (src "home/reprepro/gnupg/gpg.conf.j2")
        (dest (jinja "{{ reprepro__home + \"/.gnupg/gpg.conf\" }}"))
        (owner (jinja "{{ reprepro__user }}"))
        (group (jinja "{{ reprepro__group }}"))
        (mode "0644")))
    (task "Check if private keys are present"
      (ansible.builtin.find 
        (paths (jinja "{{ reprepro__home + \"/.gnupg/private-keys-v1.d/\" }}")))
      (register "reprepro__register_private_keys"))
    (task "Create repository key template"
      (ansible.builtin.template 
        (src "home/reprepro/gnupg-key-template.j2")
        (dest (jinja "{{ reprepro__home + \"/.gnupg-key-template\" }}"))
        (owner (jinja "{{ reprepro__user }}"))
        (group (jinja "{{ reprepro__group }}"))
        (mode "0644"))
      (when "reprepro__register_private_keys.matched == 0"))
    (task "Generate automatic signing key"
      (ansible.builtin.command "gpg --batch --gen-key .gnupg-key-template")
      (args 
        (chdir (jinja "{{ reprepro__home }}")))
      (register "reprepro__register_keygen")
      (changed_when "reprepro__register_keygen.changed | bool")
      (become "True")
      (become_user (jinja "{{ reprepro__user }}"))
      (when "reprepro__register_private_keys.matched == 0"))
    (task "Archive ~/.gnupg directory"
      (community.general.archive 
        (path (jinja "{{ reprepro__home + \"/.gnupg\" }}"))
        (dest (jinja "{{ reprepro__home + \"/\" + reprepro__gpg_snapshot_name }}"))
        (owner (jinja "{{ reprepro__user }}"))
        (group (jinja "{{ reprepro__group }}"))
        (mode "0600"))
      (register "reprepro__register_gpg_archive"))
    (task "Upload ~/.gnupg archive to Ansible Controller"
      (ansible.builtin.fetch 
        (src (jinja "{{ reprepro__home + \"/\" + reprepro__gpg_snapshot_name }}"))
        (dest (jinja "{{ reprepro__gpg_snapshot_path + \"/\" + reprepro__gpg_snapshot_name }}"))
        (flat "True"))
      (when "reprepro__register_gpg_archive is changed"))
    (task "Remove old automatic signing key"
      (ansible.builtin.file 
        (path (jinja "{{ reprepro__home + \"/\" + reprepro__gpg_public_filename }}"))
        (state "absent"))
      (when "reprepro__register_keygen is changed"))
    (task "Export automatic signing key"
      (ansible.builtin.shell "gpg --armor --export \"" (jinja "{{ reprepro__gpg_email }}") "\" > \"" (jinja "{{ reprepro__home + \"/\" + reprepro__gpg_public_filename }}") "\"")
      (args 
        (creates (jinja "{{ reprepro__home + \"/\" + reprepro__gpg_public_filename }}")))
      (become "True")
      (become_user (jinja "{{ reprepro__user }}")))))
