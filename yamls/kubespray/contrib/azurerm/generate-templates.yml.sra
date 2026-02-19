(playbook "kubespray/contrib/azurerm/generate-templates.yml"
    (play
    (name "Generate Azure templates")
    (hosts "localhost")
    (gather_facts "false")
    (roles
      "generate-templates")))
