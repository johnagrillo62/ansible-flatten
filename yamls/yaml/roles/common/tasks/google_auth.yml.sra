(playbook "yaml/roles/common/tasks/google_auth.yml"
  (tasks
    (task "Ensure required packages are installed"
      (apt "pkg=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "libpam-google-authenticator"
          "libpam0g-dev"
          "libqrencode3"))
      (tags (list
          "dependencies")))
    (task "Update sshd config to enable challenge responses"
      (lineinfile "dest=/etc/ssh/sshd_config regexp=^ChallengeResponseAuthentication line=\"ChallengeResponseAuthentication yes\" state=present")
      (notify "restart ssh"))
    (task "Add Google authenticator to PAM"
      (lineinfile "dest=/etc/pam.d/sshd line=\"auth required pam_google_authenticator.so\" insertbefore=BOF state=present"))
    (task "Generate a time-based secret code"
      (command "/usr/bin/google-authenticator -t -f -d --label=\"" (jinja "{{ main_user_name }}") "@" (jinja "{{ domain }}") "\" --qr-mode=ANSI -r 3 -R 30 -w 1 --secret=/home/" (jinja "{{ main_user_name }}") "/.google_authenticator creates=/home/" (jinja "{{ main_user_name }}") "/.google_authenticator")
      (become "yes")
      (become_user (jinja "{{ main_user_name }}"))
      (when "ansible_ssh_user != \"vagrant\""))
    (task "Retrieve generated keys from server"
      (fetch "src=/home/" (jinja "{{ main_user_name }}") "/.google_authenticator dest=/tmp/sovereign-google-auth-files")
      (when "ansible_ssh_user != \"vagrant\""))
    (task "Pause for Google Authenticator instructions"
      (pause "seconds=5 prompt=\"Your Google Authentication keys are in /tmp/sovereign-google-auth-files. Press any key to continue...\"")
      (when "ansible_ssh_user != \"vagrant\""))))
