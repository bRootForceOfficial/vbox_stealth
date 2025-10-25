# VirtualBox Stealth Configuration Scripts

Bash scripts to configure VirtualBox VMs with realistic hardware identifiers to reduce detectability.

## ⚠️ Disclaimer

**My boy Big Claude helped me out with these scripts so they are probably jank.** However, they will get you significantly further than running VBoxCloak.ps1 alone because they modify the VM's hardware configuration at the hypervisor level *before* the OS boots, making the guest OS believe it has different hardware than what VirtualBox supplies by default.

## 📋 What's Included

- **`vbox_stealth.sh`** - Main configuration script that applies stealth settings
- **`undo.sh`** - Reverts all changes and restores VirtualBox defaults

## 🎯 Best Results

These scripts work best when combined with **[VBoxCloak by Kyle Cucci](https://github.com/d4rksystem/VBoxCloak)**. 

**Recommended workflow:**
1. Power off your VM completely
2. Run `vbox_stealth.sh` to configure hardware identifiers
3. Start the VM
4. Run VBoxCloak.ps1 inside the guest OS to clean up registry entries and artifacts

This two-pronged approach addresses detection vectors at both the hypervisor level (hardware) and the guest OS level (software artifacts).

## 💻 Windows Users - Running Bash Scripts

Since these are bash scripts but VirtualBox runs on Windows, you'll need a bash environment. Here are the easiest options:

### Option 1: Git Bash (Recommended - Easiest)

1. **Install Git for Windows** from [git-scm.com](https://git-scm.com/download/win)
   - During installation, make sure "Git Bash" is selected
2. **Open Git Bash** (search for it in Start menu)
3. **Navigate to your scripts folder:**
   ```bash
   cd /c/path/to/your/scripts
   ```
4. **Run the scripts** as shown in the Usage section below

### Option 2: WSL (Windows Subsystem for Linux)

1. **Install WSL** (PowerShell as Admin):
   ```powershell
   wsl --install
   ```
2. **Restart your computer** when prompted
3. **Open Ubuntu** (or your chosen distro) from Start menu
4. **Navigate to Windows files:**
   ```bash
   cd /mnt/c/path/to/your/scripts
   ```
5. **Run the scripts** as shown in the Usage section below

### Option 3: Cygwin

1. Download and install [Cygwin](https://www.cygwin.com/)
2. Ensure `bash` package is selected during installation
3. Open Cygwin terminal and run scripts

**Note:** VBoxManage must be in your PATH. If you get "VBoxManage not found" errors:
```bash
# Add to PATH (Git Bash/WSL)
export PATH="$PATH:/c/Program Files/Oracle/VirtualBox"

# Or use full path
"/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" list vms
```

## 🚀 Usage

### Initial Setup

```bash
# Make scripts executable
chmod +x vbox_stealth.sh undo.sh

# Apply stealth configuration (Dell preset)
./vbox_stealth.sh "VM Name" dell

# Available presets: dell, hp, lenovo, asus
./vbox_stealth.sh "Windows 10" hp
```

### Reverting Changes

```bash
# Restore VirtualBox defaults
./undo.sh "VM Name"
```

## 🔧 What Gets Modified

The script configures the following to mimic real hardware:

### BIOS/SMBIOS Information
- BIOS vendor, version, and release date
- System vendor and product names
- Motherboard details and serials
- Chassis information

### Hardware Identifiers
- Randomized serial numbers for system, board, and chassis
- Realistic disk model and serial numbers
- MAC address changed from VirtualBox range (08:00:27:xx:xx:xx)

### CPU Configuration
- Removes hypervisor CPUID leaves
- Disables paravirtualization provider
- Masks virtualization detection flags

### Timing & Performance
- TSC tied to execution
- Disabled time synchronization
- Large pages enabled

### ACPI Tables
- OEM IDs changed to match manufacturer presets

## 📝 Requirements

- VirtualBox 7.x (tested on 7.2.2)
- VM must be **powered off** before running scripts
- `uuidgen` or `/proc/sys/kernel/random/uuid` for UUID generation
- Bash shell

## ⚙️ Hardware Presets

| Preset | System | BIOS | Typical Use Case |
|--------|--------|------|------------------|
| `dell` | OptiPlex 7090 | American Megatrends | Corporate desktop |
| `hp` | EliteDesk 800 G6 | HP | Enterprise workstation |
| `lenovo` | ThinkCentre M720q | Lenovo | Small form factor PC |
| `asus` | PRIME B560M-A | American Megatrends | Custom build |

## 🛡️ Additional Steps (Important!)

After running the script, you should:

1. **Start the VM** and run VBoxCloak.ps1:
   ```powershell
   PowerShell -ExecutionPolicy Bypass -File VBoxCloak.ps1 -all
   ```

2. **Remove VirtualBox Guest Additions** completely

3. **Disable in VirtualBox settings:**
   - Shared folders
   - Bidirectional clipboard
   - Drag and drop

4. **Verify in Device Manager:**
   - No VirtualBox devices should be visible
   - Remove any "Unknown devices" related to VBox

5. **Test with detection tools:**
   - al-khaser
   - pafish
   - Ensure Guest Additions are removed first

## 🚨 Known Limitations

Some detections will likely remain due to VirtualBox's architecture:

- WMI class instance checks (Win32_PhysicalMemory, etc.)
- Thermal zone information (MSAcpi_ThermalZoneTemperature)
- Some CIM sensor classes
- Power management capability differences
- Hardware timing variations

These would require kernel-mode drivers or VirtualBox source code modifications to address.

## 🔄 Backup & Recovery

The `undo.sh` script automatically creates backups before making changes:
- Backups stored in `/tmp/vbox_backups/`
- Named with timestamp: `vbox_backup_VMName_YYYYMMDD_HHMMSS.txt`
- Contains all original settings for manual restoration if needed

## 📚 Resources

- [VBoxCloak](https://github.com/d4rksystem/VBoxCloak) - Companion PowerShell script for guest OS cleanup
- [VirtualBox Manual](https://www.virtualbox.org/manual/) - Official documentation
- [al-khaser](https://github.com/LordNoteworthy/al-khaser) - VM detection testing tool
- [pafish](https://github.com/a0rtega/pafish) - Paranoid Fish VM detection

## ⚖️ Legal Notice

These scripts are for **educational and legitimate testing purposes only**. Users are responsible for ensuring compliance with applicable laws and terms of service. Bypassing security measures or evading detection for malicious purposes is illegal.

## 📄 License

MIT License - Feel free to use, modify, and distribute.

---

**Note:** Always test in a non-production environment first. VM detection is a cat-and-mouse game, and no solution is 100% foolproof.
