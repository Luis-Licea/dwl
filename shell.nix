# vim: tabstop=2 softtabstop=2 shiftwidth=2 expandtab filetype=nix
# Run nix-shell to activate this environment in NixOS.
{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  name = "DWL Development Shell";
  buildInputs = with pkgs; [
    gnumake
    libinput
    libxkbcommon
    pixman
    pkg-config
    wayland
    wayland-protocols
    wayland-scanner
    wlroots_0_16
    xorg.libX11
    xorg.libxcb
    xorg.xcbutilwm
 ];
}
