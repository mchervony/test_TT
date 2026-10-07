# Define the URL and the local destination path
$url = "https://example.com"
$destination = "$env:USERPROFILE\Desktop\downloaded_file.txt"

try {
    # Method 1: Using native .NET WebClient (Recommended for pure .NET approach in PS 5.1)
    Write-Host "Downloading file via .NET WebClient..." -ForegroundColor Cyan
    $webClient = New-Object System.Net.WebClient
    
    # Download the string content directly into memory
    $content = $webClient.DownloadString($url)
    Write-Host "Content successfully grabbed in-memory!" -ForegroundColor Green
    
    # Optional: Save the content to a file
    $webClient.DownloadFile($url, $destination)
    Write-Host "File successfully saved to: $destination" -ForegroundColor Green

    # Display a preview of the content
    Write-Host "`n--- Content Preview ---" -ForegroundColor Yellow
    $content
}
catch {
    Write-Error "An error occurred during the download: $_"
}