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

<!-- References -->

[turing-pi]: https://turingpi.com/product/turing-pi-2/
[tower-100]: https://thermaltakeusa.com/products/the-tower-100-snow-mini-chassis-ca-1r3-00s6wn-00
[cm4104032]: https://www.raspberrypi.com/products/compute-module-4/?variant=raspberry-pi-cm4104032
[cm4008032]: https://www.raspberrypi.com/products/compute-module-4/?variant=raspberry-pi-cm4008032
