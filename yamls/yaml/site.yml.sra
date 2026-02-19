(playbook "yaml/site.yml"
    (play
    (hosts "all")
    (user "deploy")
    (become "True")
    (gather_facts "True")
    (roles
      "common"
      "mailserver"
      "webmail"
      "blog"
      "ircbouncer"
      "xmpp"
      "owncloud"
      "vpn"
      "tarsnap"
      "news"
      "git"
      "readlater"
      "monitoring")))
