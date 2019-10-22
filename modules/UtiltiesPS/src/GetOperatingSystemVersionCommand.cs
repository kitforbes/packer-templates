using System;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using Microsoft.PowerShell.Commands;

namespace UtiltiesPS
{
    [Cmdlet(VerbsDiagnostic.Get, "OperatingSystemVersionCommand")]
    [OutputType(typeof(string))]
    public class GetOperatingSystemVersionCommand : PSCmdlet
    {
        [Parameter(
            Mandatory = false)]
        public SwitchParameter DisplayName { get; set; }

        protected override void BeginProcessing()
        {
            WriteVerbose("Begin");
        }

        protected override void ProcessRecord()
        {
            WriteVerbose("Process");
            GetCommandCommand()

            if (DisplayName)
            {
                var lookupTable = new Dictionary<string, string>();
                lookupTable.Add("5.1.2600", "Windows XP");
                lookupTable.Add("5.1.3790", "Windows Server 2003");
                lookupTable.Add("6.0.6001", "Windows Vista/Windows Server 2008");
                lookupTable.Add("6.1.7600", "Windows 7/Windows Server 2008 R2");
                lookupTable.Add("6.1.7601", "Windows 7 SP1/Windows Server 2008 R2 SP1");
                lookupTable.Add("6.2.9200", "Windows 8/Windows Server 2012");
                lookupTable.Add("6.3.9600", "Windows Server 8.1/Windows Server 2012 R2");
                lookupTable.Add("10.0.*", "Windows 10/Windows Server 2016");
            }

            // var version = (Get-CimInstance -ClassName Win32_OperatingSystem).Version
            var name = (from x in new ManagementObjectSearcher("SELECT Caption FROM Win32_OperatingSystem").Get().Cast<ManagementObject>()
                        select x.GetPropertyValue("Caption")).FirstOrDefault();
            return name != null ? name.ToString() : "Unknown";

            if (version.Split(".")[0] == "10")
            {
                return lookupTable["10.0.*"]
            }

            return lookupTable[version]
        }
        else {
            if (Test-Command -Name Get -CimInstance) {
                return (Get-CimInstance -ClassName Win32_OperatingSystem).Version
    }
            else {
                throw
            }
            }
        }

        protected override void EndProcessing()
{
    WriteVerbose("End");
}
    }
}
