# 🪒 Shaving Yaks 🐑

🧪 An over-engineered home lab. For fun and... 🏡

## Hardware

### Cluster Board

The cluster is built on the [Turing Pi 2][turing-pi], a mini ITX board with a
built-in Ethernet switch. The Turing Pi 2 can host up to four computing modules
including Raspberry Pi CM4 and Nvidia Jetson.

### Case

The Turing Pi board is installed in the [Thermaltake Tower 100][tower-100]
(Snow) chassis.

### Compute Modules

The cluster consists of the following compute modules:

| Node | Device                              | Processor                           | Speed   | Cores | RAM  | Storage   |
| ---- | ----------------------------------- | ----------------------------------- | ------- | ----- | ---- | --------- |
| 1    | [Turing Pi RK1][turing-rk1]         | ARM v8 (4×Cortex-A76, 4×Cortex-A55) | 2.4 GHz | 8     | 16GB | 32GB eMMC |
| 2    | [Raspberry Pi CM4008032][cm4008032] | ARM v8 (Cortex-A72)                 | 1.5GHz  | 4     | 8GB  | 32GB eMMC |
| 1    | [Turing Pi RK1][turing-rk1]         | ARM v8 (4×Cortex-A76, 4×Cortex-A55) | 2.4 GHz | 8     | 16GB | 32GB eMMC |
| 4    | [Raspberry Pi CM4008032][cm4008032] | ARM v8 (Cortex-A72)                 | 1.5GHz  | 4     | 8GB  | 32GB eMMC |

## Operating System

The OS for each compute module is setup as follows:

| Node | Operating System                                  | Hostname     | IP Address   |
| ---- | ------------------------------------------------- | ------------ | ------------ |
| 1    | [Turing RK1 Ubuntu 22.04 (LTS)][turing-rk-ubuntu] | `yak-001`    | 192.168.5.1  |
| 2    | [Official Ubuntu 22.04 (LTS)][jammy-jellyfish]    | `yak-002`    | 192.168.5.2  |
| 3    | [Turing RK1 Ubuntu 22.04 (LTS)][turing-rk-ubuntu] | `yak-003`    | 192.168.5.3  |
| 4    | [Official Ubuntu 22.04 (LTS)][jammy-jellyfish]    | `barber-001` | 192.168.5.51 |

Configuration was completed using the files found in the `os-configuration/`
directory in this repository, using the following steps:

1. Flash the Ubuntu 22.04 Raspberry Pi image from Canonical onto the modules
   eMMC, via the [Turing Pi 2 BMC][turing-pi-bmc]. Once the flash is complete,
   power the device on bia the BMC web interface.

2. Once the module has powered on, SSH into the fresh OS install with the
   default user account and password (`ubuntu:ubuntu`):

   `ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@xxx.xxx.xxx.xxx`

   When prompted, change the password to a unique, secure value.

3. Set the hostname by editing `/etc/hostname`

4. Assign the node a reserved DHCP address (from table above) in the network.

5. Copy SSH key(s) to allow for key-based authentication to the node by running
   `ssh-copy-id -i ~/.ssh/id_ed25519.pub ubuntu@xxx.xxx.xxx.xxx`
   from the external machines that should be able to connect to the nodes.

6. Install any available updates via `apt`:

   `sudo apt update && sudo apt upgrade`

7. Format and mount the 

   ```shell
   # List block devices, verify the desired disk is sda before continuing 
   lsblk -f

   # Format the disk
   sudo mkfs -t ext4 /dev/sda

   # Verify format worked
   lsblk -f

   # Create the mount point
   sudo mkdir -p /mnt/longhorn-001

   # Get the disk UUID
   lsblk -f | grep sda

   # Edit the fstab, adding a line like this (with UUID replaced):
   # UUID=069e5955-1892-43f6-99c4-d8075887eb74   /mnt/longhorn-001   ext4   defaults   0   3
   sudo vi /etc/fstab

   # Mount the disk, verify that it worked
   sudo mount -a
   lsblk -f
   ```

5. Reboot the node. After booting verify hostname, network configuration and
   drive(s) are all working as expected.

   ```shell
   sudo reboot
   ```

## Kubernetes

The Kubernetes cluster is configured to have one node as the controller and the
remaining nodes as workers.

| Node | Hostname     | Cluster Role |
| ---- | ------------ | ------------ |
| 1    | `yak-001`    | worker       |
| 2    | `yak-002`    | worker       |
| 3    | `yak-003`    | worker       |
| 4    | `barber-001` | controller   |

### Kubernetes Installation

The cluster runs [k0s][k0s], which is an all-inclusive Kubernetes distribution
that still manages to be low friction for installation and management.

The Kubernetes setup is done via [`k0sctl`][k0sctl], a command-line tool for
bootstrapping and managing k0s clusters. Before proceeding,
[install `k0sctl`][k0sctl-install] on your local workstation.

`k0sctl` works from a configuration
file, [`k0s/cluster.yaml`][k0s-config], which describes the desired cluster and
connects to each host over SSH to configure as needed. The Kubernetes
installation is done via a single command which only takes ~2 minutes to
complete:

```shell
k0sctl apply --config k0s/cluster.yaml
```

![Demo](./k0s/demo/cluster-init.cast.gif)

Once the k0s cluster has been installed, the `k0sctl kubeconfig` command is used
to get a kubeconfig file that can be used to connect to the cluster with tools
such as `kubectl`.

```shell
k0sctl kubeconfig --config k0s/cluster.yaml > shaving-yaks.kubeconfig
```

Once this is completed, youc an connect to the cluster with most command-line
tools by passing the `--kubeconfig` flag. For example, the `kubectl` command can
now be used to verify the cluster is running:

```shell
kubectl get nodes --kubeconfig shaving-yaks.kubeconfig
```

```
NAME      STATUS   ROLES    AGE   VERSION
yak-002   Ready    <none>   1m    v1.28.4+k0s
yak-003   Ready    <none>   1m    v1.28.4+k0s
yak-004   Ready    <none>   1m    v1.28.4+k0s
```

```shell
get deployments --all-namespaces  --kubeconfig shaving-yaks.kubeconfig
```

```
NAMESPACE     NAME             READY   UP-TO-DATE   AVAILABLE   AGE
kube-system   coredns          2/2     2            2           1m
kube-system   metrics-server   1/1     1            1           1m
```

### Flux

[Flux][flux] is a set of continuous and progressive delivery solutions for
Kubernetes designed to keep clusters in sync one ore more sources of
configuration. In this case, Flux is used to adopt the [GitOps][gitops] approach
for managing all applications running in the cluster.

First, [install the Flux command-line tool][flux-install] on a local machine.
This will be used to install and configure Flux.

Then use the `flux bootstrap github` command to deploiy the Flux controllers in
the Kubernetes cluster and configures those controllers to sync the cluster
state from this GitHub repository.

> Note: This requires a [GitHub personal access token][github-pat] (PAT) which
> for use with the GitHub API.

```shell
export GITHUB_USER=tantalic
export GITHUB_TOKEN=<redacted>
export GITHUB_REPO=shaving-yaks

flux bootstrap github \
  --kubeconfig ./shaving-yaks.kubeconfig \
  --token-auth \
  --owner=$GITHUB_USER \
  --repository=$GITHUB_REPO \
  --branch=main \
  --path=kubernetes/cluster \
  --personal
```

![Demo](kubernetes/demo/flux-bootstrap.cast.gif)

To verify Flux is watching the Git repository for changes, use the `kubectl log`
commands on the `source-controller` deployment:

```shell
kubectl logs deployment/source-controller --namespace flux-system --kubeconfig ./shaving-yaks.kubeconfig --tail 1
```

```json
{"level":"info","ts":"2023-12-27T08:18:38.317Z","msg":"no changes since last reconcilation: observed revision 'main@sha1:b7c5a953620aa4a55ac5592ff78f551edbabf47c'","controller":"gitrepository","controllerGroup":"source.toolkit.fluxcd.io","controllerKind":"GitRepository","GitRepository":{"name":"flux-system","namespace":"flux-system"},"namespace":"flux-system","name":"flux-system","reconcileID":"72871145-39c8-4bae-9413-e270726ab853"}
```

With Flux installed and connected to this Git repository, any operation on the
cluster (even upgrading Flux) can be done via Git push, rather than
through the Kubernetes API. The definitions for the flux components can be
found in [`kubernetes/cluster/flux-system`](./kubernetes/cluster/flux-system).

### Sealed Secrets

[Sealed Secrets][sealed-secrets] provides a GitOps-friendly mechanisn for secure
Kubernetes Secret Management. Instead of directly creating
[Kubernetes Secrets][k8s-secret], Sealed Secrets objects are created, stored in
this Git repository and commited to the Repository via Flux. The Sealed Secrets
controller then automatically decrypts all Sealed Secrets into the equivalent
native Kubernetes Secret for use within the cluster.

Because the encryption key is generated and stored in the cluster, Sealed
Secrets are safe to store in local code repositories, along with the rest of
Kubernetes objects.

#### Installing Sealed Secrets in Kubernetes

Sealed Secrets is installed via it's Helm chart. The specific configuration
can be found in `cluster/sealed-secrets/sealed-secrets-components.yaml`. The
objects were initially generated with the following `flux create` commands:

```bash
flux create source helm sealed-secrets \
    --url https://bitnami-labs.github.io/sealed-secrets \
    --namespace=sealed-secrets \
    --export
```

```bash
flux create helmrelease sealed-secrets \
    --interval=1h \
    --release-name=sealed-secrets-controller \
    --target-namespace=sealed-secrets \
    --source=HelmRepository/sealed-secrets \
    --chart=sealed-secrets \
    --chart-version="2.14.1" \
    --crds=CreateReplace \
    --export
```

#### Installing `kubeseal`

To generate and work with Kube Seal locally, [install the `kubeseal`][kubeseal-install]
command-line tool.

#### Getting the Public Certificate

After Flux completes the installation, the public certificate that can be used
to encrypt credentials can be fetched from the cluster with the following
command:

```bash
kubeseal --fetch-cert \
    --kubeconfig ././shaving-yaks.kubeconfig \
    --controller-name=sealed-secrets-controller \
    --controller-namespace=sealed-secrets \
    > sealed-secrets-pub.pem
```

#### Creating a Sealed Secret

To create a Sealed Secret, you will first need a local secret in YAML format. As
an example a simple secreat can be created with:

```bash
echo -n "some secret value" | kubectl create secret generic test-secret --dry-run=client --from-file=foo=/dev/stdin -o yaml > test-secret.yaml
```

The `kubeseal` command can then be used to convert this to a Sealed Secret:

```bash
kubeseal \
    --cert sealed-secrets-pub.pem \
    --secret-file test-secret.yaml \
    --sealed-secret-file test-secret.yaml
```

### Tailscale

One of the challenges of a home lab is providing secure and reliable access to
the applications running when you are not on the network. As I am already a
(very) happy [Tailscale][tailscale] user, the
[Tailscale Operator][tailscale-operator] is a natural fit. Specifically this
allows me to access services within the cluster (via Ingress) and to the
Kubernetes API from any device connected to my tailnet.

#### Installing Tailscale Operator

Tailscale Operator is installed via it's Helm chart. The specific configuration
can be found in `kubernetes/cluster/tailscale/tailscale.yaml`. The objects
were initially generated with the following commands:

Namespace:

```shell
kubectl create namespace tailscale --dry-run=client -o yaml
```

Sealed Secret:

```shell
kubeseal \
    --cert sealed-secrets-pub.pem \
    --secret-file kubernetes/cluster/tailscale/secret.yaml \
    --sealed-secret-file kubernetes/cluster/tailscale/secret.yaml
```

Note: The original Secret, HelmRepository, HelmRelease were created manually.


<!-- References -->

[turing-pi]: https://turingpi.com/product/turing-pi-2/
[tower-100]: https://thermaltakeusa.com/products/the-tower-100-snow-mini-chassis-ca-1r3-00s6wn-00
[cm4104032]: https://www.raspberrypi.com/products/compute-module-4/?variant=raspberry-pi-cm4104032
[cm4008032]: https://www.raspberrypi.com/products/compute-module-4/?variant=raspberry-pi-cm4008032
[turing-rk1]: https://docs.turingpi.com/docs/turing-rk1-specs-and-io-ports
[jammy-jellyfish]: https://www.releases.ubuntu.com/22.04/
[turing-rk-ubuntu]: https://firmware.turingpi.com/turing-rk1/ubuntu_22.04_rockchip_linux/
[turing-pi-bmc]: https://docs.turingpi.com/docs/turing-pi2-bmc-intro-specs
[k0s]: https://k0sproject.io
[k0sctl]: https://github.com/k0sproject/k0sctl
[k0s-config]: k0s/cluster.yaml
[k0sctl-install]: https://github.com/k0sproject/k0sctl#installation
[flux]: https://fluxcd.io
[gitops]: https://www.weave.works/technologies/gitops/
[flux-install]: https://fluxcd.io/flux/installation/#install-the-flux-cli
[github-pat]: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
[sealed-secrets]: https://github.com/bitnami-labs/sealed-secrets
[k8s-secret]: https://kubernetes.io/docs/concepts/configuration/secret/
[kubeseal-install]: https://github.com/bitnami-labs/sealed-secrets#kubeseal
[tailscale]: https://tailscale.com/
[tailscale-operator]: https://tailscale.com/kb/1236/kubernetes-operator
