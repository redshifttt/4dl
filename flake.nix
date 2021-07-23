{
  description = "4dl - 4chan image downloader written in bash";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  };
  outputs = { self, nixpkgs, ... }@inputs: let
    systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
    forSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    nixpkgsFor = forSystems (system: import nixpkgs { inherit system; });
  in {
    defaultApp = forSystems (system: {
      type = "app";
      program = "${self.defaultPackage.${system}}/bin/4dl";
    });

    defaultPackage = forSystems (system:
    let
      pkgs = nixpkgsFor.${system};
      deps = with pkgs; [
        coreutils gnused gawk gnugrep
        findutils # for xargs
        ncurses # for tput
        util-linuxMinimal # for column
        fd
        curl jq wget
        dateutils
        recode
      ];
      binPath = nixpkgs.lib.makeBinPath deps;
    in pkgs.runCommandLocal "4dl" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      mkdir -p $out/bin
      cp ${./4dl} $out/bin/4dl
      patchShebangs $out/bin/4dl
      wrapProgram $out/bin/4dl --prefix PATH : ${binPath}
    '');
  };
}
