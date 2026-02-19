(playbook "ansible-galaxy/molecule/default/verify.yml"
    (play
    (name "Verify")
    (hosts "all")
    (vars
      (__galaxy_version (jinja "{{ lookup('env', 'GALAXY_VERSION') }}")))
    (tasks
      (task "Check version"
        (uri 
          (url "http://localhost:8080/api/version"))
        (register "response")
        (failed_when "response.status != 200 or (__galaxy_version != 'dev' and response.json.version_major != lookup('env', 'GALAXY_VERSION'))")
        (until "response.status > 0")
        (retries "60")
        (delay "1")))))
