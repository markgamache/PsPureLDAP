Function Update-LDAPSD
{
    Param (
		
        [parameter(Mandatory = $true)]
		[byte[]]$CurrentSD
		
	)
	Add-Type -AssemblyName "System.DirectoryServices.Protocols"
    
    $ads = New-Object System.DirectoryServices.ActiveDirectorySecurity
    $ads.SetSecurityDescriptorBinaryForm($CurrentSD)

    ##auth'd users
    # apply GPO guid edacfd8f-ffb3-11d1-b41d-00a0c968f939
    $AppGuid = [guid]::Parse("edacfd8f-ffb3-11d1-b41d-00a0c968f939")
    $AuthdUsers = New-Object System.Security.Principal.SecurityIdentifier( "S-1-5-11")
    $adCompsAceX =  New-Object System.DirectoryServices.ActiveDirectoryAccessRule ($AuthdUsers, "ExtendedRight", "Allow",$AppGuid )

    $ads.AddAccessRule($adCompsAceX)

    $theOutSD =  $ads.GetSecurityDescriptorBinaryForm()

    return $theOutSD

}