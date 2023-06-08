#Get public and private function definition files.
$ClassesPath = Join-Path -Path $PSScriptRoot -ChildPath "Classes" -AdditionalChildPath "*.ps1"
$Classes = @( Get-ChildItem -Path $ClassesPath -ErrorAction SilentlyContinue )

$PrivatePath = Join-Path -Path $PSScriptRoot -ChildPath "Private" -AdditionalChildPath "*.ps1"
$Private = @( Get-ChildItem -Path $PrivatePath -ErrorAction SilentlyContinue )

$PublicPath = Join-Path -Path $PSScriptRoot -ChildPath "Public" -AdditionalChildPath "*.ps1"
$Public = @( Get-ChildItem -Path $PublicPath -ErrorAction SilentlyContinue )

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
