(playbook "debops/ansible/roles/fail2ban/defaults/main.yml"
  (fail2ban_loglevel "WARNING")
  (fail2ban_logtarget "/var/log/fail2ban.log")
  (fail2ban_dbpurgeage (jinja "{{ (60 * 60 * 24) }}"))
  (fail2ban_ignoreip (list))
  (fail2ban_group_ignoreip (list))
  (fail2ban_host_ignoreip (list))
  (fail2ban_ignoreip_default (list
      "127.0.0.0/8"))
  (fail2ban_findtime (jinja "{{ (60 * 10) }}"))
  (fail2ban_maxretry "3")
  (fail2ban_bantime (jinja "{{ (60 * 60 * 2) }}"))
  (fail2ban_backend "auto")
  (fail2ban_mta "sendmail")
  (fail2ban_destemail "root@" (jinja "{{ ansible_domain }}"))
  (fail2ban_banaction "iptables-xt_recent-echo-reject")
  (fail2ban_protocol "tcp")
  (fail2ban_chain "INPUT")
  (fail2ban_position "6")
  (fail2ban_bantime_distribution_map 
    (focal "7200"))
  (fail2ban_action "action_")
  (fail2ban_action_distribution_map 
    (focal "%(banaction)s[name=%(__name__)s, port=\"%(port)s\", protocol=\"%(protocol)s\", chain=\"%(chain)s\", position=\"%(position)s\"]"))
  (fail2ban_default_actions 
    (action_ (jinja "{{ fail2ban_action_distribution_map[ansible_distribution_release]
if ansible_distribution_release in fail2ban_action_distribution_map.keys()
else '%(banaction)s[name=%(__name__)s, port=\"%(port)s\", protocol=\"%(protocol)s\", chain=\"%(chain)s\", position=\"%(position)s\", bantime=\"%(bantime)s\"]' }}") "
")
    (action_mw (jinja "{{ fail2ban_action_distribution_map[ansible_distribution_release]
if ansible_distribution_release in fail2ban_action_distribution_map.keys()
else '%(banaction)s[name=%(__name__)s, port=\"%(port)s\", protocol=\"%(protocol)s\", chain=\"%(chain)s\", position=\"%(position)s\", bantime=\"%(bantime)s\"]' }}") "
%(mta)s-whois[name=%(__name__)s, dest=\"%(destemail)s\", protocol=\"%(protocol)s\", chain=\"%(chain)s\"]
")
    (action_mwl (jinja "{{ fail2ban_action_distribution_map[ansible_distribution_release]
if ansible_distribution_release in fail2ban_action_distribution_map.keys()
else '%(banaction)s[name=%(__name__)s, port=\"%(port)s\", protocol=\"%(protocol)s\", chain=\"%(chain)s\", position=\"%(position)s\", bantime=\"%(bantime)s\"]' }}") "
%(mta)s-whois-lines[name=%(__name__)s, dest=\"%(destemail)s\", logpath=%(logpath)s, chain=\"%(chain)s\"]
"))
  (fail2ban_custom_actions )
  (fail2ban_actions (list))
  (fail2ban_filters (list))
  (fail2ban_usedns "warn")
  (fail2ban_jails (list
      
      (name (jinja "{{ fail2ban_ssh_jail_name }}"))
      (enabled "true")))
  (fail2ban_ssh_jail_name (jinja "{{ fail2ban_ssh_jail_distribution_map[ansible_distribution_release]
                            if ansible_distribution_release in fail2ban_ssh_jail_distribution_map.keys()
                            else \"sshd\" }}"))
  (fail2ban_ssh_jail_distribution_map 
    (trusty "ssh"))
  (fail2ban_group_jails (list))
  (fail2ban_host_jails (list))
  (fail2ban_dependent_jails (list)))
