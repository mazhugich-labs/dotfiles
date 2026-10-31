{
  description = "Reproducible Ubuntu development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      settings = import ./settings.nix;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      mkHome =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          extraSpecialArgs = { inherit settings; };
          modules = [ ./modules/home.nix ];
        };
    in
    {
      # The output name is the Nix platform, so the scripts do not need a
      # username baked into a command.
      homeConfigurations = forAllSystems mkHome;

      packages = forAllSystems (system: {
        home-manager = home-manager.packages.${system}.home-manager;
      });

      checks = forAllSystems (system: {
        home = self.homeConfigurations.${system}.activationPackage;
      });

      formatter = forAllSystems (system: (pkgsFor system).nixfmt);
    };
}
