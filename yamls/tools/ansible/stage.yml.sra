(playbook "tools/ansible/stage.yml"
    (play
    (hosts "localhost")
    (connection "local")
    (vars
      (changelog_path "")
      (payload 
        (body (jinja "{{ (lookup('file', changelog_path) | replace('\\\\n', '\\n')) if changelog_path else '' }}"))
        (name (jinja "{{ version }}"))
        (tag_name (jinja "{{ version }}"))
        (draft "true")))
    (tasks
      (task "Publish draft Release"
        (uri 
          (url "https://api.github.com/repos/" (jinja "{{ repo }}") "/releases")
          (method "POST")
          (headers 
            (Accept "application/vnd.github.v3+json")
            (Authorization "Bearer " (jinja "{{ github_token }}")))
          (body (jinja "{{ payload | to_json }}"))
          (status_code (list
              "200"
              "201")))))))
