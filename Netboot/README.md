# Required Services for Netbooting

In order for netbooting to **work**, three services need to be up and running:

- `isc-dhcp-server`
- `tftp-hpa`
- `nfs-kernel-server`

## Enable Services at Boot

To ensure these services start automatically when the system boots, run:

```bash
sudo systemctl enable isc-dhcp-server
sudo systemctl enable tftp-hpa
sudo systemctl enable nfs-kernel-server
```

## Restart services

Restart if service is off or we have made config changes

```bash
sudo systemctl restart isc-dhcp-server
sudo systemctl restart tftp-hpa
sudo systemctl restart nfs-kernel-server
```
