(playbook "debops/ansible/roles/sysnews/defaults/main.yml"
  (sysnews__base_packages (list
      "sysnews"))
  (sysnews__packages (list))
  (sysnews__notification "True")
  (sysnews__notification_min_uid "900")
  (sysnews__notification_max_uid "")
  (sysnews__notification_command "/usr/bin/news -l -n")
  (sysnews__group "staff")
  (sysnews__entry_contact (jinja "{{ ansible_local.machine.contact | d(\"\") }}"))
  (sysnews__default_entries (list
      
      (name "Welcome to System News")
      (content "This host has support for the \"System News\" bulletin, which can be read
using the 'news' command.

Members of the '" (jinja "{{ sysnews__group }}") "' UNIX system group can create news entries in the form
of text files located in the '/var/lib/sysnews/' directory. The news items
will automatically expire after a month, unless they are specifically
marked for no expiration.

Read the news(1) manpage for more details.
")
      (state "present")
      
      (name "This machine is managed using Ansible")
      (content "Ansible is a Configuration Management tool used to configure hosts in an
automated fashion.

Any changes in files which are managed using Ansible may be unexpectedly
lost if not accounted for by the system administrator. These files can be
recognized by a special annotation near the top of the file which informs
that this file is managed remotely.
" (jinja "{% if sysnews__entry_contact | d() %}") "

If you want to perform system modifications on this host, consider
contacting the system administrators first. They can be reached using
" (jinja "{{ sysnews__entry_contact }}") "
" (jinja "{% endif %}") "
")
      (state "present")))
  (sysnews__entries (list))
  (sysnews__group_entries (list))
  (sysnews__host_entries (list))
  (sysnews__combined_entries (jinja "{{ sysnews__default_entries
                               + sysnews__entries
                               + sysnews__group_entries
                               + sysnews__host_entries }}")))
