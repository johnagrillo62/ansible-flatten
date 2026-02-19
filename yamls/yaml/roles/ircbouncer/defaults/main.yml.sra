(playbook "yaml/roles/ircbouncer/defaults/main.yml"
  (irc_timezone (jinja "{{ common_timezone|default('Etc/UTC') }}")))
