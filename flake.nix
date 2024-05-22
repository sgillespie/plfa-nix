{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    plfa = {
      url = "github:plfa/plfa.github.io";
      flake = false;
    };
  };

  outputs = { nixpkgs, utils, plfa, ... }@inputs:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;

          overlays = [
            (final: prev: {
              standard-library =
                prev.agdaPackages.standard-library.overrideAttrs (oldAttrs: rec {
                  version = "1.7.3";

                  src =  final.fetchFromGitHub {
                    repo = "agda-stdlib";
                    owner = "agda";
                    rev = "v1.7.3";
                    hash = "sha256-vtL6VPvTXhl/mepulUm8SYyTjnGsqno4RHDmTIy22Xg=";
                  };

                  preConfigure = ''
                    runhaskell GenerateEverything.hs
                    # We will only build/consider Everything.agda, in particular we don't want Everything*.agda
                    # do be copied to the store.
                    rm EverythingSafe.agda
                  '';
                });
            })

            (final: prev: {
              plfa = prev.agdaPackages.mkDerivation {
                pname = "plfa";
                version = "1.0.0";
                src = "${plfa}/src";

                buildInputs = [prev.standard-library];

                buildPhase = ''
                  # All the modules have to be compiled separately, because there are some
                  # conflicting definitions
                  find plfa -type f -name "*.lagda.md" -exec agda {} \;
                '';

                meta = {
                  homepage = "https://plfa.github.io";
                  description = "An introduction to programming language theory in Agda";
                  license = final.lib.licenses.cc-by-40;
                  platforms = final.lib.platforms.unix;
                };
              };
            })
          ];
        };

        agda = pkgs.agda.withPackages (p: [
          pkgs.standard-library
          pkgs.plfa
        ]);
      in {
        devShells.default = pkgs.mkShell {
          inputsFrom = [ pkgs.plfa ];
        };

        packages.default = pkgs.plfa pkgs.agdaPackages;
      });
}
