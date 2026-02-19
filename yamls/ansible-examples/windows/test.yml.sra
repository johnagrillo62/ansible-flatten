(playbook "ansible-examples/windows/test.yml"
    (play
    (name "test raw module")
    (hosts "all")
    (tasks
      (task "run ipconfig"
        (raw "ipconfig")
        (register "ipconfig"))
      (task
        (debug "var=ipconfig"))))
    (play
    (name "test stat module")
    (hosts "windows")
    (tasks
      (task "test stat module on file"
        (win_stat "path=\"C:/Windows/win.ini\"")
        (register "stat_file"))
      (task
        (debug "var=stat_file"))
      (task "check stat_file result"
        (assert 
          (that (list
              "stat_file.stat.exists"
              "not stat_file.stat.isdir"
              "stat_file.stat.size > 0"
              "stat_file.stat.md5")))))))
