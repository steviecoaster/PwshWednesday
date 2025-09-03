[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [String]
    $Domain
)

end {
    Get-PACertificate -MainDomain $Domain
}