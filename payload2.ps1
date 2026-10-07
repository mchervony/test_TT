# ============================================
# Enumeration Script - WMI/ADSI Only
# For authorized tabletop exercise use
# ============================================
Write-Host "===== LOCAL GROUPS ====="
# Native ADSI accelerator - no net.exe
$computer = [ADSI]"WinNT://$env:COMPUTERNAME"
$computer.Children | Where-Object { $_.SchemaClassName -eq 'Group' } | ForEach-Object {
    Write-Host "`nGroup: $($_.Name)"
    $group = [ADSI]"WinNT://$env:COMPUTERNAME/$($_.Name),group"
    $members = @($group.Invoke("Members"))
    foreach ($member in $members) {
        $memberPath = $member.GetType().InvokeMember("AdsPath", 'GetProperty', $null, $member, $null)
        Write-Host "  Member: $memberPath"
    }
}
Write-Host "`n===== NETWORK CONFIGURATION ====="
# Native WMI accelerator - no ipconfig/wmic
Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | ForEach-Object {
    Write-Host "`nAdapter: $($_.Description)"
    Write-Host "  IP Address(es): $($_.IPAddress -join ', ')"
    Write-Host "  Subnet Mask(s): $($_.IPSubnet -join ', ')"
    Write-Host "  Default Gateway: $($_.DefaultIPGateway -join ', ')"
    Write-Host "  DNS Servers: $($_.DNSServerSearchOrder -join ', ')"
    Write-Host "  MAC Address: $($_.MACAddress)"
}
Write-Host "`n===== DOMAIN TRUSTS ====="
# Native .NET accelerator - no nltest/wmic
try {
    $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    Write-Host "`nCurrent Domain: $($domain.Name)"
    
    $trusts = $domain.GetAllTrustRelationships()
    if ($trusts.Count -eq 0) {
        Write-Host "No trust relationships found."
    } else {
        foreach ($trust in $trusts) {
            Write-Host "`nTrust Partner: $($trust.TargetName)"
            Write-Host "  Trust Type: $($trust.TrustType)"
            Write-Host "  Trust Direction: $($trust.TrustDirection)"
        }
    }
} catch {
    Write-Host "Unable to enumerate domain trusts. Host may not be domain-joined or ADSI/.NET AD context unavailable."
}
Write-Host "`n===== ENUMERATION COMPLETE ====="