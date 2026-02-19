(playbook "kubespray/contrib/azurerm/generate-inventory_2.yml"
    (play
    (name "Generate Azure inventory")
    (hosts "localhost")
    (gather_facts "false")
    (roles
      "generate-inventory_2")))
