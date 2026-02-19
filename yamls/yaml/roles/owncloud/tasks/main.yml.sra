(playbook "yaml/roles/owncloud/tasks/main.yml"
  (tasks
    (task
      (debug 
        (msg "OwnCloud is not supported in this distribution release https://github.com/sovereign/sovereign/issues/765"))
      (when "ansible_distribution_release in [\"jessie\", \"trusty\"]"))
    (task
      (import_tasks "owncloud.yml")
      (tags "owncloud")
      (when "ansible_distribution_release not in [\"jessie\", \"trusty\"]"))))
