[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [String]
    $cert,

    [Parameter(Mandatory)]
    [String]
    $key,

    [Parameter(Mandatory)]
    [String]
    $pfx,

    [Parameter()]
    [SecureString]
    $password
)

process {
    $convert = @('pkcs12', '-export', '-in', $('{0}' -f $Cert), '-inkey', $('{0}' -f $Key), '-out', "$('{0}' -f $Pfx)", '-passout', "pass:$(([System.Net.NetworkCredential]::new($null,$Password).Password))")
    & openssl @convert
}