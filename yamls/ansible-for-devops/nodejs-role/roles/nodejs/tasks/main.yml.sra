(playbook "ansible-for-devops/nodejs-role/roles/nodejs/tasks/main.yml"
  (tasks
    (task "Install Node.js (npm plus all its dependencies)."
      (dnf "name=npm state=present enablerepo=epel"))
    (task "Install forever module (to run our Node.js app)."
      (npm "name=forever global=yes state=present"))))
