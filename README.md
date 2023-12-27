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

| Node | Device                              | Processor          | Speed  | Cores | RAM | Storage   |
| ---- | ----------------------------------- | ------------------ | ------ | ----- | --- | --------- |
| 1    | [Raspberry Pi CM4104032][cm4104032] | ARM v8, Cortex-A72 | 1.5GHz | 4     | 4GB | 32GB eMMC |
| 2    | [Raspberry Pi CM4008032][cm4008032] | ARM v8, Cortex-A72 | 1.5GHz | 4     | 8GB | 32GB eMMC |
| 3    | [Raspberry Pi CM4008032][cm4008032] | ARM v8, Cortex-A72 | 1.5GHz | 4     | 8GB | 32GB eMMC |
| 4    | [Raspberry Pi CM4104032][cm4104032] | ARM v8, Cortex-A72 | 1.5GHz | 4     | 4GB | 32GB eMMC |

## Operating System

The OS for each compute module is setup as follows:

| Node | Operating System                      | Hostname  | IP Address  |
| ---- | ------------------------------------- | --------- | ----------- |
| 1    | [Ubuntu 22.04 (LTS)][jammy-jellyfish] | `yak-001` | 192.168.5.1 |
| 2    | [Ubuntu 22.04 (LTS)][jammy-jellyfish] | `yak-002` | 192.168.5.2 |
| 3    | [Ubuntu 22.04 (LTS)][jammy-jellyfish] | `yak-003` | 192.168.5.3 |
| 4    | [Ubuntu 22.04 (LTS)][jammy-jellyfish] | `yak-004` | 192.168.5.4 |

Configuration was completed using the files found in the `os-configuration/`
directory in this repository, using the following steps:

1. Flash the Ubuntu 22.04 Raspberry Pi image from Canonical onto the modules
   eMMC, via the [Turing Pi 2 BMC][turing-pi-bmc]. Once the flash is complete,
   power the device on bia the BMC web interface.
2. Once the module has powered on, SSH into the fresh OS install with the
   default user account and password (`ubuntu:ubuntu`). When prompted, change
   the password to a unique, secure value.
3. Copy SSH key(s) to allow for key-based authentication to the node by running
   `ssh-copy-id -i ~/.ssh/id_ed25519.pub ubuntu@xxx.xxx.xxx.xxx` from the
   external machines that should be able to connect to the nodes.
4. Configure the hostname by replacing/editing `/etc/hostname`
5. Configure the device to use a static IP address:
   - Delete the existing netplan: `/etc/netplan/50-cloud-init.yaml`
   - Add `/etc/cloud/cloud.cfg.d/01-disable-network-config.cfg`
   - Add `/etc/netplan/05-static-ip.yaml`
6. Reboot the node `sudo reboot` and verify hostname and network configuration
   is working

<!-- References -->

[turing-pi]: https://turingpi.com/product/turing-pi-2/
[tower-100]: https://thermaltakeusa.com/products/the-tower-100-snow-mini-chassis-ca-1r3-00s6wn-00
[cm4104032]: https://www.raspberrypi.com/products/compute-module-4/?variant=raspberry-pi-cm4104032
[cm4008032]: https://www.raspberrypi.com/products/compute-module-4/?variant=raspberry-pi-cm4008032
[jammy-jellyfish]: https://www.releases.ubuntu.com/22.04/
[turing-pi-bmc]: https://docs.turingpi.com/docs/turing-pi2-bmc-intro-specs
