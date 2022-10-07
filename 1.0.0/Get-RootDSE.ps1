Function Get-RootDSE
{
	Param (
		[parameter(Mandatory = $false)]
		[String]#LDAP server name
		#Default: closest DC
		$LdapServer = [String]::Empty,
		[parameter(Mandatory = $false)]
		[Int32]#LDAP server port#Default: 389
		$Port = 389		
	)
	
	Process
	{
		Add-Type -AssemblyName "System.DirectoryServices.Protocols"		
		try
		{
					
			$global:LdapConnection = new-object System.DirectoryServices.Protocols.LdapConnection(new-object System.DirectoryServices.Protocols.LdapDirectoryIdentifier($LdapServer, $Port))
			$global:LdapConnection.AuthType = 'Basic'
									
			$propDef = @{ "configurationNamingContext" = @(); "schemaNamingContext" = @(); "namingContexts" = @() }

			#build request
			$rq = new-object System.DirectoryServices.Protocols.SearchRequest
			$rq.DistinguishedName = $null
			$rq.Filter = "objectclass=*"
			$rq.Scope = "Base"
			$rq.Attributes.AddRange($propDef.Keys) | Out-Null
			$rq.TimeLimit = New-Object System.TimeSpan(0,0,4);
			$rsp = $global:LdapConnection.SendRequest($rq)
			$data = new-object PSObject -Property $propDef
			$data.configurationNamingContext = (($rsp.Entries[0].Attributes["configurationNamingContext"].GetValues([string]))[0]) #.Split(';')[1];
			$data.schemaNamingContext = (($rsp.Entries[0].Attributes["schemaNamingContext"].GetValues([string]))[0]) #.Split(';')[1];
			$data.namingContexts  = ($rsp.Entries[0].Attributes["namingContexts"].GetValues([string])) #.Split(';')[2];
			$global:LdapConnection.Dispose()
			return $data


		}
		catch
		{
			Write-Error $Error[0]
			return $false
		}
		
	}
}

