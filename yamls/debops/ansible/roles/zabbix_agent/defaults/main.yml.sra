(playbook "debops/ansible/roles/zabbix_agent/defaults/main.yml"
  (zabbix_agent__flavor "C")
  (zabbix_agent__deploy_state "present")
  (zabbix_agent__base_packages (jinja "{{ [\"zabbix-agent\"]
                                 if (zabbix_agent__flavor == \"C\")
                                 else [\"zabbix-agent2\"] }}"))
  (zabbix_agent__packages (list))
  (zabbix_agent__allow (list))
  (zabbix_agent__group_allow (list))
  (zabbix_agent__host_allow (list))
  (zabbix_agent__user "zabbix")
  (zabbix_agent__group "zabbix")
  (zabbix_agent__additional_groups (list
      (jinja "{{ (ansible_local.proc_hidepid.group | d(\"procadmins\"))
        if (ansible_local.proc_hidepid.enabled | d()) | bool
        else [] }}")))
  (zabbix_agent__conf_file_path (jinja "{{ \"/etc/zabbix/zabbix_agentd.conf\"
                                  if (zabbix_agent__flavor == \"C\")
                                  else \"/etc/zabbix/zabbix_agent2.conf\" }}"))
  (zabbix_agent__tls_psk_identity (jinja "{{ lookup(\"password\", secret
                                    + \"/zabbix/identities/\" + inventory_hostname
                                    + \"/identity.key length=32 chars=ascii_letters,digits\") }}"))
  (zabbix_agent__tls_psk_secret (jinja "{{ lookup(\"password\", secret
                                  + \"/zabbix/identities/\" + inventory_hostname
                                  + \"/secret.key length=64 chars=abcdef,digits\") }}"))
  (zabbix_agent__original_configuration (list
      
      (name "PidFile")
      (comment "Name of PID file.
")
      (value "/var/run/zabbix/zabbix_agentd.pid")
      (state (jinja "{{ \"present\" if (zabbix_agent__flavor == \"C\") else \"comment\" }}"))
      
      (name "LogType")
      (comment "Specifies where log messages are written to
  system  - syslog
  file    - file specified with LogFile parameter
  console - standard output
")
      (value "file")
      (state "comment")
      
      (name "LogFile")
      (comment "Log file name for LogType 'file' parameter.
Mandatory: yes, if LogType is set to file, otherwise no
")
      (value "/var/log/zabbix-agent/zabbix_agentd.log")
      (state (jinja "{{ \"present\" if (zabbix_agent__flavor == \"C\") else \"comment\" }}"))
      
      (name "LogFileSize")
      (comment "Maximum size of log file in MB.
0 - disable automatic log rotation.
Range: 0-1024
")
      (value "0")
      (state "present")
      
      (name "DebugLevel")
      (comment "Specifies debug level:
0 - basic information about starting and stopping of Zabbix processes
1 - critical information
2 - error information
3 - warnings
4 - for debugging (produces lots of information)
5 - extended debugging (produces even more information)
")
      (value "3")
      (state "comment")
      
      (name "SourceIP")
      (comment "Source IP address for outgoing connections.
")
      (value "")
      (state "comment")
      
      (name "EnableRemoteCommands")
      (comment "Whether remote commands from Zabbix server are allowed.
0 - not allowed
1 - allowed
")
      (value "0")
      (state "comment")
      
      (name "LogRemoteCommands")
      (comment "Enable logging of executed shell commands as warnings.
0 - disabled
1 - enabled
")
      (value "0")
      (state "comment")
      
      (name "Server")
      (comment "List of comma delimited IP addresses, optionally in CIDR notation, or DNS names of Zabbix servers and Zabbix proxies.
Incoming connections will be accepted only from the hosts listed here.
If IPv6 support is enabled then '127.0.0.1', '::127.0.0.1', '::ffff:127.0.0.1' are treated equally
and '::/0' will allow any IPv4 or IPv6 address.
'0.0.0.0/0' can be used to allow any IPv4 address.
Example: Server=127.0.0.1,192.168.1.0/24,::1,2001:db8::/32,zabbix.example.com
Mandatory: yes, if StartAgents is not explicitly set to 0
")
      (value "127.0.0.1")
      (state "present")
      
      (name "ListenPort")
      (comment "Agent will listen on this port for connections from the server.
Range: 1024-32767
")
      (value "10050")
      (state "comment")
      
      (name "ListenIP")
      (comment "List of comma delimited IP addresses that the agent should listen on.
First IP address is sent to Zabbix server if connecting to it to retrieve list of active checks.
")
      (value "0.0.0.0")
      (state "comment")
      
      (name "StartAgents")
      (comment "Number of pre-forked instances of zabbix_agentd that process passive checks.
If set to 0, disables passive checks and the agent will not listen on any TCP port.
Range: 0-100
")
      (value "3")
      (state "comment")
      
      (name "ServerActive")
      (comment "List of comma delimited IP:port (or DNS name:port) pairs of Zabbix servers and Zabbix proxies for active checks.'
If port is not specified, default port is used.
IPv6 addresses must be enclosed in square brackets if port for that host is specified.
If port is not specified, square brackets for IPv6 addresses are optional.
If this parameter is not specified, active checks are disabled.
Example: ServerActive=127.0.0.1:20051,zabbix.domain,[::1]:30051,::1,[12fc::1]
")
      (value "127.0.0.1")
      (state "present")
      
      (name "Hostname")
      (comment "Unique, case sensitive hostname.
Required for active checks and must match hostname as configured on the server.
Value is acquired from HostnameItem if undefined.
")
      (value "")
      (state "comment")
      
      (name "HostnameItem")
      (comment "Item used for generating Hostname if it is undefined. Ignored if Hostname is defined.
Does not support UserParameters or aliases.
")
      (value "system.hostname")
      (state "comment")
      
      (name "HostMetadata")
      (comment "Optional parameter that defines host metadata.
Host metadata is used at host auto-registration process.
An agent will issue an error and not start if the value is over limit of 255 characters.
If not defined, value will be acquired from HostMetadataItem.
Range: 0-255 characters
")
      (value "")
      (state "comment")
      
      (name "HostMetadataItem")
      (comment "Optional parameter that defines an item used for getting host metadata.
Host metadata is used at host auto-registration process.
During an auto-registration request an agent will log a warning message if
the value returned by specified item is over limit of 255 characters.
This option is only used when HostMetadata is not defined.
")
      (value "")
      (state "comment")
      
      (name "RefreshActiveChecks")
      (comment "How often list of active checks is refreshed, in seconds.
Range: 60-3600
")
      (value "120")
      (state "comment")
      
      (name "BufferSend")
      (comment "Do not keep data longer than N seconds in buffer.
Range: 1-3600
")
      (value "5")
      (state "comment")
      
      (name "BufferSize")
      (comment "Maximum number of values in a memory buffer. The agent will send
all collected data to Zabbix Server or Proxy if the buffer is full.
Range: 2-65535
")
      (value "100")
      (state "comment")
      
      (name "MaxLinesPerSecond")
      (comment "Maximum number of new lines the agent will send per second to Zabbix Server
or Proxy processing 'log' and 'logrt' active checks.
The provided value will be overridden by the parameter 'maxlines',
provided in 'log' or 'logrt' item keys.
Range: 1-1000
")
      (value "20")
      (state "comment")
      
      (name "Alias")
      (comment "Sets an alias for an item key. It can be used to substitute long and complex item key with a smaller and simpler one.
Multiple Alias parameters may be present. Multiple parameters with the same Alias key are not allowed.
Different Alias keys may reference the same item key.
For example, to retrieve the ID of user 'zabbix':
Alias=zabbix.userid:vfs.file.regexp[/etc/passwd,^zabbix:.:([0-9]+),,,,\\1]
Now shorthand key zabbix.userid may be used to retrieve data.
Aliases can be used in HostMetadataItem but not in HostnameItem parameters.
")
      (value "")
      (state "comment")
      
      (name "Timeout")
      (comment "Spend no more than Timeout seconds on processing
Range: 1-30
")
      (value "3")
      (state "comment")
      
      (name "AllowRoot")
      (comment "Allow the agent to run as 'root'. If disabled and the agent is started by 'root', the agent
will try to switch to the user specified by the User configuration option instead.
Has no effect if started under a regular user.
0 - do not allow
1 - allow
")
      (value "0")
      (state "comment")
      
      (name "User")
      (comment "Drop privileges to a specific, existing user on the system.
Only has effect if run as 'root' and AllowRoot is disabled.
")
      (value "zabbix")
      (state "comment")
      
      (name "Include")
      (comment "You may include individual files or all files in a directory in the configuration file.
Installing Zabbix will create include directory in /etc/zabbix, unless modified during the compile time.
")
      (value (jinja "{{ \"/etc/zabbix/zabbix_agentd.conf.d/*.conf\"
               if (zabbix_agent__flavor == \"C\")
               else \"/etc/zabbix/zabbix_agent2.d/*.conf\" }}"))
      (state "present")
      
      (name "UnsafeUserParameters")
      (comment "Allow all characters to be passed in arguments to user-defined parameters.
The following characters are not allowed:
\\ ' \" ` * ? [ ] { } ~ $ ! & ; ( ) < > | # @
Additionally, newline characters are not allowed.
  0 - do not allow
  1 - allow
")
      (value "0")
      (state "comment")
      
      (name "UserParameter")
      (comment "User-defined parameter to monitor. There can be several user-defined parameters.
Format: UserParameter=<key>,<shell command>
See 'zabbix_agentd' directory for examples.
")
      (value "")
      (state "comment")
      
      (name "LoadModulePath")
      (comment "Full path to location of agent modules.
Default depends on compilation options.
To see the default path run command \"zabbix_agentd --help\".
")
      (value "${libdir}/modules")
      (state "comment")
      
      (name "LoadModule")
      (comment "Module to load at agent startup. Modules are used to extend functionality of the agent.
Format: LoadModule=<module.so>
The modules must be located in directory specified by LoadModulePath.
It is allowed to include multiple LoadModule parameters.
")
      (value "")
      (state "comment")
      
      (name "TLSConnect")
      (comment "How the agent should connect to server or proxy. Used for active checks.
Only one value can be specified:
    unencrypted - connect without encryption
    psk         - connect using TLS and a pre-shared key
    cert        - connect using TLS and a certificate
Mandatory: yes, if TLS certificate or PSK parameters are defined (even for 'unencrypted' connection)
")
      (value "unencrypted")
      (state "comment")
      
      (name "TLSAccept")
      (comment "What incoming connections to accept.
Multiple values can be specified, separated by comma:
    unencrypted - accept connections without encryption
    psk         - accept connections secured with TLS and a pre-shared key
    cert        - accept connections secured with TLS and a certificate
Mandatory: yes, if TLS certificate or PSK parameters are defined (even for 'unencrypted' connection)
")
      (value "unencrypted")
      (state "comment")
      
      (name "TLSCAFile")
      (comment "Full pathname of a file containing the top-level CA(s) certificates for
peer certificate verification.
")
      (value "")
      (state "comment")
      
      (name "TLSCRLFile")
      (comment "Full pathname of a file containing revoked certificates.
")
      (value "")
      (state "comment")
      
      (name "TLSServerCertIssuer")
      (comment "Allowed server certificate issuer.
")
      (value "")
      (state "comment")
      
      (name "TLSServerCertSubject")
      (comment "Allowed server certificate subject.
")
      (value "")
      (state "comment")
      
      (name "TLSCertFile")
      (comment "Full pathname of a file containing the agent certificate or certificate chain.
")
      (value "")
      (state "comment")
      
      (name "TLSKeyFile")
      (comment "Full pathname of a file containing the agent private key.
")
      (value "")
      (state "comment")
      
      (name "TLSPSKIdentity")
      (comment "Unique, case sensitive string used to identify the pre-shared key.
")
      (value "")
      (state "comment")
      
      (name "TLSPSKFile")
      (comment "Full pathname of a file containing the pre-shared key.
")
      (value "")
      (state "comment")
      
      (name "IncludePlugins")
      (option "Include")
      (comment "Include configuration files for plugins")
      (value "./zabbix_agent2.d/plugins.d/*.conf")
      (state (jinja "{{ \"present\" if zabbix_agent__flavor == \"Go\" else \"absent\" }}"))))
  (zabbix_agent__default_configuration (list
      
      (name "TLSPSKIdentity")
      (value (jinja "{{ zabbix_agent__tls_psk_identity | d() }}"))
      (state "present")
      
      (name "TLSPSKFile")
      (value "/etc/zabbix/secret.key")
      (state "present")
      
      (name "User")
      (value (jinja "{{ zabbix_agent__user }}"))
      (state (jinja "{{ \"present\" if zabbix_agent__flavor == \"C\" else \"ignore\" }}"))
      
      (name "TLSConnect")
      (value "psk")
      (state "present")
      
      (name "TLSAccept")
      (value "psk")
      (state "present")))
  (zabbix_agent__configuration (list))
  (zabbix_agent__group_configuration (list))
  (zabbix_agent__host_configuration (list))
  (zabbix_agent__combined_configuration (jinja "{{ zabbix_agent__original_configuration
                                      + zabbix_agent__default_configuration
                                      + zabbix_agent__configuration
                                      + zabbix_agent__group_configuration
                                      + zabbix_agent__host_configuration }}"))
  (zabbix_agent__ferm__dependent_rules (list
      
      (name "zabbix_agent_allow_http")
      (type "accept")
      (dport (list
          "zabbix-agent"))
      (protocol (list
          "tcp"
          "udp"))
      (saddr (jinja "{{ zabbix_agent__allow + zabbix_agent__group_allow + zabbix_agent__host_allow }}"))
      (weight "50")
      (by_role "debops.zabbix_agent")
      (rule_state (jinja "{{ zabbix_agent__deploy_state }}"))))
  (zabbix_agent__dpkg_cleanup__dependent_packages (list
      
      (name "zabbix-agent")
      (ansible_fact "zabbix_agent")
      (revert_files (list
          "/etc/zabbix/zabbix_agentd.conf"))
      (remove_files (list
          "/etc/zabbix/secret.key"))
      (remove_directories (list
          "/etc/zabbix/zabbix_agentd.conf.d"))
      (restart_services (list
          "ferm"))
      (state (jinja "{{ \"present\" if (zabbix_agent__flavor == \"C\") else \"absent\" }}"))
      
      (name "zabbix-agent2")
      (ansible_fact "zabbix_agent")
      (revert_files (list
          "/etc/zabbix/zabbix_agent2.conf"))
      (remove_files (list
          "/etc/zabbix/secret.key"))
      (restart_services (list
          "ferm"))
      (state (jinja "{{ \"present\" if (zabbix_agent__flavor == \"Go\") else \"absent\" }}")))))
