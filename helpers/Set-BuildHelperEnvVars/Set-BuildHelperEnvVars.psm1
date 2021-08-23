function Set-BuildHelperEnvVars {
    param ()

    $BuildHelperVars = Get-Item ENV:BH*
    if (!$BuildHelperVars) {
        Set-BuildEnvironment
    }
}
