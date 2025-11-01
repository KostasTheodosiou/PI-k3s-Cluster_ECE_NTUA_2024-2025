

# 🐳 Flask LLM App – Kubernetes Deployment

This directory contains all manifests needed to deploy a **Flask-based Large Language Model (LLM) application** on a Raspberry Pi k3s cluster.

Included resources:

* **Deployments** – Single-node and multi-node configurations
* **Services** – NodePort and LoadBalancer options
* **Persistent Volumes** – NFS-backed shared storage
* **MetalLB** – Layer 2 load balancing

---

## 🗂️ Repository Structure

| File Name                             | Description                                                       |
| ------------------------------------- | ----------------------------------------------------------------- |
| **`flask-deployment-local.yaml`**     | Single-node / local ARM64 Pi deployment                           |
| **`flask-deployment-multi.yaml`**     | Multi-node deployment (16 replicas with anti-affinity)            |
| **`flask-service-nodeport.yaml`**     | NodePort service exposing Flask app on port `30500`               |
| **`flask-service-loadbalancer.yaml`** | LoadBalancer service for MetalLB                                  |
| **`nfs-pv-pvc.yaml`**                 | PersistentVolume and PersistentVolumeClaim for NFS shared storage |
| **`metallb-config.yaml`**             | MetalLB IP pool and Layer 2 advertisement configuration           |

---


All Kubernetes manifests in this directory can be deployed with the command:

```bash
sudo kubectl apply -f <filename>.yaml
```

---

## 🚀 Flask App Deployment (Single-Node / Local)

* **Deployment (`apps/v1`)**

  * `replicas: 1` → Deploys a single pod for local testing.
  * `nodeSelector.kubernetes.io/hostname: ubuntu` → Forces the pod to run on a specific node (useful for ARM64 nodes).

* **Container Settings**

  * `image: newmyapp:arm64` → Flask application container.
  * `imagePullPolicy: IfNotPresent` → Uses local image if available.
  * `ports.containerPort: 5000` → Flask internal port.

* **Environment Variables**

  * `LLM_MODEL_DIR: /models` → Folder for model files.

* **Volume Mounts**

  * Mounts host directory `/mnt` into `/models` inside the container for persistent data.

* **Service (NodePort)**

  * Exposes the pod externally on port `30500`.
  * `selector.app: flask-app` → Routes traffic to the correct pod.

---

## 🚀 Flask App Deployment (Multi-Node / 16 Replicas)

* **`replicas: 16`** → High availability with multiple pods.

* **`selector.matchLabels.app` & `template.metadata.labels.app`** → Ensure Deployment manages the correct pods.

* **`affinity.podAntiAffinity`** → Spreads pods across nodes (`topologyKey: kubernetes.io/hostname`).

* **Container `name: flask-app`** → Main application container.

* **`image: 192.168.2.3:5000/flask-llm-app`** → Private registry image, pulled always.

* **`ports.containerPort: 5000`** → Exposes Flask internally.

* **Environment Variables**

  * `LLM_MODEL_DIR: /models/models` → Model folder inside container.
  * `NODE_NAME` → Dynamically set to the node running the pod.

* **Volumes**

  * `volumeMounts` → Mounts `models-volume` to `/models`.
  * `volumes` → Uses `PersistentVolumeClaim` `models-pvc` for shared storage.

---

## 🌐 Flask App Service (NodePort)

* **`kind: Service`** → Exposes pods to network traffic.
* **`metadata.name: flask-app-service`** → Service name.
* **`spec.type: NodePort`** → Exposes the service externally on all nodes.
* **`selector.app: flask-app`** → Routes traffic to pods with label `app: flask-app`.
* **Ports:**

  * `port: 5000` → Cluster-internal service port.
  * `targetPort: 5000` → Pod port to forward traffic to.
  * `nodePort: 30500` → External port for node access.

---

## 🌐 Flask App Service (LoadBalancer)

* **`kind: Service`** → Exposes pods externally.
* **`metadata.name: flask-service`** → Service name.
* **`metadata.namespace: default`** → Namespace of the service.
* **`spec.type: LoadBalancer`** → Requests an external IP via MetalLB.
* **`spec.externalTrafficPolicy: Cluster`** → Distributes traffic across all pods.
* **`selector.app: flask-app`** → Routes traffic to the correct pods.
* **Ports:**

  * `port: 5000` → Service listens externally.
  * `targetPort: 5000` → Forwarded to pod.

---

## 💾 Persistent Volume & Claim (NFS Storage)

* **PersistentVolume (`models-pv`)**

  * `capacity: 20Gi` → Storage size.
  * `accessModes: ReadWriteMany` → Shared across multiple pods.
  * `persistentVolumeReclaimPolicy: Retain` → Data persists after PVC deletion.
  * `nfs.server: 192.168.2.3` & `nfs.path: /mnt/nfs_share` → NFS server configuration.

* **PersistentVolumeClaim (`models-pvc`)**

  * Requests 20Gi storage from PV.
  * `accessModes: ReadWriteMany` → Matches PV access mode.

* **Usage:** Mounted in pods (`/models`) for model storage.

---

## ⚡ MetalLB Configuration (Layer 2)

* **IPAddressPool (`my-pool`)**

  * Defines assignable IPs (`192.168.2.2`).
  * Namespace: `metallb-system`.

* **L2Advertisement (`my-l2adv`)**

  * References `my-pool` for Layer 2 advertisement.

* **Purpose:** Enables `LoadBalancer` services to get an external IP in a Layer 2 network without a cloud provider.
