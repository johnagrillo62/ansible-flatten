(playbook "yaml/roles/git/tasks/gitolite.yml"
  (tasks
    (task "Create gitolite group"
      (group "name=git state=present"))
    (task "Create gitolite user"
      (user "name=git state=present home=/home/git system=yes group=git"))
    (task "Add www-data to the git group"
      (user "name=www-data groups=git append=yes"))
    (task "Install gitolite3 package"
      (apt "pkg=gitolite3 state=present")
      (tags (list
          "dependencies")))
    (task "Copy .gitolite.rc file"
      (copy "src=home_git_.gitolite.rc dest=/home/git/.gitolite.rc group=git owner=git mode=0644"))
    (task "Copy SSH public key to server"
      (copy "src=gitolite.pub dest=/home/git/" (jinja "{{ main_user_name }}") ".pub group=git owner=git mode=0644"))
    (task "Setup gitolite"
      (command "gitolite setup -pk " (jinja "{{ main_user_name }}") ".pub chdir=/home/git")
      (become_user "git")
      (tags (list
          "skip_ansible_lint")))))
