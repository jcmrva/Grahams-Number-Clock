
Set-Location .\app -ErrorAction Stop

elm-format .\src\ --yes
elm make .\src\GrahamsNbrClock.elm --output=GrahamsNbrClock.js # --debug

Copy-Item -Path .\GrahamsNbrClock.js -Destination ..\GrahamsNbrClock.js -Force

Set-Location ..