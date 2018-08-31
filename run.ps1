[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)]$Remaining
)
DynamicParam {
    $ParameterName = 'Command'
    $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

    $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
    $ParameterAttribute.Mandatory = $true
    #$ParameterAttribute.Position = 1

    # Add the attributes to the attributes collection
    $AttributeCollection.Add($ParameterAttribute)
 
    # Generate and set the ValidateSet
    $arrSet = @("uno", "dos", "tres", "go")
    $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

    # Add the ValidateSet to the attributes collection
    $AttributeCollection.Add($ValidateSetAttribute)

    # Create and return the dynamic parameter
    $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
    $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
    return $RuntimeParameterDictionary
}

Process {
    . "./cmd-go.ps1"

    $cmdMap = @{
        "go" = "CmdGo";
    }

    function TestFunction {
        param(
            [string] $a,
            [string] $b = "bar"
        )

        Write-Host "Function has been called with $a and $b"
    }

    function DynamicCall {
        param(
            [string] $cmd,
            [object[]] $cmdArgs = @()
        )

        $mappedArgs = $cmdArgs | %{ "`"$_`""}
        Invoke-Expression "$cmd $mappedArgs"
    }

    Write-Output "Args: $args"

    #TestFunction "foo"
    $cmd = "TestFunction"
    $cmdArgs = @("eins", "zw ei", "drei")

    DynamicCall $cmd $cmdArgs

    $first, $rest = $Remaining
    Write-Host $rest

    DynamicCall $cmdMap[$first] $rest
}
