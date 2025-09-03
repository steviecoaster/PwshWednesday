New-UDApp -Content {
    $session:PSUJobData = $null
    #Put a card on top of the page, use a stack to place text inside
    New-UDStack -Content {
        New-UDCard -Content {
            New-UDStack -Direction row -Spacing 2 -AlignItems center -Content {
                New-UDIcon -Icon shield-cat -Size 8x
                New-UDStack -Direction column -Content {
                    New-UDTypography -Variant h4 -Text "PowerShell Wednesday - Certificate Request" -Style @{ 'margin-bottom' = '4px' }
                    New-UDTypography -Variant subtitle1 -Text "Use this form to request a new certificate" -Style @{ 'opacity' = '0.8' }
                }
            }
        } -Style @{ 
            'margin-bottom' = '24px'
            'background'    = 'linear-gradient(135deg, rgba(155, 39, 176, 0.1) 0%, rgba(104, 108, 126, 0.57) 100%)'
            'border-left'   = '4px solid #4744caff'
        }
    } -Spacing 2

    # Make a grid for the two functions of the page
    New-UDGrid -Container -Spacing 3 -Content {
        
        # Certificate Request Form Card
        New-UDGrid -Item -SmallSize 6 -Content {
            New-UDCard -Content {
                New-UDGrid -Container -Spacing 2 -Content {
                    # Purpose
                    New-UDGrid -Item -Content {
                        New-UDTypography -Variant body1 -Text 'Request New Certificate'
                    }
                    # Certificate domain textbox
                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                        New-UDTextbox -Id 'txtDomain' -Label "Certificate Subject" -Placeholder 'Enter the cert subject' -Icon (New-UDIcon -Icon firefox) -OnValidate {
                            if ([string]::IsNullOrEmpty($EventData)) {
                                New-UDValidationResult -ValidationError 'Domain name is required'
                            } 
                            else {
                                New-UDValidationResult -Valid
                            }
                        }
                    }
                    # Contact email textbox
                    New-UDGrid -Item -SmallSize 12 -Content {
                        New-UDTextbox -Id 'txtContact' -Label 'Contact Email' -Placeholder 'Enter registrant email' -Icon (New-UDIcon -Icon envelope) -OnValidate {
                            if ([string]::IsNullOrEmpty($EventData)) {
                                New-UDValidationResult -ValidationError 'Email is required'
                            } 
                            else {
                                New-UDValidationResult -Valid
                            }
                        }
                    }
                    # Button to request certificate
                    New-UDGrid -Item -SmallSize 6 -Content {
                        New-UDButton -Icon shield-halved -Text "Request Certificate" -FullWidth -Color secondary -OnClick {
                            $Domain = (Get-UDElement -Id 'txtDomain').value
                            $Contact = (Get-UDElement -ID 'txtContact').value
                            $psuScript = Get-PSUScript -Name 'RequestCert.ps1' -TrustCertificate
                
                            # Request certificate
                            #$Job = Invoke-PSUScript -Script $psuScript -Parameters @{Domain = $Domain} -TrustCertificate
                            $Job = Invoke-PSUScript -Script $psuScript -Parameters @{Domain = $Domain ; ContactEmail = $Contact } -TrustCertificate
                                            
                            # Show modal with job monitoring
                            Show-UDModal -Content {
                                New-UDElement -Id 'ModalJobOutput' -Tag 'pre' -Attributes @{
                                    style = @{
                                        'background-color' = '#1e1e1e'
                                        'color'            = '#00ff00'
                                        'border-radius'    = '4px'
                                        'padding'          = '16px'
                                        'max-height'       = '500px'
                                        'overflow-y'       = 'auto'
                                        'font-family'      = 'Consolas, Monaco, monospace'
                                        'font-size'        = '12px'
                                        'white-space'      = 'pre-wrap'
                                        'min-height'       = '300px'
                                        'width'            = '100%'
                                    }
                                } -Content {
                                    "Requesting certificate for: $Domain...`r`n"
                                }
                            } -Header {
                                New-UDTypography -Text "Certificate Request Monitor" -Variant h5
                            } -FullWidth -MaxWidth 'lg' -Persistent
                                            
                            # Monitor job in background
                            while ($Job.Status -eq 'Running' -or $Job.Status -eq 'Queued') {
                                try {
                                    Set-UDElement -Id 'ModalJobOutput' -Content {
                                        "Waiting for certificate (may take up to 2 minutes)..."
                                    }
                                }
                                catch {
                                    Write-Host "Error getting job output: $($_.Exception.Message)"
                                }
                                                
                                $Job = Get-PSUJob -Id $Job.Id -TrustCertificate -ErrorAction SilentlyContinue
                                Start-Sleep -Seconds 2
                            }
                                            
                            # Get final output and close modal
                            try {
                                $FinalOutput = Get-PSUJobOutput -Job $Job -TrustCertificate -ErrorAction SilentlyContinue
                                Set-UDElement -Id 'ModalJobOutput' -Content {
                                    if ($FinalOutput -and $FinalOutput.Length -gt 0) {
                                        $finalText = ($FinalOutput | ForEach-Object { "$_`r`n" }) -join ""
                                        "$finalText`r`n`r`n--- Job $($Job.Status) ---"
                                    }
                                    else {
                                        "Job completed but no output was captured.`r`n`r`n--- Job $($Job.Status) ---"
                                    }
                                }
                            }
                            catch {
                                Set-UDElement -Id 'ModalJobOutput' -Content {
                                    "Error retrieving final job output: $($_.Exception.Message)`r`n`r`n--- Job $($Job.Status) ---"
                                }
                            }
                            $session:PSUJobData = Get-PSUJobPipelineOutput -Job $Job -TrustCertificate
                            Hide-UDModal
                            Sync-UDElement -ID 'CertificateTableContainer'
                        }
                    }
                }
            } -Style @{
                'padding'       = '24px'
                'box-shadow'    = '0 2px 8px rgba(0,0,0,0.2)'
                'border-radius' = '8px'
                'border'        = '1px solid rgba(255,255,255,0.1)'
                'background'    = 'rgba(0,0,0,0.05)'
            }
        }
        
        # Second Card - Domain Lookup
        New-UDGrid -Item -SmallSize 6 -Content {
            New-UDCard -Content {
                New-UDGrid -Container -Spacing 2 -Content {
                    
                    # Purpose
                    New-UDGrid -Item -Content {
                        New-UDTypography -Variant body1 -Text 'Lookup Certificate'
                    }

                    # Domain textbox
                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                        New-UDTextbox -Id 'txtLookupDomain' -Label "Domain" -Placeholder 'Enter domain to lookup' -Icon (New-UDIcon -Icon search) -OnValidate {
                            if ([string]::IsNullOrEmpty($EventData)) {
                                New-UDValidationResult -ValidationError 'Domain is required'
                            } 
                            else {
                                New-UDValidationResult -Valid
                            }
                        }
                    }
                    
                    # Lookup button
                    New-UDGrid -Item -SmallSize 6 -Content {
                        New-UDButton -Icon search -Text "Get Certificate" -FullWidth -Color secondary -OnClick {
                            $Domain = (Get-UDElement -Id 'txtLookupDomain').value
                            $psuScript = Get-PSUScript -Name 'GetCert.ps1' -TrustCertificate
                            $Job = Invoke-PSUScript -Script $psuScript -Parameters @{Domain = $Domain } -TrustCertificate
                        
                            # Show modal with job monitoring
                            Show-UDModal -Content {
                                New-UDElement -Id 'ModalJobOutput' -Tag 'pre' -Attributes @{
                                    style = @{
                                        'background-color' = '#1e1e1e'
                                        'color'            = '#00ff00'
                                        'border-radius'    = '4px'
                                        'padding'          = '16px'
                                        'max-height'       = '500px'
                                        'overflow-y'       = 'auto'
                                        'font-family'      = 'Consolas, Monaco, monospace'
                                        'font-size'        = '12px'
                                        'white-space'      = 'pre-wrap'
                                        'min-height'       = '300px'
                                        'width'            = '100%'
                                    }
                                } -Content {
                                    "Fetching certificate info for: $Domain...`r`n"
                                }
                            } -Header {
                                New-UDTypography -Text "Certificate Request Monitor" -Variant h5
                            } -FullWidth -MaxWidth 'lg' -Persistent
                                            
                            # Monitor job in background
                            while ($Job.Status -eq 'Running' -or $Job.Status -eq 'Queued') {
                                try {
                                    Set-UDElement -Id 'ModalJobOutput' -Content {
                                        "Waiting for certificate (may take up to 2 minutes)..."
                                    }
                                }
                                catch {
                                    Write-Host "Error getting job output: $($_.Exception.Message)"
                                }
                                                
                                $Job = Get-PSUJob -Id $Job.Id -TrustCertificate -ErrorAction SilentlyContinue
                                Start-Sleep -Seconds 2
                            }
                                            
                            # Get final output and close modal
                            try {
                                $FinalOutput = Get-PSUJobOutput -Job $Job -TrustCertificate -ErrorAction SilentlyContinue
                                Set-UDElement -Id 'ModalJobOutput' -Content {
                                    if ($FinalOutput -and $FinalOutput.Length -gt 0) {
                                        $finalText = ($FinalOutput | ForEach-Object { "$_`r`n" }) -join ""
                                        "$finalText`r`n`r`n--- Job $($Job.Status) ---"
                                    }
                                    else {
                                        "Job completed but no output was captured.`r`n`r`n--- Job $($Job.Status) ---"
                                    }
                                }
                            }
                            catch {
                                Set-UDElement -Id 'ModalJobOutput' -Content {
                                    "Error retrieving final job output: $($_.Exception.Message)`r`n`r`n--- Job $($Job.Status) ---"
                                }
                            }
                            $session:PSUJobData = Get-PSUJobPipelineOutput -Job $Job -TrustCertificate
                            Hide-UDModal
                            Sync-UDElement -ID 'CertificateTableContainer'
                        }
                    }
                }
            } -Style @{
                'padding'       = '24px'
                'box-shadow'    = '0 2px 8px rgba(0,0,0,0.2)'
                'border-radius' = '8px'
                'border'        = '1px solid rgba(255,255,255,0.1)'
                'background'    = 'rgba(0,0,0,0.05)'
            }
        }
    }

    # Grid for our data display
    New-UDGrid -Container -Spacing 2 -Content {
        #Table to display certificate data
        New-UDGrid -Item -Smallsize 8 -Content {
            # Wrapping the table in a dynamic allows it to be updated from external forces (like clicking a button on a form)
            New-UDDynamic -Content {
                if ($session:PSUJobData -and $session:PSUJobData.Count -gt 0) {
                    New-UDTable -Data $session:PSUJobData -Id 'CertificateTable' -Columns @(
                        New-UDTableColumn -Property Subject -Title "Subject"
                        New-UDTableColumn -Property NotAfter -Title "Not After"
                        New-UDTableColumn -Property Thumbprint -Title "Thumbprint"
                        # You can lie to the table to provide extra functionality. Actions doesn't exist on the $PSUJobData object, but we can render our own data, like a button
                        New-UDTableColumn -Property Actions -Title 'Actions' -Render {
                            New-UDStack -Direction row -Spacing 1 -Content {
                                New-UDButton -Icon download -Text 'Download Certificate(s)' -Color secondary -OnClick {

                                    $downloadFiles = @()
                                    
                                    if ($EventData.CertFile) {
                                        $downloadFiles += @{
                                            Name = [System.IO.Path]::GetFileName($EventData.CertFile)
                                            Type = "Certificate"
                                            Path = $EventData.CertFile
                                        }
                                    }
                                    if ($EventData.KeyFile) {
                                        $downloadFiles += @{
                                            Name = [System.IO.Path]::GetFileName($EventData.KeyFile)
                                            Type = "Private Key"
                                            Path = $EventData.KeyFile
                                        }
                                    }
                                    if ($EventData.ChainFile) {
                                        $downloadFiles += @{
                                            Name = [System.IO.Path]::GetFileName($EventData.ChainFile)
                                            Type = "Chain"
                                            Path = $EventData.ChainFile
                                        }
                                    }
                                    if ($EventData.FullChainFile) {
                                        $downloadFiles += @{
                                            Name = [System.IO.Path]::GetFileName($EventData.FullChainFile)
                                            Type = "Full Chain"
                                            Path = $EventData.FullChainFile
                                        }
                                    }
                                    if ($EventData.PfxFile) {
                                        $downloadFiles += @{
                                            Name = [System.IO.Path]::GetFileName($EventData.PfxFile)
                                            Type = "PFX"
                                            Path = $EventData.PfxFile
                                        }
                                    }
                                    if ($EventData.PfxFullChain) {
                                        $downloadFiles += @{
                                            Name = [System.IO.Path]::GetFileName($EventData.PfxFullChain)
                                            Type = "PFX Full Chain"
                                            Path = $EventData.PfxFullChain
                                        }
                                    }

                                    # Open a modal to display the available certificate files for download
                                    Show-UDModal -Content {
                                        New-UDTable -Data $downloadFiles -Columns @(
                                            New-UDTableColumn -Property Name -Title "File Name"
                                            New-UDTableColumn -Property Type -Title "Type"
                                            New-UDTableColumn -Property Download -Title "Download" -Render {
                                                New-UDButton -Icon download -Text 'Download' -Size small -OnClick {
                                                    try {
                                                        Start-UDDownload -Path $EventData.Path -FileName $EventData.Name
                                                    }
                                                    catch {
                                                        Show-UDToast -Message "Error downloading file: $($_.Exception.Message)" -MessageColor error
                                                    }
                                                }
                                            }
                                        )
                                    } -Header {
                                        New-UDTypography -Text "Download Certificate Files" -Variant h5
                                    } -FullWidth -MaxWidth 'md'
                                }
                            }
                        }
                    )
                }
                else {
                    New-UDCard -Content {
                        New-UDStack -Direction column -Spacing 2 -AlignItems center -Content {
                            New-UDIcon -Icon exclamation-triangle -Size '3x' -Color warning -Style @{ 'opacity' = '0.6' }
                            New-UDTypography -Variant h6 -Text "No Certificates Found" -Align center
                            New-UDTypography -Variant body2 -Text "Request certificate above" -Align center -Style @{ 'opacity' = '0.7' }
                        }
                    } -Style @{ 
                        'text-align' = 'center'
                        'padding'    = '40px'
                        'border'     = '2px dashed rgba(0,0,0,0.12)'
                    }
                }
            } -Id 'CertificateTableContainer'
        }
        
    }
}