(playbook "kubespray/test-infra/image-builder/cluster.yml"
    (play
    (name "Build kubevirt images")
    (hosts "image-builder")
    (gather_facts "false")
    (roles
      "kubevirt-images")))
