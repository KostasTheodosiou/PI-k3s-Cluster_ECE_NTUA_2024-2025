# Script Descriptions

## `chmod-vmlinuz.sh`

This script was used to correct read permissions on the executable that contains the Linux kernel.  
**Note:** This script is likely no longer needed, as the issue has been resolved with `zzz-chmod-vmlinuz.sh`.

---

## `power_cycle_pi.sh`

A one-command tool to **restart clients** that connect to the network switch and interface with the PoE (Power over Ethernet) power of those devices.

Example usage:

```bash
./power_cycle_pi.sh green3
```
