This container should contain all utilities needed when building software. This should be used in a CI/CD environment.

## Build

The following command will build the container image using 4GB of memory

```bash
docker build -t buildtools:latest -m 4GB .
```

---

**Note**

The build may take a while as the following workloads and components are big in size...

- Microsoft.VisualStudio.Workload.UniversalBuildTools
- Microsoft.VisualStudio.ComponentGroup.VC.Tools.142.x86.x64
- Microsoft.VisualStudio.ComponentGroup.UWP.VC.BuildTools
- Microsoft.VisualStudio.ComponentGroup.UWP.VC.v141.BuildTools
- Microsoft.VisualStudio.ComponentGroup.UWP.VC.v142.BuildTools

---

## Troubleshooting Windows and Build Tools containers

There are a few issues when installing Visual Studio into a Docker container.

### Troubleshoot Windows containers

The following known issues occur when you install Visual Studio Build Tools into a Windows container.

  - Pass -m 2GB (or more) when building the image. Some workloads require more memory than the default 1 GB when installed.

  - Configure Docker to use disks larger than the default 20 GB.

  - Pass --norestart on the command line. As of this writing, attempting to restart a Windows container from within the container returns ERROR_TOO_MANY_OPEN_FILES to the host.

  - If you base your image directly on mcr.microsoft.com/windows/servercore, the .NET Framework might not install properly and no install error is indicated. Managed code might not run after the install is complete. Instead, base your image on microsoft/dotnet-framework:4.7.1 or later. As an example, you might see an error when building with MSBuild that's similar to the following:

		C:\BuildTools\MSBuild\15.0\bin\Roslyn\Microsoft.CSharp.Core.targets(84,5): error MSB6003: The specified task executable "csc.exe" could not be run. Could not load file or assembly 'System.IO.FileSystem, Version=4.0.1.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a' or one of its dependencies. The system cannot find the file specified.
