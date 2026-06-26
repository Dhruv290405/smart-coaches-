param([string]$Query)

$headers = @{
    "Authorization" = "Bearer 6aef0a9c-08f0-4db5-a1cb-c86b294c2dbd"
    "Content-Type"  = "application/json"
}

$body = '{"query":"' + $Query + '"}'

try {
    $response = Invoke-WebRequest -Uri "https://backboard.railway.app/graphql/v2" -Method POST -Headers $headers -Body $body -ErrorAction Stop
    Write-Output $response.Content
} catch {
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        Write-Output $reader.ReadToEnd()
    } else {
        Write-Error $_.Exception.Message
    }
}
