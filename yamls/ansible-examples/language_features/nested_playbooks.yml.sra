(playbook "ansible-examples/language_features/nested_playbooks.yml"
  (list
    
    (name "this is a play at the top level of a file")
    (hosts "all")
    (remote_user "root")
    (tasks (list
        
        (name "say hi")
        (tags "foo")
        (shell "echo \"hi...\"")))
    
    (include "intro_example.yml")))
