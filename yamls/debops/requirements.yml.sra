(playbook "debops/requirements.yml"
  (collections (list
      "ansible.posix"
      "ansible.utils"
      "community.crypto"
      "community.docker"
      "community.general"
      "community.libvirt"
      "community.mysql"
      "community.postgresql"
      "community.rabbitmq")))
