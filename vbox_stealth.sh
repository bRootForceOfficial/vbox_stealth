#!/bin/bash
#################################################
# VirtualBox VM Stealth Configuration - Tested on VBOX 7.2.2
# Run BEFORE starting the VM (VM must be powered off)
# Usage: ./vbox_stealth.sh "VM_NAME" [dell|hp|lenovo|asus]
#################################################

VM_NAME="$1"
PRESET="${2:-dell}"

echo "================================================================"
echo "VirtualBox VM Stealth Configuration - Tested on VBOX v7.2.2"
echo "Tested with Windows 10 VM, may work for other stuff too idk"
echo "================================================================"
echo ""

# Check arguments
if [ -z "$VM_NAME" ]; then
    echo "Usage: $0 \"VM_NAME\" [dell|hp|lenovo|asus]"
    echo "Example: $0 \"Windows 10\" dell"
    echo ""
    echo "Available VMs:"
    VBoxManage list vms
    exit 1
fi

# Check if VBoxManage exists
if ! command -v VBoxManage &> /dev/null; then
    echo "Error: VBoxManage not found"
    exit 1
fi

# Check if VM exists
if ! VBoxManage showvminfo "$VM_NAME" &>/dev/null; then
    echo "Error: VM '$VM_NAME' not found"
    echo ""
    echo "Available VMs:"
    VBoxManage list vms
    exit 1
fi

echo "VM: $VM_NAME"
echo "Preset: $PRESET"
echo ""

# Generate random serials with more realistic formats
SYSTEM_SERIAL=$(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 10 | head -n 1)
BOARD_SERIAL=$(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 8 | head -n 1)
CHASSIS_SERIAL=$(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 8 | head -n 1)
DISK_SERIAL=$(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 20 | head -n 1)

# Preset configurations
case "$PRESET" in
    dell)
        BIOS_VENDOR="American Megatrends Inc."
        BIOS_VERSION="2.18.0"
        BIOS_RELEASE_DATE="12/15/2022"
        SYSTEM_VENDOR="Dell Inc."
        SYSTEM_PRODUCT="OptiPlex 7090"
        BOARD_PRODUCT="0J42H4"
        DISK_MODEL="Samsung SSD 870 EVO 500GB"
        ;;
    hp)
        BIOS_VENDOR="HP"
        BIOS_VERSION="T83 v02.08"
        BIOS_RELEASE_DATE="10/28/2022"
        SYSTEM_VENDOR="HP"
        SYSTEM_PRODUCT="HP EliteDesk 800 G6"
        BOARD_PRODUCT="872E"
        DISK_MODEL="WDC WD5000AAKX-60U6AA0"
        ;;
    lenovo)
        BIOS_VENDOR="LENOVO"
        BIOS_VERSION="M1AKT59A"
        BIOS_RELEASE_DATE="11/03/2022"
        SYSTEM_VENDOR="LENOVO"
        SYSTEM_PRODUCT="ThinkCentre M720q"
        BOARD_PRODUCT="3106SDK0J40705"
        DISK_MODEL="Samsung SSD 860 EVO 500GB"
        ;;
    asus)
        BIOS_VENDOR="American Megatrends Inc."
        BIOS_VERSION="1401"
        BIOS_RELEASE_DATE="09/20/2022"
        SYSTEM_VENDOR="ASUSTeK COMPUTER INC."
        SYSTEM_PRODUCT="PRIME B560M-A"
        BOARD_PRODUCT="PRIME B560M-A"
        DISK_MODEL="Samsung SSD 980 PRO 500GB"
        ;;
    *)
        echo "Unknown preset: $PRESET, using dell"
        PRESET="dell"
        BIOS_VENDOR="American Megatrends Inc."
        BIOS_VERSION="2.18.0"
        BIOS_RELEASE_DATE="12/15/2022"
        SYSTEM_VENDOR="Dell Inc."
        SYSTEM_PRODUCT="OptiPlex 7090"
        BOARD_PRODUCT="0J42H4"
        DISK_MODEL="Samsung SSD 870 EVO 500GB"
        ;;
esac

echo "================================================================"
echo "DMI/SMBIOS BIOS Information"
echo "================================================================"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiBIOSVendor" "$BIOS_VENDOR"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiBIOSVersion" "$BIOS_VERSION"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiBIOSReleaseDate" "$BIOS_RELEASE_DATE"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiBIOSReleaseMajor" 5
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiBIOSReleaseMinor" 12
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiBIOSFirmwareMajor" 5
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiBIOSFirmwareMinor" 12
echo "✓ BIOS information configured (Date: $BIOS_RELEASE_DATE)"
echo ""

echo "================================================================"
echo "DMI/SMBIOS System Information"
echo "================================================================"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiSystemVendor" "$SYSTEM_VENDOR"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiSystemProduct" "$SYSTEM_PRODUCT"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiSystemVersion" "1.0"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiSystemSerial" "$SYSTEM_SERIAL"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiSystemSKU" "0A12"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiSystemFamily" "Desktop"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiSystemUuid" "$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || echo '00000000-0000-0000-0000-000000000000')"
echo "✓ System information configured"
echo ""

echo "================================================================"
echo "DMI/SMBIOS Board Information"
echo "================================================================"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiBoardVendor" "$SYSTEM_VENDOR"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiBoardProduct" "$BOARD_PRODUCT"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiBoardVersion" "A00"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiBoardSerial" "$BOARD_SERIAL"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiBoardAssetTag" "Default"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiBoardLocInChass" "Default"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiBoardBoardType" 10
echo "✓ Board information configured"
echo ""

echo "================================================================"
echo "DMI/SMBIOS Chassis Information"
echo "================================================================"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiChassisVendor" "$SYSTEM_VENDOR"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiChassisVersion" "1.0"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiChassisSerial" "$CHASSIS_SERIAL"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiChassisAssetTag" "Default"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/pcbios/0/Config/DmiChassisType" 3
echo "✓ Chassis information configured"
echo ""

echo "================================================================"
echo "ACPI Configuration"
echo "================================================================"
# Change ACPI OEM IDs to match real hardware
case "$PRESET" in
    dell)
        VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/acpi/0/Config/AcpiOemId" "DELL  "
        ;;
    hp)
        VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/acpi/0/Config/AcpiOemId" "HPQOEM"
        ;;
    lenovo)
        VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/acpi/0/Config/AcpiOemId" "LENOVO"
        ;;
    asus)
        VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/acpi/0/Config/AcpiOemId" "ALASKA"
        ;;
esac

VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/acpi/0/Config/AcpiCreatorId" "INTL"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/acpi/0/Config/AcpiCreatorRev" "0x20210331"

echo "✓ ACPI tables configured"
echo "⚠️  Note: ACPI VBOX__ entries require guest-side registry cleanup"
echo ""

echo "================================================================"
echo "Disk Configuration (AHCI/IDE/NVMe)"
echo "================================================================"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/ahci/0/Config/Port0/ModelNumber" "$DISK_MODEL"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/ahci/0/Config/Port0/SerialNumber" "$DISK_SERIAL"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/ahci/0/Config/Port0/FirmwareRevision" "SVT02B6Q"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/piix3ide/0/Config/PrimaryMaster/ModelNumber" "$DISK_MODEL"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/piix3ide/0/Config/PrimaryMaster/SerialNumber" "$DISK_SERIAL"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/piix3ide/0/Config/PrimaryMaster/FirmwareRevision" "01.01A01"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/nvme/0/Config/ModelNumber" "$DISK_MODEL"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/nvme/0/Config/SerialNumber" "$DISK_SERIAL"
echo "✓ Disk information configured"
echo ""

echo "================================================================"
echo "CPU Configuration"
echo "================================================================"
# Set paravirtualization provider to none to hide hypervisor presence
VBoxManage modifyvm "$VM_NAME" --paravirtprovider none

# Remove CPUID leaves that expose hypervisor
VBoxManage modifyvm "$VM_NAME" --cpuid-set 0x00000001 0x000306a9 0x00020800 0x7fbae3ff 0xbfebfbff

# Remove hypervisor CPUID leaves completely
VBoxManage modifyvm "$VM_NAME" --cpuid-remove 0x40000000
VBoxManage modifyvm "$VM_NAME" --cpuid-remove 0x40000001
VBoxManage modifyvm "$VM_NAME" --cpuid-remove 0x40000002  
VBoxManage modifyvm "$VM_NAME" --cpuid-remove 0x40000003
VBoxManage modifyvm "$VM_NAME" --cpuid-remove 0x40000004
VBoxManage modifyvm "$VM_NAME" --cpuid-remove 0x40000005
VBoxManage modifyvm "$VM_NAME" --cpuid-remove 0x40000006

# Remove extended CPUID leaves that might expose virtualization
VBoxManage modifyvm "$VM_NAME" --cpuid-remove 0x80000001

echo "✓ CPUID leaves masked"
echo ""

echo "================================================================"
echo "Timing and Performance"
echo "================================================================"
# Tie TSC to execution to prevent timing-based detection
VBoxManage setextradata "$VM_NAME" "VBoxInternal/TM/TSCTiedToExecution" 1

# Enable large pages for more realistic timing
VBoxManage modifyvm "$VM_NAME" --largepages on

# Disable time sync to prevent detection via timing analysis
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled" 1

echo "✓ Timing optimizations applied"
echo ""

echo "================================================================"
echo "Network Configuration"
echo "================================================================"
# Change MAC address to avoid VirtualBox range (08:00:27:xx:xx:xx)
# Generate a realistic Intel MAC address
RANDOM_MAC=$(printf '00:1A:2B:%02X:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
VBoxManage modifyvm "$VM_NAME" --macaddress1 $(echo $RANDOM_MAC | tr -d ':')
echo "✓ MAC address changed to: $RANDOM_MAC"
echo ""

echo "================================================================"
echo "Additional Stealth Settings"
echo "================================================================"

# Disable nested HW virtualization (can be used for detection)
VBoxManage modifyvm "$VM_NAME" --nested-hw-virt off

# Set realistic firmware type (most modern systems use EFI)
# Note: This may require reinstalling the OS if changing from BIOS to EFI
CURRENT_FIRMWARE=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "firmware=" | cut -d'"' -f2)
echo "Current firmware: $CURRENT_FIRMWARE"
echo "⚠️  Consider using --firmware efi for more realistic modern hardware emulation"
echo "   (requires OS reinstall if switching from BIOS)"
echo ""

echo "================================================================"
echo "Configuration Summary"
echo "================================================================"
echo "System Vendor:     $SYSTEM_VENDOR"
echo "System Product:    $SYSTEM_PRODUCT"
echo "BIOS Vendor:       $BIOS_VENDOR"
echo "BIOS Version:      $BIOS_VERSION"
echo "BIOS Date:         $BIOS_RELEASE_DATE"
echo "System Serial:     $SYSTEM_SERIAL"
echo "Disk Model:        $DISK_MODEL"
echo "MAC Address:       $RANDOM_MAC"
echo "Paravirt Provider: none"
echo "TSC Mode:          Tied to execution"
echo ""

echo "================================================================"
echo "IMPORTANT: Next Steps"
echo "================================================================"
echo ""
echo "1. START THE VM"
echo ""
echo "2. RUN VBoxCloak.ps1 inside Windows:"
echo "   PowerShell -ExecutionPolicy Bypass -File VBoxCloak.ps1 -all"
echo ""
echo "3. DISABLE/REMOVE these features in Windows:"
echo "   • VirtualBox Guest Additions (uninstall completely)"
echo "   • Shared folders"
echo "   • Bidirectional clipboard"
echo "   • Drag and drop"
echo ""
echo "4. VERIFY in Device Manager:"
echo "   • No VirtualBox devices should be visible"
echo "   • Remove any 'Unknown devices' related to VBox"
echo ""
echo "5. TEST with detection tools:"
echo "   • al-khaser"
echo "   • pafish"
echo "   • Ensure Guest Additions are fully removed first"
echo ""
echo "================================================================"
echo "Known Limitations (Cannot be Fixed)"
echo "================================================================"
echo ""
echo "The following detections will likely remain:"
echo "• WMI class instance checks (Win32_PhysicalMemory, etc.)"
echo "• Thermal zone information (MSAcpi_ThermalZoneTemperature)"
echo "• Some CIM sensor classes"
echo "• Power management capability differences"
echo "• Hardware timing variations"
echo ""
echo "These are inherent to VirtualBox's architecture and would"
echo "require kernel-mode drivers or source code modifications."
echo ""
echo "================================================================"
