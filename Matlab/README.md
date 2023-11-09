# MatLab ConfigMgr PowerShell Installer

MatLab VHD and PowerShell Installer

Prepping the VHD
1. Get license key string to add to the installer_input.txt.
	1. fileInstallationKey=<Key from software services>
2. Usually take old installer_input.txt and just modify it to current version with key, log path, and licensepath.  If this is not possible, the follow changes are made to the file:
	1. destinationFolder=C:\Program Files\MATLAB\<Version>
	2. fileInstallationKey=<Key from software services>
	3. agreeToLicense=yes
	4. outputFile=C:\Windows\Temp\MATLAB-<version>.log
	5. mode=silent
	6. licensePath=C:\Program Files\MATLAB\<version>\license.dat
	7. lmgrFiles=false
	8. lmgrService=false
	9. desktopShortcut=false
	10. startMenuShortcut=true
	11. createAccelTask=false
	12. enableLNU=no
3. Copy old uninstaller_input.txt from previous year and put it in the root folder, if not, add following lines:
	1. outputFile=C:\Windows\Temp\MATLAB_Uninstall.log
	2. mode=silent
	3. prefs=True
4. Copy license.dat to main directory
	1. Add in license server name and IP/Ports
6. After this, create the below VHD

# Creating a VHD for installation

https://github.com/winadminsdotorg/SystemCenterConfigMgr/tree/master/Applications/Scripts/VHD_Application_Install

7. Create the VHD (instructions also from the VHD_Application_Install link above)
	1. Run Computer Management and select the Disk Management node.
	2. Select Action -> Create VHD
	3. Browse to the folder the rest of the files are going into and call the file the MATLAB_version.vhd
	4. Set the VHD Size by looking at the size of the installer. 2022a was 9.46 gigs, so setting it to 10 gigs but be aware that the formatted size is a little smaller than the raw size.
	5. Use VHD. The included script assumes .VHD files.
	6. Dynamic disk so that it expands to exactly the size needed.
	7. Once created, the VHD will attach in the Disk Management window.
	8. Right click its row header(the "Disk 3, Unknown, Not Initialized" box) and select "Initialize Disk". MBR is fine unless you have a specific need for GPT.
	9. Right click the unallocated space and create / format a new Volume. Default setting should be fine
	10. In Windows Explorer, copy to the root of the mounted VHD
		1. Installation source files
		2. license.dat
		3. installer_input.txt
	11. Right click and "Eject" when finished.
8. On a test box, run PS_VHD_Install.ps1 to test the install process

# Creating the deploy

1. When creating a deployment type, be sure to set run as 32bit on a 64bit machine. Install is a Java based installer and seems to run out of memory and give java errors if you don't.