# plfa-nix

A Nix build for [Programming Language Foundations in Agda](https://plfa.github.io/)

**Important**: Please do not use this repository to post exercises in a public place. From the book:

> Please do not post answers to the exercises in a public place.
>
> There is a private repository of answers to selected questions on github. Please contact
> Philip Wadler if you would like to access it.

## Usage

This flake will allow you to use PLFA as a library. Add this flake as an input. You can use
the following example nix flake as a template:

    {
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        utils.url = "github:numtide/flake-utils";
        plfa.url = "github:sgillespie/plfa-nix";
      };

      outputs = { nixpkgs, utils, plfa, ... }@inputs:
        utils.lib.eachDefaultSystem (system:
          let
            pkgs = import nixpkgs { inherit system; };
            plfaPackages = plfa.packages.${system};
          in rec {
            devShells.default = pkgs.mkShell {
              inputsFrom = [packages.default];
            };

            packages.default = pkgs.agdaPackages.mkDerivation {
              version = "1.0.0";
              pname = "my-project";
              src = ./.;
              buildInputs = [
                plfaPackages.plfa
                plfaPackages.standard-library
              ];

              meta = {
              };
            };
          });
    }

Add `plfa` to your `*.agda-lib`:

    name: my-project
    include: src
    depend:
      standard-library
      plfa

Now you should be able to import modules from PLFA:

    module MyNaturals where

    import plfa.part1.Naturals
