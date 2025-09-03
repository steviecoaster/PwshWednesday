[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [String]
    $Domain,

    [Parameter(Mandatory)]
    [String]
    $ContactEmail
)

end {
    $token = @{CFToken = ($Secret:CloudflareToken | ConvertTo-SecureString -AsPlainText -Force)}
    $certArgs = @{
        Domain = $Domain
        Contact = $ContactEmail
        AcceptTOS = $true
        Plugin = 'Cloudflare'
        PluginArgs = $token
    }

    New-PACertificate @certArgs
}