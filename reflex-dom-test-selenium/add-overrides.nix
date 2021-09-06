let
  # Older chromium for reflex-dom-core test suite
  nixpkgs_oldChromium = import ../../nixpkgs-old-chromium {
    overlays = [ (self: super: {
      # Disable tests for p11-kit, a dependency of chromium
      # They fail on non-NixOS systems
      # https://github.com/NixOS/nixpkgs/issues/96715
      p11-kit = super.p11-kit.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
    })];
  };
in
{ nixpkgs }: testPackage:
  nixpkgs.haskell.lib.overrideCabal testPackage
    (drv: {

      # The headless browser run as part of the tests will exit without this
      preBuild = ''
        export HOME="$PWD"
      '';

      testSystemDepends = with nixpkgs; (drv.testSystemDepends or []) ++ [
        nixpkgs_oldChromium.selenium-server-standalone
        nixpkgs_oldChromium.chromium
        which
        nixpkgs.iproute
      ];

      # The headless browser run as part of gc tests would hang/crash without this
      preCheck = ''
        export FONTCONFIG_PATH=${nixpkgs.fontconfig.out}/etc/fonts
      '';
    })