# ansible-flatten

Ansible YAML+Jinja2 flattened to greppable text. Every `.yml` file has a `.yml.txt` beside it.

## What's here

2,383 files across 14 public Ansible repos, flattened to 86,811 greppable paths.

| Repo | Files | Paths | Jinja2 |
|------|-------|-------|--------|
| ansible-examples | 150 | 2,035 | 327 |
| ansible-for-devops | 119 | 1,968 | 197 |
| awx | 122 | 7,791 | 1,632 |
| debops | 1,191 | 52,719 | 12,076 |
| kubespray | 564 | 16,448 | 3,998 |
| sovereign | 65 | 1,216 | 213 |
| + others | 172 | 4,634 | 1,202 |
| **total** | **2,383** | **86,811** | **19,645** |

Files skipped: **0**

Parsed with a custom script.

## Why

This started as an attempt to create round-trip YAML tests — parse Ansible YAML, flatten it, verify the structure. No current tool could do it. Every standard YAML parser chokes on Jinja2 template expressions (`{{ }}`). Security scanners silently skip files they can't parse.

Once the round-trip worked, the whole structure became visible — and things fell out that you'd never notice reading individual files.  The flattened tree adds structure on top — you can see where in the tree a password lives, which task runs a shell command, what module disables TLS. Structure, not just matches. The files most likely to contain hardcoded credentials — the ones with dynamic templates — are exactly the ones scanners never see.

This repo makes those files visible. Every path. Every value. Every Jinja2 expression. Greppable with standard Unix tools.

## Usage

```bash
# Clone and grep
git clone https://github.com/johnagrillo62/yaml-flattened.git
cd yaml-flattened

# Find hardcoded passwords across all repos
grep -ri password **/*.txt

# Find shell commands
grep '\.shell ' **/*.txt

# Find all Jinja2 expressions
grep '{{.*}}' **/*.txt

# Find shell commands with templated values
grep '\.shell.*{{' **/*.txt
```

## Format

Each `.yml.txt` contains one path per line:

```
[0].hosts = webservers
[0].become = yes
[0].tasks[0].name = Install nginx
[0].tasks[0].apt.name = nginx
[0].tasks[0].apt.state = present
[0].tasks[1].name = Copy config
[0].tasks[1].template.src = {{ app_config }}.j2
[0].tasks[1].template.dest = /etc/app/{{ app_name }}.conf
```

The original YAML structure is encoded in the dot path. Array indices are `[N]`. Jinja2 expressions are preserved in the values.

## What scanners miss

Security scanners skip files with Jinja2 template expressions because no standard YAML parser can handle `{{ }}`. This is a known limitation across Checkov, KICS, ansible-lint, and other tools. Tools built with experimental Jinja2 evaluators still fail on nested expressions, multiline templates, and dynamic content.

The files with the most Jinja2 are the most security-critical — they contain dynamic credentials, templated shell commands, and interpolated secrets. These are exactly the files scanners exist to check, and exactly the files they can't see.

## Source repos

- [ansible/ansible-examples](https://github.com/ansible/ansible-examples)
- [geerlingguy/ansible-for-devops](https://github.com/geerlingguy/ansible-for-devops)
- [ansible/awx](https://github.com/ansible/awx)
- [debops/debops](https://github.com/debops/debops)
- [kubernetes-sigs/kubespray](https://github.com/kubernetes-sigs/kubespray)
- [sovereign/sovereign](https://github.com/sovereign/sovereign)
- [openshift/openshift-ansible](https://github.com/openshift/openshift-ansible)
- [sensu/sensu-ansible](https://github.com/sensu/sensu-ansible)
- [galaxyproject/ansible-galaxy](https://github.com/galaxyproject/ansible-galaxy)
- [openstack/openstack-ansible](https://github.com/openstack/openstack-ansible)
- [streisand-vpn/streisand](https://github.com/streisand-vpn/streisand)
- [algo-vpn/algo](https://github.com/algo-vpn/algo)
- [leucos/ansible-tuto](https://github.com/leucos/ansible-tuto)

## Tool

Tool set created with AI-powered scanners. Coming soon.
