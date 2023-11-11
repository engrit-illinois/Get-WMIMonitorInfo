# Get-WMIMonitorInfo

Mostly made this for convenience, and also because examples on the internet either used the dated `Get-WMIObject` cmdlet, didn't output the results as a PowerShell object, or were lost due to being hosted on Microsoft TechNet. Hate that I'm basically reinventing a wheel, but it is what it is.

This module makes use of `JoinModule`, the source for which can be found here: https://github.com/iRon7/Join-Object

## Examples

Queries and returns the monitor info from target computer `EH-406B8-01` 
```powershell
Get-WMIMonitorInfo -ComputerName EH-406B8-01
```

## Parameters
```powershell
-ComputerName
```
Accepts a string for a target computer to query.

## Sources
* https://support.moonpoint.com/os/windows/PowerShell/monitor_mfg.php
* https://community.spiceworks.com/topic/321045-is-there-any-way-to-determine-the-monitor-size-attached-to-a-computer