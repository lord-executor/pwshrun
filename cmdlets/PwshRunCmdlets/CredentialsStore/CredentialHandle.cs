using Microsoft.Win32.SafeHandles;
using System;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Security;

namespace PwshRunCmdlets.CredentialsStore
{
    /// <summary>
    /// Borrowed from https://github.com/AdysTech/CredentialManager
    /// </summary>
    sealed class CredentialHandle : CriticalHandleZeroOrMinusOneIsInvalid
    {
        // Set the handle.
        internal CredentialHandle(IntPtr existingHandle)
        {
            SetHandle(existingHandle);
        }

        internal PSCredential GetCredential()
        {
            if (!IsInvalid)
            {
                // Get the Credential from the mem location
                CredUI.NativeCredential cred = (CredUI.NativeCredential)Marshal.PtrToStructure(handle, typeof(CredUI.NativeCredential));

                var password = new SecureString();
                var username = Marshal.PtrToStringUni(cred.UserName);

                if (cred.CredentialBlobSize > 2)
                {
                    var pwdStr = Marshal.PtrToStringUni(cred.CredentialBlob, (int)cred.CredentialBlobSize / 2);
                    foreach (var c in pwdStr)
                    {
                        password.AppendChar(c);
                    }
                }

                return new PSCredential(username, password);
            }
            else
            {
                throw new InvalidOperationException("Invalid CriticalHandle!");
            }
        }

        // Perform any specific actions to release the handle in the ReleaseHandle method.
        // Often, you need to use Pinvoke to make a call into the Win32 API to release the 
        // handle. In this case, however, we can use the Marshal class to release the unmanaged memory.

        override protected bool ReleaseHandle()
        {
            // If the handle was set, free it. Return success.
            if (!IsInvalid)
            {
                CredUI.CredFree(handle);
                // Mark the handle as invalid for future users.
                SetHandleAsInvalid();
                return true;
            }
            // Return false. 
            return false;
        }
    }
}
