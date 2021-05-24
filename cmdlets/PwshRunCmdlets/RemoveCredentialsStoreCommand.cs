using PwshRunCmdlets.CredentialsStore;
using System;
using System.Management.Automation;
using System.Runtime.InteropServices;

namespace PwshRunCmdlets
{
    [Cmdlet(VerbsCommon.Remove, "CredentialsStore")]
    public class RemoveCredentialsStoreCommand : Cmdlet
    {
        // Declare the parameters for the cmdlet.
        [Parameter(Mandatory = true, Position = 0)]
        public string Target { get; set; }

        [Parameter(Mandatory = false)]
        public string Type { get; set; } = nameof(CredUI.CredentialType.Generic);

        public RemoveCredentialsStoreCommand()
        {
        }

        protected override void ProcessRecord()
        {
            var type = (CredUI.CredentialType)Enum.Parse(typeof(CredUI.CredentialType), Type);
            if (CredUI.CredDelete(Target, type, 0))
            {
                WriteObject(Target);
            }
            else
            {
                int lastError = Marshal.GetLastWin32Error();
                if (lastError == (int)CredUI.CredentialUIReturnCodes.NotFound)
                {
                    WriteObject(null);
                }
                else
                {
                    throw new Exception($"'CredDelete' call threw an error (Error code: {lastError})");
                }
            }
        }
    }
}
