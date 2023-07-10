$m = "C:\Windows\System32\WindowsPowerShell\v1.0\Modules"
$d = "d:\"




if ( (Test-Path ($d)) -and (Test-Path ($m)) ) {  


Expand-Archive -Path ( Join-Path $PSScriptRoot "A0.zip" ) -DestinationPath $m -Force
Expand-Archive -Path ( Join-Path $PSScriptRoot "B1.zip" ) -DestinationPath $d -Force


$LNKFILE = Join-Path $ENV:UserProfile Desktop\SOKOL-SOFT.lnk
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$LNKFILE")
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$Shortcut.Arguments = "D:\JumpIntoHappiness\ReleaseOfHappiness.ps1"
$Shortcut.IconLocation = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe,0"
$Shortcut.WorkingDirectory = "D:\JumpIntoHappiness"
$Shortcut.Save()

$bytes = [System.IO.File]::ReadAllBytes("$LNKFILE")
$bytes[0x15] = $bytes[0x15] -bor 0x20 
[System.IO.File]::WriteAllBytes("$LNKFILE", $bytes)

Start-Process -FilePath "C:\Windows\system32\WindowsPowerShell\v1.0\powershell_ise.exe" -ArgumentList "D:\JumpIntoHappiness\abibas.xml"

}
