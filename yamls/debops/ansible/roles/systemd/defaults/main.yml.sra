(playbook "debops/ansible/roles/systemd/defaults/main.yml"
  (systemd__enabled (jinja "{{ True
                      if (ansible_service_mgr == \"systemd\")
                      else False }}"))
  (systemd__deploy_state "absent")
  (systemd__version (jinja "{{ ansible_local.systemd.version | d(\"0\") }}"))
  (systemd__default_configuration (list
      
      (name "LogLevel")
      (value "info")
      (state "init")
      
      (name "LogTarget")
      (value "journal-or-kmsg")
      (state "init")
      
      (name "LogColor")
      (value "True")
      (state "init")
      
      (name "LogLocation")
      (value "False")
      (state "init")
      
      (name "LogTime")
      (value "False")
      (state "init")
      
      (name "DumpCore")
      (value "True")
      (state "init")
      
      (name "ShowStatus")
      (value "True")
      (state "init")
      
      (name "CrashChangeVT")
      (value "False")
      (state "init")
      
      (name "CrashShell")
      (value "False")
      (state "init")
      
      (name "CrashReboot")
      (value "False")
      (state "init")
      
      (name "CtrlAltDelBurstAction")
      (value "reboot-force")
      (state "init")
      
      (name "CPUAffinity")
      (value "1 2")
      (state "init")
      
      (name "NUMAPolicy")
      (value "default")
      (state "init")
      
      (name "NUMAMask")
      (value "")
      (state "init")
      
      (name "RuntimeWatchdogSec")
      (value "0")
      (state "init")
      
      (name "RebootWatchdogSec")
      (value "10min")
      (state "init")
      
      (name "ShutdownWatchdogSec")
      (value "10min")
      (state "init")
      
      (name "KExecWatchdogSec")
      (value "0")
      (state "init")
      
      (name "WatchdogDevice")
      (value "")
      (state "init")
      
      (name "CapabilityBoundingSet")
      (value "")
      (state "init")
      
      (name "NoNewPrivileges")
      (value "False")
      (state "init")
      
      (name "SystemCallArchitectures")
      (value "")
      (state "init")
      
      (name "TimerSlackNSec")
      (value "")
      (state "init")
      
      (name "StatusUnitFormat")
      (value "description")
      (state "init")
      
      (name "DefaultTimerAccuracySec")
      (value "1min")
      (state "init")
      
      (name "DefaultStandardOutput")
      (value "journal")
      (state "init")
      
      (name "DefaultStandardError")
      (value "inherit")
      (state "init")
      
      (name "DefaultTimeoutStartSec")
      (value "90s")
      (state "init")
      
      (name "DefaultTimeoutStopSec")
      (value "90s")
      (state "init")
      
      (name "DefaultTimeoutAbortSec")
      (value "")
      (state "init")
      
      (name "DefaultRestartSec")
      (value "100ms")
      (state "init")
      
      (name "DefaultStartLimitIntervalSec")
      (value "10s")
      (state "init")
      
      (name "DefaultStartLimitBurst")
      (value "5")
      (state "init")
      
      (name "DefaultEnvironment")
      (value "")
      (state "init")
      
      (name "DefaultCPUAccounting")
      (value "False")
      (state "init")
      
      (name "DefaultIOAccounting")
      (value "False")
      (state "init")
      
      (name "DefaultIPAccounting")
      (value "False")
      (state "init")
      
      (name "DefaultBlockIOAccounting")
      (value "False")
      (state "init")
      
      (name "DefaultMemoryAccounting")
      (value "True")
      (state "init")
      
      (name "DefaultTasksAccounting")
      (value "True")
      (state "init")
      
      (name "DefaultTasksMax")
      (value "15%")
      (state "init")
      
      (name "DefaultLimitCPU")
      (value "")
      (state "init")
      
      (name "DefaultLimitFSIZE")
      (value "")
      (state "init")
      
      (name "DefaultLimitDATA")
      (value "")
      (state "init")
      
      (name "DefaultLimitSTACK")
      (value "")
      (state "init")
      
      (name "DefaultLimitCORE")
      (value "")
      (state "init")
      
      (name "DefaultLimitRSS")
      (value "")
      (state "init")
      
      (name "DefaultLimitNOFILE")
      (value "1024:524288")
      (state "init")
      
      (name "DefaultLimitAS")
      (value "")
      (state "init")
      
      (name "DefaultLimitNPROC")
      (value "")
      (state "init")
      
      (name "DefaultLimitMEMLOCK")
      (value "")
      (state "init")
      
      (name "DefaultLimitLOCKS")
      (value "")
      (state "init")
      
      (name "DefaultLimitSIGPENDING")
      (value "")
      (state "init")
      
      (name "DefaultLimitMSGQUEUE")
      (value "")
      (state "init")
      
      (name "DefaultLimitNICE")
      (value "")
      (state "init")
      
      (name "DefaultLimitRTPRIO")
      (value "")
      (state "init")
      
      (name "DefaultLimitRTTIME")
      (value "")
      (state "init")))
  (systemd__configuration (list))
  (systemd__group_configuration (list))
  (systemd__host_configuration (list))
  (systemd__combined_configuration (jinja "{{ systemd__default_configuration
                                     + systemd__configuration
                                     + systemd__group_configuration
                                     + systemd__host_configuration }}"))
  (systemd__user_default_configuration (list
      
      (name "LogLevel")
      (value "info")
      (state "init")
      
      (name "LogTarget")
      (value "console")
      (state "init")
      
      (name "LogColor")
      (value "True")
      (state "init")
      
      (name "LogLocation")
      (value "False")
      (state "init")
      
      (name "LogTime")
      (value "False")
      (state "init")
      
      (name "SystemCallArchitectures")
      (value "")
      (state "init")
      
      (name "TimerSlackNSec")
      (value "")
      (state "init")
      
      (name "StatusUnitFormat")
      (value "description")
      (state "init")
      
      (name "DefaultTimerAccuracySec")
      (value "1min")
      (state "init")
      
      (name "DefaultStandardOutput")
      (value "inherit")
      (state "init")
      
      (name "DefaultStandardError")
      (value "inherit")
      (state "init")
      
      (name "DefaultTimeoutStartSec")
      (value "90s")
      (state "init")
      
      (name "DefaultTimeoutStopSec")
      (value "90s")
      (state "init")
      
      (name "DefaultTimeoutAbortSec")
      (value "")
      (state "init")
      
      (name "DefaultRestartSec")
      (value "100ms")
      (state "init")
      
      (name "DefaultStartLimitIntervalSec")
      (value "10s")
      (state "init")
      
      (name "DefaultStartLimitBurst")
      (value "5")
      (state "init")
      
      (name "DefaultEnvironment")
      (value "")
      (state "init")
      
      (name "DefaultLimitCPU")
      (value "")
      (state "init")
      
      (name "DefaultLimitFSIZE")
      (value "")
      (state "init")
      
      (name "DefaultLimitDATA")
      (value "")
      (state "init")
      
      (name "DefaultLimitSTACK")
      (value "")
      (state "init")
      
      (name "DefaultLimitCORE")
      (value "")
      (state "init")
      
      (name "DefaultLimitRSS")
      (value "")
      (state "init")
      
      (name "DefaultLimitNOFILE")
      (value "")
      (state "init")
      
      (name "DefaultLimitAS")
      (value "")
      (state "init")
      
      (name "DefaultLimitNPROC")
      (value "")
      (state "init")
      
      (name "DefaultLimitMEMLOCK")
      (value "")
      (state "init")
      
      (name "DefaultLimitLOCKS")
      (value "")
      (state "init")
      
      (name "DefaultLimitSIGPENDING")
      (value "")
      (state "init")
      
      (name "DefaultLimitMSGQUEUE")
      (value "")
      (state "init")
      
      (name "DefaultLimitNICE")
      (value "")
      (state "init")
      
      (name "DefaultLimitRTPRIO")
      (value "")
      (state "init")
      
      (name "DefaultLimitRTTIME")
      (value "")
      (state "init")))
  (systemd__user_configuration (list))
  (systemd__user_group_configuration (list))
  (systemd__user_host_configuration (list))
  (systemd__user_combined_configuration (jinja "{{ systemd__user_default_configuration
                                          + systemd__user_configuration
                                          + systemd__user_group_configuration
                                          + systemd__user_host_configuration }}"))
  (systemd__logind_default_configuration (list
      
      (name "NAutoVTs")
      (value "6")
      (state "init")
      
      (name "ReserveVT")
      (value "6")
      (state "init")
      
      (name "KillUserProcesses")
      (value "False")
      (state "init")
      
      (name "KillOnlyUsers")
      (value (list))
      (state "init")
      
      (name "KillExcludeUsers")
      (value (list
          "root"))
      (state "init")
      
      (name "InhibitDelayMaxSec")
      (value "5")
      (state "init")
      
      (name "UserStopDelaySec")
      (value "10")
      (state "init")
      
      (name "HandlePowerKey")
      (value "poweroff")
      (state "init")
      
      (name "HandleSuspendKey")
      (value "suspend")
      (state "init")
      
      (name "HandleHibernateKey")
      (value "hibernate")
      (state "init")
      
      (name "HandleLidSwitch")
      (value "suspend")
      (state "init")
      
      (name "HandleLidSwitchExternalPower")
      (value "suspend")
      (state "init")
      
      (name "HandleLidSwitchDocked")
      (value "ignore")
      (state "init")
      
      (name "HandleRebootKey")
      (value "reboot")
      (state "init")
      
      (name "PowerKeyIgnoreInhibited")
      (value "False")
      (state "init")
      
      (name "SuspendKeyIgnoreInhibited")
      (value "False")
      (state "init")
      
      (name "HibernateKeyIgnoreInhibited")
      (value "False")
      (state "init")
      
      (name "LidSwitchIgnoreInhibited")
      (value "True")
      (state "init")
      
      (name "RebootKeyIgnoreInhibited")
      (value "False")
      (state "init")
      
      (name "HoldoffTimeoutSec")
      (value "30s")
      (state "init")
      
      (name "IdleAction")
      (value "ignore")
      (state "init")
      
      (name "IdleActionSec")
      (value "30min")
      (state "init")
      
      (name "RuntimeDirectorySize")
      (value "10%")
      (state "init")
      
      (name "RuntimeDirectoryInodes")
      (value "400k")
      (state "init")
      
      (name "RemoveIPC")
      (value "True")
      (state "init")
      
      (name "InhibitorsMax")
      (value "8192")
      (state "init")
      
      (name "SessionsMax")
      (value "8192")
      (state "init")))
  (systemd__logind_configuration (list))
  (systemd__logind_group_configuration (list))
  (systemd__logind_host_configuration (list))
  (systemd__logind_combined_configuration (jinja "{{ systemd__logind_default_configuration
                                            + systemd__logind_configuration
                                            + systemd__logind_group_configuration
                                            + systemd__logind_host_configuration }}"))
  (systemd__units (list))
  (systemd__group_units (list))
  (systemd__host_units (list))
  (systemd__dependent_units (list))
  (systemd__combined_units (jinja "{{ systemd__dependent_units
                             + systemd__units
                             + systemd__group_units
                             + systemd__host_units }}"))
  (systemd__user_units (list))
  (systemd__user_group_units (list))
  (systemd__user_host_units (list))
  (systemd__user_dependent_units (list))
  (systemd__user_combined_units (jinja "{{ systemd__user_dependent_units
                                  + systemd__user_units
                                  + systemd__user_group_units
                                  + systemd__user_host_units }}")))
