function Set-TestHelperEnvVars {
    param (
        $Path
    )

    $BuildHelperVars = Get-Item ENV:BH*
    if (!$BuildHelperVars) {
        Set-BuildEnvironment -Path ($Path -replace "tests.+")
    }

    $ENV:THFunctionName = (Get-Item -Path $Path).BaseName -replace "\.tests"
    $ENV:THFunctionPath = $Path -replace ".+unit-tests", $ENV:BHPSModulePath -replace "\.tests"

}
