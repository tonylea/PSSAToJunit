function Set-BuildHelperEnvVars {
    param (
        $Path
    )

    $BuildHelperVars = Get-Item ENV:BH*
    if (!$BuildHelperVars) {
        Set-BuildEnvironment -Path $Path
    }
}
