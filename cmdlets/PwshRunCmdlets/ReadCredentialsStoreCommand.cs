﻿using PwshRunCmdlets.CredentialsStore;
using System;
using System.Management.Automation;
using System.Runtime.InteropServices;

namespace PwshRunCmdlets
{
    [Cmdlet(VerbsCommunications.Read, "CredentialsStore")]
    public class ReadCredentialsStoreCommand : Cmdlet
    {
        // Declare the parameters for the cmdlet.
        [Parameter(Mandatory = true, Position = 0)]
        public string Target { get; set; }

        [Parameter(Mandatory = false)]
        public string Type { get; set; } = nameof(CredUI.CredentialType.Generic);

        public ReadCredentialsStoreCommand()
        {
        }

        protected override void ProcessRecord()
        {
            IntPtr credPtr;
            var type = (CredUI.CredentialType)Enum.Parse(typeof(CredUI.CredentialType), Type);

            // Make the API call using the P/Invoke signature
            if (!CredUI.CredRead(Target, type, 0, out credPtr))
            {
                var lastError = Marshal.GetLastWin32Error();
                if (lastError == (int)CredUI.CredentialUIReturnCodes.NotFound)
                {
                    WriteObject(null);
                    return;
                }
                else
                {
                    throw new Exception($"'CredRead' call threw an error (Error code: {lastError})");
                }
            }

            using (var critCred = new CredentialHandle(credPtr))
            {
                WriteObject(critCred.GetCredential());
            }
        }
    }
}
