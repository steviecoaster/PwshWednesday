# Pwsh Wednesday Presentation materials

The scripts in this repository were demonstrated during the PDQ PowerShell Wednesday livestream on 3 September 2025.

The following files are available:

- `ConvertPfx.ps1` - This script performs a conversion of certificate data to a PFX file.
- `ConvertPfx_gui.ps1` - This script launches a GUI produced using WinUIShell to convert certificates files into a PFX
- `UD.ps1` - This script provides a simnple PowerShell Universal App that has components for requesting Let's Encrypt certificates

## PowerShell Universal considerations

The `UD.ps1` script makes some assumptions, and has some requirements.

### Requirements

1. The Posh-ACME module must be installed by navigating to your PowerShell Universal instance > Platform > Modules > Galleries, searching for `Posh-ACME` and clicking install
2. You use the Cloudflare plugin of Posh-ACME
3. You have a Secret variable configured in PSU in Platform > Variables called `CloudflareToken`
4. You have a Script called RequestCert.ps1 in Automation > Scripts
5. You have a Script called GetCert.ps1 in Automation > Scripts

The script contents are available in the [UDScripts](/UDScripts/) folder.

>📓 **NOTE**
>
>_Other plugin types are available, modify `RequestCert.ps1` appropriately to use a different provider. You may need to add/edit/change Secrets to get things to work!_
