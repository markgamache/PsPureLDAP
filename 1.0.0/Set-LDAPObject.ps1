Function Set-LDAPObject
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
		[string[]]$Value
		
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
            #  
			$rq = new-object System.DirectoryServices.Protocols.ModifyRequest($obDN, $Operation, $atributeName, $Value)

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