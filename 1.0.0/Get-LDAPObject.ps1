
Function Get-LDAPObject
{
	Param (
		[parameter(Mandatory = $false)]
		[String]#LDAP server name
		#Default: closest DC
		$LdapServer = [String]::Empty,
        
        [parameter(Mandatory = $true)]
		[string]$SearchBase,

        [parameter(Mandatory = $true)]
		[string]$LDAPFilter,

        [parameter(Mandatory = $false)]
		[string[]]$Attributes = $null,

        [parameter(Mandatory = $false)]
        [ValidateSet("Base", "OneLevel", "Subtree")] 
		[string[]]$Scope = "OneLevel",


		[parameter(Mandatory = $false)]
		[Int32]#LDAP server port#Default: 389
		$Port = 389
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
			
									
			#$propDef = @{ "configurationNamingContext" = @(); "schemaNamingContext" = @(); "namingContexts" = @() }
            $theEntries = @{}
            if($Attributes -ne $null)
            {
                $propDef = [string[]] $Attributes
            }


			#build request
			$rq = new-object System.DirectoryServices.Protocols.SearchRequest

            #LDAP_SERVER_SD_FLAGS_OID for LDAP control  . needed to read ntSecurityDescriptor  https://msdn.microsoft.com/en-us/library/windows/desktop/aa366987(v=vs.85).aspx
            #$OIDVal = [byte[]] @( 0x30, 0x03, 0x02, 0x01, 0x04 )
            #$editSDOid = New-Object System.DirectoryServices.Protocols.DirectoryControl("1.2.840.113556.1.4.801", $OIDVal, $false, $true)
            #$rq.Controls.Add($editSDOid) | Out-Null

			$rq.DistinguishedName = $SearchBase
			$rq.Filter = $LDAPFilter
			$rq.Scope = $Scope
            if($Attributes -ne $null)
            {
			    $rq.Attributes.AddRange($Attributes) | Out-Null
            }
			
            $rq.TimeLimit = New-Object System.TimeSpan(1,0,4);
			$rsp = $global:LdapConnection.SendRequest($rq)
    
            if($rsp.Entries.Count -eq 0)
            {
                return $null
            }

            foreach($ent in $rsp.Entries)
            {
                $theAttribs = @{}
                $totalAtts = 0
                $totalAtts = $ent.Attributes.Count
                $atKeys = $null
                $atKeys = $ent.Attributes.Keys

                foreach($atttt in $atKeys)
                {
                    try
                    {
                        
                        $attType = $ent.Attributes[$atttt][0].GetType()
                        if($attType.Name -eq "String")
                        {
                            $eeeeeeee = $ent.Attributes[$atttt].GetValues([string])
                            $theAttribs.Add($atttt, $eeeeeeee)
                            if($atttt -eq "url")
                            {
                                echo " "
                            }
                        }
                        else
                        {
                            $eeeeeeee = $ent.Attributes[$atttt].GetValues([byte[]])
                            $theAttribs.Add($atttt, $eeeeeeee)
                        }
                    }
                    catch
                    {
                        Write-Error $Error[0]
                    }
                }
                $theEntries.Add($ent.distinguishedName, $theAttribs)
                $eee = $ent
            }


            return $theEntries



		}
		catch
		{
			Write-Error $Error[0]
			return $false
		}
		
	}
}

