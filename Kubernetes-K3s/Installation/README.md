# Installation of Kubernetes Orchestration Software – K3s

The installation of **K3s** is straightforward, but our setup requires certain configurations to ensure compatibility with the storage system and container runtime environment.

---

## 1. Background

When **K3s** (or Kubernetes) runs a container, it uses the **container runtime** `containerd`, which relies on **overlay filesystems** (such as `overlayfs`) to manage container layers.

However, **NFS does not fully support `overlayfs`** requirements.

---

## 2. The Solution: `fuse-overlayfs`

`fuse-overlayfs` is a **userspace implementation** of the Linux **OverlayFS** filesystem.  
It provides the same functionality as the kernel’s OverlayFS but runs **in user space** using **FUSE (Filesystem in Userspace)**.

This makes it possible for `containerd` to function correctly on top of NFS or other filesystems that don’t natively support OverlayFS.

---

## 3. Installation of `fuse-overlayfs`

`fuse-overlayfs` must be installed on **all devices running K3s**, including both **worker** and **master** nodes.

### Manual Installation

```bash
sudo apt install fuse-overlayfs
```

### Automated Installation (Using Ansible)

Installation on all worker nodes has been automated using **Ansible** with the `install-fuse.yml` playbook.

Run the following command:

```bash
ansible-playbook -i inventory.ini install-fuse.yml
```

---

## 4. Installing K3s on the Master Node

The installation of K3s on the master node is straightforward using the official installation script provided by Rancher:

```bash
curl -sfL https://get.k3s.io | sh -s - server --snapshotter=fuse-overlayfs
```

* `server` → Specifies that this node is the **K3s master (control plane)**
* `--snapshotter=fuse-overlayfs` → Configures K3s to use **fuse-overlayfs** as the container snapshotter

---

## 5. installing K3s on Client Nodes

In order to install k3s on client Nodes, we need a token that was generated on first install of the k3s server obtained by:

sudo cat /var/lib/rancher/k3s/server/node-token

Next the k3s-agent can be installed in similar fashion to the master, providing however certain environment variables:

Environment Variables:
1. K3S_NODE_NAME={{ inventory_hostname }}
Sets the node name to the Ansible inventory hostname
2. K3S_URL={{ k3s_url }}
Points to the K3s server API endpoint
https://192.168.2.2:6443 - Where the K3s control plane is running
3. K3S_TOKEN={{ k3s_token }}
Authentication token to join the cluster
4. INSTALL_K3S_EXEC="..."
--snapshotter=fuse-overlayfs:
--kubelet-arg=runtime-request-timeout=5m:
--kubelet-arg=node-status-update-frequency=10s:
5. INSTALL_K3S_SKIP_SSL_VERIFY=true
Skips SSL certificate verification

Install using: 
./install-k3s.sh

