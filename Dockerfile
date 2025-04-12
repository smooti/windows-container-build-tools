# escape=`
# ^^ The above is set to prevent issues with Windows paths containing backslashes
# https://docs.docker.com/reference/dockerfile/#escape


# Use the latest Windows Server 2022 image
FROM mcr.microsoft.com/windows/server:ltsc2022

# Restore the default Windows shell for correct batch processing
SHELL ["cmd", "/S", "/C"]

COPY scripts/ C:\scripts\

RUN `
	powershell -File C:\scripts\build\Install-Chocolatey.ps1 `
	&& powershell -File C:\scripts\build\Install-ChocolateyPackages.ps1

RUN `
	# Download the Build Tools bootstrapper
	echo 'Downloading Build Tools bootstrapper...' `
	&& curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe `
	`
	# Install Visual Studio workloads and components
	&& echo 'Installing Visual Studio workloads and components...' `
	&& (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
		--installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" `
		--add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools `
		--add Microsoft.VisualStudio.Workload.VCTools `
		--add Microsoft.VisualStudio.Workload.UniversalBuildTools `
		--add Microsoft.VisualStudio.Component.VC.ATLMFC `
		--add Microsoft.VisualStudio.Component.VC.CLI.Support `
		--add Microsoft.VisualStudio.Component.VC.140 `
		--add Microsoft.VisualStudio.Component.VC.v141.x86.x64 `
		--add Microsoft.VisualStudio.Component.VC.v141.CLI.Support `
		--add Microsoft.VisualStudio.Component.VC.v141.ATL `
		--add Microsoft.VisualStudio.Component.VC.v141.MFC `
		--add Microsoft.VisualStudio.Component.VC.14.29.16.11.CLI.Support `
		--add Microsoft.VisualStudio.Component.VC.14.29.16.11.ATL `
		--add Microsoft.VisualStudio.Component.VC.14.29.16.11.MFC `
		--add Microsoft.VisualStudio.ComponentGroup.VC.Tools.142.x86.x64 `
		--add Microsoft.VisualStudio.ComponentGroup.UWP.VC.BuildTools `
		--add Microsoft.VisualStudio.ComponentGroup.UWP.VC.v141.BuildTools `
		--add Microsoft.VisualStudio.ComponentGroup.UWP.VC.v142.BuildTools `
		|| IF "%ERRORLEVEL%"=="3010" EXIT 0) `
	`
	# Cleanup
	&& echo 'Cleaning up...' `
	&& del /q vs_buildtools.exe

# Define the entry point for the docker container.
# This entry point starts the developer command prompt and launches the PowerShell shell.
ENTRYPOINT ["C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]