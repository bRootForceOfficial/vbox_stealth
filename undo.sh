#!/bin/bash
# VirtualBox Configuration Undo Script

set -eo pipefail

VM="${1:-}"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_info() { echo -e "${YELLOW}[INFO]${NC} $1"; }
log_section() { echo -e "${CYAN}[*]${NC} $1"; }

# Validate inputs
if [ -z "$VM" ]; then
	echo "Usage: $0 \"VM Name\""
	exit 1
fi

# Check if VBoxManage exists
if ! command -v VBoxManage &> /dev/null; then
	log_error "VBoxManage not found. Please install VirtualBox."
	exit 1
fi

VBOXMANAGE="VBoxManage"

# Check if VM exists
if ! "$VBOXMANAGE" showvminfo "$VM" &> /dev/null; then
	log_error "VM '$VM' not found."
	exit 1
fi

# Check VM state
check_vm_state() {
	local state
	state=$("$VBOXMANAGE" showvminfo "$VM" --machinereadable | grep "^VMState=" | cut -d'"' -f2)
	if [ "$state" != "poweroff" ] && [ "$state" != "aborted" ]; then
		log_error "VM must be powered off. Current state: $state"
		exit 1
	fi
}

generate_random_uuid() {
	if command -v uuidgen &> /dev/null; then
		uuidgen
	else
		printf '%08x-%04x-%04x-%04x-%012x\n' \
			$((RANDOM * RANDOM)) $RANDOM $((RANDOM | 0x4000)) \
			$((RANDOM | 0x8000)) $((RANDOM * RANDOM * RANDOM))
	fi
}

# Backup current settings
backup_settings() {
	local backup_dir="/tmp/vbox_backups"
	mkdir -p "$backup_dir"
	
	local backup_file="$backup_dir/vbox_backup_${VM// /_}_$(date +%Y%m%d_%H%M%S).txt"
	log_info "Backing up current settings to: $backup_file"
	
	{
		echo "=== VM Configuration Backup ==="
		echo "Timestamp: $(date)"
		echo "VM Name: $VM"
		echo ""
		echo "=== Hardware UUID ==="
		"$VBOXMANAGE" showvminfo "$VM" --machinereadable | grep "^hardwareuuid="
		echo ""
		echo "=== MAC Addresses ==="
		"$VBOXMANAGE" showvminfo "$VM" --machinereadable | grep "^macaddress"
		echo ""
		echo "=== Paravirtualization ==="
		"$VBOXMANAGE" showvminfo "$VM" --machinereadable | grep "^paravirtprovider="
		echo ""
		echo "=== Graphics Controller ==="
		"$VBOXMANAGE" showvminfo "$VM" --machinereadable | grep "^graphicscontroller="
		echo ""
		echo "=== All Extra Data ==="
		"$VBOXMANAGE" getextradata "$VM" enumerate
	} > "$backup_file"
	
	log_success "Backup saved to: $backup_file"
}

undo_identifiers() {
	log_section "Reverting to VirtualBox Defaults"
	check_vm_state
	backup_settings

	log_info "Removing all custom configuration..."
	
	# Remove all VBoxInternal extradata
	"$VBOXMANAGE" getextradata "$VM" enumerate 2>/dev/null | grep "^Key: VBoxInternal" | while read -r line; do
		local key=$(echo "$line" | sed 's/^Key: \(.*\), Value:.*/\1/')
		if [ -n "$key" ]; then
			"$VBOXMANAGE" setextradata "$VM" "$key" "" 2>/dev/null || true
		fi
	done

	# Reset MAC addresses
	log_info "Resetting network adapters..."
	for i in {1..8}; do
		"$VBOXMANAGE" modifyvm "$VM" --macaddress${i} auto 2>/dev/null || true
	done

	# Reset UUID
	log_info "Generating new UUID..."
	local new_uuid=$(generate_random_uuid)
	"$VBOXMANAGE" modifyvm "$VM" --hardware-uuid "$new_uuid"

	# Restore paravirtualization
	"$VBOXMANAGE" modifyvm "$VM" --paravirtprovider default 2>/dev/null || true

	# Restore graphics
	"$VBOXMANAGE" modifyvm "$VM" --graphicscontroller vboxsvga 2>/dev/null || true

	# Restore CPU settings
	"$VBOXMANAGE" modifyvm "$VM" --cpu-execution-cap 100 2>/dev/null || true
	"$VBOXMANAGE" modifyvm "$VM" --hpet on 2>/dev/null || true

	log_success "VM reverted to VirtualBox defaults"
}

undo_identifiers
