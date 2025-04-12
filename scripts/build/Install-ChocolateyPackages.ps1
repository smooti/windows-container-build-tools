# Install Chocolatey packages

function Install-ChocoPackage {
	<#
	.SYNOPSIS
			A function to install a Chocolatey package with retries.

	.DESCRIPTION
			This function attempts to install a specified Chocolatey package. If the 
			installation fails, it retries a specified number of times.

	.PARAMETER PackageName
			The name of the Chocolatey package to install.

	.PARAMETER ArgumentList
			An array of arguments to pass to the choco install command.

	.PARAMETER RetryCount
			The number of times to retry the installation if it fails. Default is 5.

	.PARAMETER Version
			The version of the package to install.

	.EXAMPLE
			Install-ChocoPackage -PackageName "git" -Version "2.39.2" -RetryCount 3
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string] $PackageName,
		[string[]] $ArgumentList,
		[string] $Version,
		[int] $RetryCount = 5
	)

	$count = 1
	while ($true) {
		Write-Host "Running [#$count]: choco install $packageName -y $argumentList"
		if ($Version) {
			choco install $packageName --version $Version -y @ArgumentList --no-progress --require-checksums
		}
		else {
			choco install $packageName -y @ArgumentList --no-progress --require-checksums
		}
		$pkg = choco list --localonly $packageName --exact --all --limitoutput
		if ($pkg) {
			Write-Host "Package installed: $pkg"
			break
		}
		else {
			$count++
			if ($count -ge $retryCount) {
				Write-Host "Could not install $packageName after $count attempts"
				exit 1
			}
			Start-Sleep -Seconds 30
		}
	}
}

function Add-MachinePathItem {
	<#
	.SYNOPSIS
			Adds a new item to the machine-level PATH environment variable.

	.DESCRIPTION
			The Add-MachinePathItem function adds a new item to the machine-level PATH environment variable.
			It takes a string parameter, $PathItem, which represents the new item to be added to the PATH.

	.PARAMETER PathItem
			Specifies the new item to be added to the machine-level PATH environment variable.

	.EXAMPLE
			Add-MachinePathItem -PathItem "C:\Program Files\MyApp"

			This example adds "C:\Program Files\MyApp" to the machine-level PATH environment variable.
	#>

	param(
		[Parameter(Mandatory = $true)]
		[string] $PathItem
	)

	$currentPath = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine')
	$newPath = $PathItem + ';' + $currentPath
	[Environment]::SetEnvironmentVariable('PATH', $newPath, 'Machine')
}

function Update-Environment {
	<#
	.SYNOPSIS
			Updates the environment variables by reading values from the registry.

	.DESCRIPTION
			This function updates current environment by reading values from the registry.
			It is useful when you need to update the environment variables without restarting the current session.

	.NOTES
			The function requires administrative privileges to modify the system registry.
	#>

	$locations = @(
		'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
		'HKCU:\Environment'
	)

	# Update PATH variable
	$pathItems = $locations | ForEach-Object {
			(Get-Item $_).GetValue('PATH').Split(';')
	} | Select-Object -Unique
	$env:PATH = $pathItems -join ';'

	# Update other variables
	$locations | ForEach-Object {
		$key = Get-Item $_
		foreach ($name in $key.GetValueNames()) {
			$value = $key.GetValue($name)
			if (-not ($name -ieq 'PATH')) {
				Set-Item -Path Env:$name -Value $value
			}
		}
	}
}

$chocolateyPackages = @(
	@{ name = '7zip.install' },
	@{ name = 'jq' },
	@{ name = 'packer' },
	@{ name = 'terraform' },
	@{ name = 'cmake.install' }
)

# Add to system PATH
Add-MachinePathItem 'C:\ProgramData\chocolatey\bin'
Update-Environment

foreach ($package in $chocolateyPackages) {
	Install-ChocoPackage $package.name -Version $package.version -ArgumentList $package.args
}