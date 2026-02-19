(playbook "tools/docker-compose/ansible/requirements.yml"
  (collections (list
      
      (source "./awx_collection")
      (type "dir")
      "flowerysong.hvault"
      "community.docker")))
