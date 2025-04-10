################################################################################
##  File:  Install-ChocolateyPackages.ps1
##  Desc:  Install Chocolatey packages
################################################################################

$chocolateyPackages = @(
	@{ name = '7zip.install' },
	@{ name = 'jq' },
	@{ name = 'packer' },
	@{ name = 'terraform' },
	@{ name = 'cmake.install'; version = '3.31.6'; args = ADD_CMAKE_TO_PATH=\"System\"}
)

foreach ($package in $chocolateyPackages) {
	Install-ChocoPackage $package.name -Version $package.version -ArgumentList $package.args
}