Function New-LDAPObject
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
		[string]$objectClass

<#

        [parameter(Mandatory = $true)]
		[string]$atributeName,

        [parameter(Mandatory = $true)]
		[string[]]$Value,

		[parameter(Mandatory = $false)]
		[System.DirectoryServices.Protocols.LdapConnection]#existing LDAPConnection object.
		#When we perform many searches, it is more effective to use the same conbnection rather than create new connection for each search request.
		#Default: $null, which means that connection is created automatically using information in LdapServer and Port parameters

		$global:LdapConnection = $null #>
		
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

            # only works of the class has no mandatory attribs, other than the RDN
			$rq = new-object System.DirectoryServices.Protocols.AddRequest($obDN, $objectClass)

            $rsp = $global:LdapConnection.SendRequest($rq)


            return $rq.DistinguishedName

		}
		catch
		{
            if($_.Exception.Message -like "*The object exists*")
            {
                return "ObjectExists"
            }
			Write-Error $Error[0]
			return $false
		}
		
	}
}

