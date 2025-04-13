# Install Chocolatey packages

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