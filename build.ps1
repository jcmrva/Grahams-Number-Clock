
Set-Location .\app -ErrorAction Stop

elm make .\src\GrahamsNbrClock.elm --output=GrahamsNbrClock.js

Set-Location ..