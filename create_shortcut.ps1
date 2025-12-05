$ws = New-Object -ComObject WScript.Shell
$s = $ws.CreateShortcut([IO.Path]::Combine($env:USERPROFILE, "Desktop", "foodiy_web_5000.lnk"))
$s.TargetPath = "C:\\dev\\foodiy\\run_foodiy_5000.bat"
$s.WorkingDirectory = "C:\\dev\\foodiy"
$s.WindowStyle = 1
$s.IconLocation = "C:\\Windows\\System32\\shell32.dll,0"
$s.Save()

