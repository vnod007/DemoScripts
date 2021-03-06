#Code for creating the storage controller class
#region Create WMI Class
Function CreateWMIClass{
    #CIMTYPE Enum:http://msdn.microsoft.com/en-us/library/system.management.cimtype.aspx
    $newClass = New-Object System.Management.ManagementClass `
        ("root\cimv2\Dell", [String]::Empty, $null); 

    $newClass["__CLASS"] = "DellCustom_VDiskController0"; 

    $newClass.Qualifiers.Add("Static", $true)
    $newClass.Properties.Add("ID", [System.Management.CimType]::String, $false)
    $newClass.Properties["ID"].Qualifiers.Add("Key", $true)
    $newClass.Properties.Add("Bus_Protocol", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("Cache_Policy", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("Device_Name", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("Disk_Cache_Policy", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("Encrypted", [System.Management.CimType]::String, $false)
    #$newClass.Properties.Add("ID", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("Layout", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("Media", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("Name", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("Read_Policy", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("Size", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("State", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("Status", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("Stripe_Element_Size", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("Write_Policy", [System.Management.CimType]::String, $false)
    $newClass.Put()
}

#see if the class already exists, prepare for insert
#region
if ((get-wmiobject -namespace root\cimv2\dell -list | 
    where-object {$_.Name -eq "DellCustom_VDiskController0"} | 
        Measure).count -ge 1) 
{
    #delete all instances
    get-wmiobject DellCustom_VDiskController0 -namespace root\cimv2\dell | 
        foreach  {
            $_.Delete()
        }
}
else
{
    #create wmi class
    $retval = CreateWMIClass

}
#endregion

#region Query and populate WMI
Try {
$colStorage = ConvertFrom-Csv -inputobject `
    ((omreport storage vdisk controller=0 -fmt ssv)[4..500]) -delimiter ";"
}
catch {
    "Failure running omreport"
}
$colStorage | foreach {
   $onull =  Set-WMIInstance -class DellCustom_VDiskController0 `
    -namespace root\cimv2\dell -argument @{
    Bus_Protocol = $_."Bus Protocol"
    Cache_Policy = $_."Cache Policy"
    Device_Name = $_."Device Name"
    Disk_Cache_Policy = $_."Disk Cache Policy"
    Encrypted = $_."Encrypted"
    ID = $_."ID"
    Layout = $_."Layout"
    Media = $_."Media"
    Name = $_."Name"
    Read_Policy = $_."Read Policy"
    Size = $_."Size"
    State = $_."State"
    Status = $_."Status"
    Stripe_Element_Size = $_."Stripe Element Size"
    Write_Policy = $_."Write Policy"

    }
}

#endregion