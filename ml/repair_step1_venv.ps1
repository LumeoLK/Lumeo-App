param(
    [string]$VenvPath = "venv312",
    [string]$PythonCommand = "py -3.12",
    [string]$RequirementsFile = "requirements-step1.txt"
)

$ErrorActionPreference = "Stop"

function Invoke-CommandString {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    $parts = [System.Management.Automation.PSParser]::Tokenize($Command, [ref]$null) |
        Where-Object { $_.Type -eq "CommandArgument" -or $_.Type -eq "Command" } |
        ForEach-Object { $_.Content }

    if (-not $parts -or $parts.Count -eq 0) {
        throw "Could not parse command: $Command"
    }

    return ,$parts
}

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoRoot

$venvFullPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $VenvPath))
$requirementsFullPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $RequirementsFile))

if (-not (Test-Path $requirementsFullPath)) {
    throw "Missing Step 1 requirements file: $requirementsFullPath"
}

$pythonParts = Invoke-CommandString -Command $PythonCommand
$pythonExe = $pythonParts[0]
$pythonArgs = @()
if ($pythonParts.Count -gt 1) {
    $pythonArgs = $pythonParts[1..($pythonParts.Count - 1)]
}

$venvMarkers = @(
    (Join-Path $venvFullPath "pyvenv.cfg"),
    (Join-Path $venvFullPath "Scripts\python.exe"),
    (Join-Path $venvFullPath "Scripts\pip.exe")
)

$venvHealthy = $true
foreach ($marker in $venvMarkers) {
    if (-not (Test-Path $marker)) {
        $venvHealthy = $false
        break
    }
}

if (-not $venvHealthy) {
    Write-Host "Rebuilding Step 1 virtual environment at $venvFullPath"
    & $pythonExe @pythonArgs -m venv $venvFullPath --upgrade-deps
}
else {
    Write-Host "Step 1 virtual environment structure already exists at $venvFullPath"
}

$venvPython = Join-Path $venvFullPath "Scripts\python.exe"
if (-not (Test-Path $venvPython)) {
    throw "Python executable not found after venv repair: $venvPython"
}

Write-Host "Installing Step 1 dependencies from $requirementsFullPath"
& $venvPython -m pip install --upgrade pip setuptools wheel
& $venvPython -m pip install --upgrade --force-reinstall -r $requirementsFullPath

Write-Host "Validating Step 1 environment"
& $venvPython ".\step1_env_doctor.py" --venv $venvFullPath
