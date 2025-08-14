# Enable Light Mode for Apps
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1

# Enable Light Mode for System
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 1

# Set the Wallpaper
$wallpaperPath = "C:\Windows\Web\Wallpaper\Windows\img0.jpg"
$code = @'
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
'@

Add-Type $code
$SPI_SETDESKWALLPAPER = 0x0014
$UPDATE_INI_FILE = 0x01
$SEND_CHANGE = 0x02

[Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $wallpaperPath, ($UPDATE_INI_FILE -bor $SEND_CHANGE))

# Restart Explorer to apply changes
Write-Host "Restarting Explorer..."
Stop-Process -Name explorer -Force
Start-Process explorer
Write-Host "Light mode enabled! Explorer has been restarted."
