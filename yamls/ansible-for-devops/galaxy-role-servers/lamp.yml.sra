(playbook "ansible-for-devops/galaxy-role-servers/lamp.yml"
    (play
    (hosts "all")
    (become "yes")
    (roles
      "geerlingguy.mysql"
      "geerlingguy.apache"
      "geerlingguy.php"
      "geerlingguy.php-mysql")))
