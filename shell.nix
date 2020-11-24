{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.packer
    pkgs.mkpasswd

    # keep this line if you use bash
    pkgs.bashInteractive
  ];
}
