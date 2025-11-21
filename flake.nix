{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    emacs-overlay.url = "github:nix-community/emacs-overlay/master";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, unstable, emacs-overlay, ... }@inputs: {
    nixosConfigurations.ymir = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit unstable; };
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        (import ./configuration.nix inputs)
        {nixpkgs.overlays = [ emacs-overlay.overlays.default];
        }

      ];
    };
  };

}
