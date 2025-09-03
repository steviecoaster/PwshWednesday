using namespace WinUIShell
Import-Module WinUIShell

# This is our app itself
$resources = [Application]::Current.Resources

# And this is our window for our app. We'll style, size, and fill this window.
$win = [Window]::new()

# Mica gives the window its look and feel. It supports light/dark mode, follows system preference
$win.SystemBackdrop = [MicaBackdrop]::new()
$win.ExtendsContentIntoTitleBar = $true

# The presenter is a picture-in-picture overlay thing for the window
$presenter = [CompactOverlayPresenter]::new()
$win.AppWindow.SetPresenter($presenter)
$win.AppWindow.ResizeClient(410, 555)

# This is our "upper third" where the icon and title text sit
$icon = [SymbolIcon]::new('Repair')

$title = [TextBlock]::new()
$title.Text = 'Pfx File Maker Thingy'
$title.Style = $resources['TitleTextBlockStyle']

# This panel is the container for the icon and title
$titlePanel = [StackPanel]::new()
$titlePanel.Orientation = 'Horizontal'
$titlePanel.Spacing = 16
$titlePanel.Margin = [Thickness]::new(0, 12, 0, 24)
$titlePanel.Children.Add($icon)
$titlePanel.Children.Add($title)

# Add a textbox for our original certificate file
$txtCert = [TextBox]::new()
$txtCert.Header = 'Certificate File (.cer or .cert)'
$txtCert.PlaceHolderText = '.cer or .cert accepted'
$txtCert.Margin = [Thickness]::new(0, 0, 0, 24)

# And one for the key file
$txtKey = [TextBox]::new()
$txtKey.Header = 'Key File'
$txtKey.PlaceHolderText = '.key file accepted'
$txtKey.Margin = [Thickness]::new(0, 0, 0, 24)

# Save the pfx file to here
$txtPfx = [TextBox]::New()
$txtPfx.Header = 'Pfx File'
$txtPfx.PlaceholderText = 'Save to...'
$txtPfx.Margin = [Thickness]::new(0, 0, 0, 24)

$password = [PasswordBox]::new()
$password.Header = 'Export Password'
$password.Description = 'This will be the password on the private key for the pfx file.'
$password.Margin = [Thickness]::new(0, 0, 0, 24)

$progressRing = [ProgressRing]::new()
$progressRing.IsIndeterminate = $true
$progressRing.IsActive = $false


$status = [TextBlock]::new()
$status.Text = ''
$status.Margin = [Thickness]::new(0, 0, 0, 24)

# We need a button to press, and that button needs to run the choco download command.
$pressToClose = $false
$button = [Button]::new()
$button.HorizontalAlignment = 'Right'
$button.Content = 'Convert'
$button.Style = $resources['AccentButtonStyle']
$button.AddClick({
        if ($script:pressToClose) {
            $win.Close()
            return
        }

        $progressRing.IsActive = $true

        # Don't let people click the button while a conversion is happening
        $button.IsEnabled = $false
      
        # Do the conversion
        $convert = @('pkcs12', '-export', '-in', $('{0}' -f $($txtCert.Text) -replace '"',''), '-inkey', $('{0}' -f $($txtKey.Text) -replace '"',''), '-out', "$('{0}' -f $($txtPfx.Text) -replace '"','')", '-passout', "pass:$(([System.Net.NetworkCredential]::new($null,$($password.Password)).Password))")
        #$certArgs = @('pkcs12', '-export', '-in', $($txtCert.Text), '-inkey', $($txtKey.Text), '-out', $($txtPfx.Text), '-passout', $('pass:{0}' -f $password.Password))
        
        try {
            Start-Transcript C:\temp\attempt.log
            & openssl @convert
            # Update our status
            $status.Text = '🎉 Done!'
            Stop-Transcript
        }
        catch {
            $status.Text = $error[0].Exception
            Stop-Transcript
        }


        $progressRing.IsActive = $false
        $button.Content = 'Close'
        $script:pressToClose = $true
        $button.IsEnabled = $true
    })

# And here we decorate the app by putting a panel on it, and then adding all our components to the panel
$panel = [StackPanel]::new()
$panel.Margin = 25
$panel.Children.Add($titlePanel)
$panel.Children.Add($txtCert)
$panel.Children.Add($txtKey)
$panel.Children.Add($txtPfx)
$panel.Children.Add($password)
$panel.Children.Add($status)
$panel.Children.Add($progressRing)
$panel.Children.Add($button)

# And finally we give our app content, and open it for use
$win.Content = $panel
$win.Activate()
$win.WaitForClosed()
