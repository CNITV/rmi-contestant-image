NixOS Virtual Machine Builder
=============================

This project builds a virtual machine with my personal configuration of [NixOS](http://nixos.org) installed.

This is a fork of oxdi's [nixos](http://github.com/oxdi/nixos) project, which builds a NixOS Vagrant box.


Building the images
-------------------

First install [packer](http://packer.io) and [virtualbox](https://www.virtualbox.org/).

Then:

```bash
packer build template.json
```
