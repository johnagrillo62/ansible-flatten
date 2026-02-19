(playbook "ansible-examples/language_features/register_logic.yml"
    (play
    (name "test playbook")
    (remote_user "root")
    (hosts "all")
    (tasks
      (task
        (shell "grep hi /etc/motd")
        (ignore_errors "yes")
        (register "motd_result"))
      (task
        (shell "echo \"motd contains the word hi\"")
        (when "motd_result.rc == 0"))
      (task
        (shell "echo \"motd contains the word hi\"")
        (when "motd_result.stdout.find('hi') != -1"))
      (task
        (shell "echo \"motd contains word hi\"")
        (when "'hi' in motd_result.stdout"))
      (task "motd lines matching 'hi'"
        (shell "echo \"" (jinja "{{ item  }}") "\"")
        (with_items "motd_result.stdout_lines"))
      (task "motd lines matching 'hi'"
        (shell "echo \"" (jinja "{{ item  }}") "\"")
        (with_items "motd_result.stdout.split('\\n')")))))
