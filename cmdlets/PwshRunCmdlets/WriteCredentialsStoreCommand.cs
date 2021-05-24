using PwshRunCmdlets.CredentialsStore;
using System;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Security;
using System.Text;

namespace PwshRunCmdlets
{
    [Cmdlet(VerbsCommunications.Write, "CredentialsStore")]
    public class WriteCredentialsStoreCommand : Cmdlet
    {
        // Declare the parameters for the cmdlet.
        [Parameter(Mandatory = true, Position = 0)]
        public string Target { get; set; }

        [Parameter(Mandatory = true, Position = 1)]
        public PSCredential Credential { get; set; }

        [Parameter(Mandatory = false)]
        public string Type { get; set; } = nameof(CredUI.CredentialType.Generic);

        public WriteCredentialsStoreCommand()
        {
        }

        protected override void ProcessRecord()
        {
            var type = (CredUI.CredentialType)Enum.Parse(typeof(CredUI.CredentialType), Type);
            var password = SecureStringToString(Credential.Password);

            var nowTime = DateTime.Now.ToFileTimeUtc();
            var lastWritten = new System.Runtime.InteropServices.ComTypes.FILETIME();
            lastWritten.dwLowDateTime = (int)(nowTime & 0xFFFFFFFFL);
            lastWritten.dwHighDateTime = (int)((nowTime >> 32) & 0xFFFFFFFFL);

            CredUI.NativeCredential ncred = new CredUI.NativeCredential
            {
                Type = type,
                Persist = CredUI.Persistance.Entrprise,
                TargetName = this.Target,
                UserName = this.Credential.UserName,
                CredentialBlob = Marshal.StringToCoTaskMemUni(password),
                CredentialBlobSize = (UInt32)Encoding.Unicode.GetBytes(password).Length,
                LastWritten = lastWritten
            };

            if (CredUI.CredWrite(ref ncred, 0))
            {
                WriteObject(Target);
            }
            else
            {
                int lastError = Marshal.GetLastWin32Error();
                throw new Exception($"'CredWrite' call threw an error (Error code: {lastError})");
            }
        }

        private string SecureStringToString(SecureString value)
        {
            IntPtr valuePtr = IntPtr.Zero;
            try
            {
                valuePtr = Marshal.SecureStringToGlobalAllocUnicode(value);
                return Marshal.PtrToStringUni(valuePtr);
            }
            finally
            {
                Marshal.ZeroFreeGlobalAllocUnicode(valuePtr);
            }
        }
    }
}
