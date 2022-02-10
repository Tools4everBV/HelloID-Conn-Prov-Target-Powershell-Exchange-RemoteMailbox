#Initialize default properties
$c = $configuration | ConvertFrom-Json
$p = $person | ConvertFrom-Json;
$aRef = $accountReference | ConvertFrom-Json;

$success = $False;
$auditLogs = [Collections.Generic.List[PSCustomObject]]@()

#config mapping
$exchangeConnectionUri = $c.exchange.url
$exchangeAdminUsername = $c.exchange.username
$exchangeAdminPassword = $c.exchange.password
$authenticationmode = $c.exchange.authenticationmode
$remoteroutingdomain = $c.exchange.remoteroutingaddress
$skipcacheck = $c.exchange.skipcacheck 
$skipcncheck = $c.exchange.skipcncheck 
$skiprevocationcheck = $c.exchange.skiprevocationcheck 

#account mapping
$account = @{
    samaccountname = $p.Accounts.MicrosoftActiveDirectory.sAMAccountName
    mailaddress    = $p.Accounts.MicrosoftActiveDirectory.Mail
    targetaddress  = ($p.Accounts.MicrosoftActiveDirectory.Mail).Split("@")[0] + "@" + $remoteroutingdomain
}

function EstablishSession {
    try {
        $adminSecurePassword = ConvertTo-SecureString -String "$exchangeAdminPassword" -AsPlainText -Force
        $adminCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $exchangeAdminUsername, $adminSecurePassword
        $sessionOption = New-PSSessionOption -SkipCACheck:$skipcacheck  -SkipCNCheck:$skipcncheck -SkipRevocationCheck:$skiprevocationcheck    
        $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $exchangeConnectionUri -Credential $adminCredential -Authentication $authenticationmode -SessionOption $sessionOption -ErrorAction Stop 
        $null = Import-PSSession $session -DisableNameChecking -AllowClobber
        $auditLogs.Add([PSCustomObject]@{
                Message = "Successfully connected to Exchange using the URI [$exchangeConnectionUri]"
                IsError = $false
            })         
    }
    catch {
        $errorMessage = "Error connecting to Exchange using the URI [$exchangeConnectionUri]"        
        Write-Verbose $errorMessage
        $auditLogs.Add([PSCustomObject]@{
                Message = $errorMessage
                IsError = $true
            })        
    }
    return $session
}

function DisconnnectSession {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $session
    )
    try {
        Remove-PsSession -Session $session -Confirm:$false -ErrorAction Stop
        $auditLogs.Add([PSCustomObject]@{
                Message = "Successfully disconnected from Exchange."
                IsError = $false
            })        
    }
    catch {
        $errorMessage = "Error disconnecting from Exchange. Error: $($_.Exception.Message)"
        Write-Verbose $errorMessage
        $auditLogs.Add([PSCustomObject]@{
                Message = $errorMessage
                IsError = $true
            })
    }
}

try {
    $exchangeSession = EstablishSession

    if ($null -eq $exchangeSession) {
        $auditLogs.Add([PSCustomObject]@{
                Message = "No session available to perform any mailbox actions."
                IsError = $true
            })
    }
    if ($exchangeSession) {        
        $mailbox = Get-RemoteMailbox -Identity $aRef
        if ($mailbox.Name.Count -eq 0) {
            Write-Verbose "Could not find mailbox with identity '$($aRef)'"
            $auditLogs.Add([PSCustomObject]@{
                    Message = "$action mailbox for: [$($p.DisplayName)] will be executed."
                    IsError = $false
                })
        }
        if ($mailbox.Name.Count -gt 0) {            
            Write-Verbose "Mailbox found for: [$($p.DisplayName)]"
            $action = 'Hide'
            $auditLogs.Add([PSCustomObject]@{
                    Message = "$action mailbox for: [$($p.DisplayName)] will be executed."
                    IsError = $false
                })
        }
        $dryRun = $false
        if (-not($dryRun -eq $true)) {
            switch ($action) {
                'Hide' {
                    Set-RemoteMailbox -identity $aRef -HiddenFromAddressListsEnabled $true
                    $success = $true
                    $auditLogs.Add([PSCustomObject]@{
                            Message = "Hiding mailbox for: [$($p.DisplayName)] was successful."
                            IsError = $false
                        })
                    break
                }                
            }
        }
    }
}
catch {
    $errorMessage = "Failed to unhide mailbox for: [$($p.DisplayName)]. Error: $($_Exception.Message)"
    Write-Verbose $errorMessage
    $auditLogs.Add([PSCustomObject]@{
            Message = $errorMessage
            IsError = $true
        })      
}
finally {
    if ($exchangeSession) {
        DisconnnectSession $exchangeSession        
    }
}

$result = [PSCustomObject]@{
    Success          = $success
    AccountReference = $accountReference
    AuditLogs        = $auditLogs
    Account          = $account
    
    # Optionally return data for use in other systems
    ExportData       = [PSCustomObject]@{
        identity    = $accountReference
        PrimaryMail = $account.mailaddress
    }
}
Write-Output $result | ConvertTo-Json -Depth 10

