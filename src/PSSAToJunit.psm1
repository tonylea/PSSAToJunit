#Get public and private function definition files.
$ClassesPath = Join-Path -Path $PSScriptRoot -ChildPath "classes" -AdditionalChildPath "*.ps1"
$Classes = @( Get-ChildItem -Path $ClassesPath -ErrorAction SilentlyContinue )

$PrivatePath = Join-Path -Path $PSScriptRoot -ChildPath "private" -AdditionalChildPath "*.ps1"
Write-Host "Private Path: $PrivatePath" -ForegroundColor Red
$Private = @( Get-ChildItem -Path $PrivatePath -ErrorAction SilentlyContinue )
Write-Host "Found $($Private.Count) private functions"

$PublicPath = Join-Path -Path $PSScriptRoot -ChildPath "public" -AdditionalChildPath "*.ps1"
Write-Host "Public Path: $PublicPath" -ForegroundColor Red
$Public = @( Get-ChildItem -Path $PublicPath -ErrorAction SilentlyContinue )
Write-Host "Found $($Public.Count) public functions"

#Dot source the files
Foreach ($import in @($Classes + $Private + $Public)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $Public.Basename
