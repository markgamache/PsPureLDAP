Function Set-LDAPObjectBin
{
	Param (
		[parameter(Mandatory = $false)]
		[String]#LDAP server name
		#Default: closest DC
		$LdapServer = [String]::Empty,

		[parameter(Mandatory = $false)]
		[Int32]#LDAP server port#Default: 389
		$Port = 389,

        [parameter(Mandatory = $true)]
		[string]$obDN,

        [parameter(Mandatory = $true)]
        [ValidateSet("Add", "Replace", "Delete")] 
		[string]$Operation,

        [parameter(Mandatory = $true)]
		[string]$AtributeName,

        [parameter(Mandatory = $true)]
		[byte[]]$Value
		
	)
	
	Process
	{
		Add-Type -AssemblyName "System.DirectoryServices.Protocols"		
		try
		{
			
            if($global:LdapConnection -eq $null)
            {
		    
			    $global:LdapConnection = new-object System.DirectoryServices.Protocols.LdapConnection(new-object System.DirectoryServices.Protocols.LdapDirectoryIdentifier($LdapServer, $Port))
			    #$global:LdapConnection.AuthType = 'Basic'
                $global:LdapConnection.AutoBind = $true
                $global:LdapConnection.Bind()
            }

            #LDAP_SERVER_SD_FLAGS_OID for LDAP control  . needed to update ntSecurityDescriptor  https://msdn.microsoft.com/en-us/library/windows/desktop/aa366987(v=vs.85).aspx
            $OIDVal = [byte[]] @( 0x30, 0x03, 0x02, 0x01, 0x04 )
            $editSDOid = New-Object System.DirectoryServices.Protocols.DirectoryControl("1.2.840.113556.1.4.801", $OIDVal, $false, $true)



            #  make a req that we will tweak.
			$rq = new-object System.DirectoryServices.Protocols.ModifyRequest($obDN, $Operation, $atributeName, $Value)
            $rq.Controls.Add($editSDOid)
                        

            $rsp = $global:LdapConnection.SendRequest($rq)


            return $true

		}
		catch
		{
			Write-Error $Error[0]
			return $false
		}
		
	}
}
