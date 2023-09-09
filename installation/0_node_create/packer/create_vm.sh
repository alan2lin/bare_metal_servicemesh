
multipass launch file://~/bare_metal_servicemesh/packer/output-qemu/packer-qemu -c 4 -m 8G --disk 23G -n m01
multipass stop m01
multipass launch file://~/bare_metal_servicemesh/packer/output-qemu/packer-qemu -c 4 -m 8G --disk 23G -n w01
multipass stop w01
multipass launch file://~/bare_metal_servicemesh/packer/output-qemu/packer-qemu -c 4 -m 8G --disk 23G -n w02
multipass stop w02



multipass start m01
multipass mount ~/bare_metal_servicemesh m01:/bms
multipass start w01
multipass start w02


