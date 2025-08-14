# Shell and PowerShell Scripts
This repository contains a collection of useful shell and PowerShell scripts that can be used for various purposes.

## Installation
### Install custom PowerShell profile
#### Install via curl
```
curl https://github.com/fuji97/scripts/blob/main/Microsoft.PowerShell_profile.ps1 -o $PROFILE
```

### Windows Sandbox Custom Startup

You can set up a custom startup for Windows Sandbox using the provided scripts and configuration files in `sandbox/Startup Scripts/` and `sandbox/Sandbox Configurations/`.

#### Steps

1. **Create a shared folder:**
    - For example: `C:/Users/USER/SandboxShare`
  
2. **Copy all the scripts from `sandbox/` to the newly created shared folder:**
    - `General Scripts/`, `Installer Scripts/` and `SandboxStartup.ps1`. You can ignore `Sandbox Configurations/`

3. **Copy or edit a Sandbox configuration file:**
	 - Use one of the provided `.wsb` files in `sandbox/Sandbox Configurations/` (e.g., `MyDefaultSandbox.wsb`, `UseGoogleDNS.wsb`).
	 - You can edit these files to customize your sandbox environment.

4. **Update the Sandbox configuration file:**
	 - Replace the `<HostFolder>` in your your `.wsb` configuration to your newly created shared folder:

		 ```xml
		 <!--  Map a folder on your main system to appear within the sandbox  -->
        <MappedFolders>
            <!-- Desktop "HostShared" Folder. Put startup script and other useful scripts into. -->
            <MappedFolder>
                <HostFolder>C:\Users\USER\SandboxShare</HostFolder> <!-- Update the HostFolder path to the one on your real computer that will be shared with the Sandbox -->
            </MappedFolder>
        </MappedFolders>
		 ```

5. **Launch the sandbox:**
	 - Double-click your `.wsb` file to start the sandbox with your custom startup script.

## Credits
- [ThioJoe/Windows-Sandbox-Tools](https://github.com/ThioJoe/Windows-Sandbox-Tools)