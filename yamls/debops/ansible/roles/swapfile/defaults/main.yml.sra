(playbook "debops/ansible/roles/swapfile/defaults/main.yml"
  (swapfile__size (jinja "{{ ((ansible_memtotal_mb | int * 2)
                     if (ansible_memtotal_mb | int <= 2048)
                     else \"512\") }}"))
  (swapfile__priority "-1")
  (swapfile__use_dd "False")
  (swapfile__files (list
      "/swapfile")))
