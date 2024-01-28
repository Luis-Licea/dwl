{
  lib,
  stdenv,
  installShellFiles,
  libX11,
  libinput,
  libxcb,
  libxkbcommon,
  pixman,
  pkg-config,
  wayland-scanner,
  wayland,
  wayland-protocols,
  wlroots_0_16,
  writeText,
  xcbutilwm,
  xwayland,
  enableXWayland ? true,
  conf ? null,
  ...
}: let
  wlroots = wlroots_0_16;
in
  stdenv.mkDerivation rec {
    pname = "dwl";
    version = "0.4.4";

    # For local development with `nix profile install`
    # src = ./.;

    src = builtins.fetchTree {
      type = "github";
      owner = "luis-licea";
      repo = "dwl";
      # host = "";
      # ref = "main";
      rev = "afe85dd31e4716f36a3bbb599c49580bd72a29bd";
    };

    nativeBuildInputs = [
      installShellFiles
      pkg-config
      wayland-scanner
    ];

    buildInputs =
      [
        libinput
        libxcb
        libxkbcommon
        pixman
        wayland
        wayland-protocols
        wlroots
      ]
      ++ lib.optionals enableXWayland [
        libX11
        xcbutilwm
        xwayland
      ];

    outputs = ["out" "man"];

    # Allow users to set an alternative config.def.h
    postPatch = let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf
        then conf
        else writeText "config.def.h" conf;
    in
      lib.optionalString (conf != null) "cp ${configFile} config.def.h";

    makeFlags = [
      "PKG_CONFIG=${stdenv.cc.targetPrefix}pkg-config"
      "WAYLAND_SCANNER=wayland-scanner"
      "PREFIX=$(out)"
      "MANDIR=$(man)/share/man/man1"
    ];

    preBuild = ''
      makeFlagsArray+=(
        XWAYLAND=${lib.optionalString enableXWayland "-DXWAYLAND"}
        XLIBS=${lib.optionalString enableXWayland "xcb\\ xcb-icccm"}
      )
    '';

    meta = {
      homepage = "https://github.com/djpohly/dwl/";
      description = "Dynamic window manager for Wayland";
      longDescription = ''
        dwl is a compact, hackable compositor for Wayland based on wlroots. It is
        intended to fill the same space in the Wayland world that dwm does in X11,
        primarily in terms of philosophy, and secondarily in terms of
        functionality. Like dwm, dwl is:

        - Easy to understand, hack on, and extend with patches
        - One C source file (or a very small number) configurable via config.h
        - Limited to 2000 SLOC to promote hackability
        - Tied to as few external dependencies as possible
      '';
      changelog = "https://github.com/djpohly/dwl/releases/tag/v${version}";
      license = lib.licenses.gpl3Only;
      maintainers = [lib.maintainers.AndersonTorres];
      inherit (wayland.meta) platforms;
    };
  }
