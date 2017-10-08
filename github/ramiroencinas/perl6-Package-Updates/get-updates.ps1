[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ses = New-Object -com "Microsoft.Update.Session"

$search = $ses.CreateUpdateSearcher()
$res = $search.Search("IsInstalled=0 and IsHidden=0")

foreach ($i in $res.Updates) {
  write-host $i.Title
}
