{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devenv.url = "github:cachix/devenv";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, devenv, systems, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      devShells = forEachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            default = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                {
                  packages = with pkgs; [
                    fava
                    beancount
                    beancount-black
                    beancount-language-server
                    (writeShellApplication {
                      name = "beancount-langserver";

                      runtimeInputs = [ beancount-language-server ];

                      text = ''
                        beancount-language-server "$@"
                      '';
                    }
                    )
                    black
                    pyright
                  ];
                  enterShell = ''
                    echo "Loaded Beancount"
                    echo "bean-check --version `bean-check --version`"
                    export PYTHONPATH=$PYTHONPATH:$VIRTUAL_ENV/lib/python3.12/site-packages
                  '';
                  env = { };
                }
              ];
            };
          });
    };
}
