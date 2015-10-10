Teensy Docker
============

This image provides an alternative to compiling with the Teensyduino IDE.

Running `make` will build the project and flash it onto a Teensy 3.1, will support switching between target processors in the future.

### Note
This uses the `--privledged` Docker flag and mounts /dev/bus/usb on the Docker host. If the Docker host is a hypervisor additional configuration is like required
to make the Teensy available within the VM. 

#### VirtualBox
* Download the [VirtualBox Extension Pack](https://www.virtualbox.org/wiki/Downloads). 
* Add a USB filter for the Teensy under Ports in settings. The VM must be off to make these changes.
