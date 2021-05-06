{
  description = "Archives a URL and generates a QR code for it. This obviates link rot.";

  inputs = {
    nixpkgs = { 
      url = "github:NixOS/nixpkgs";
    };

    flake-utils = { 
      url = "github:numtide/flake-utils"; 
    };

    pypi-deps-db = {
      url = github:DavHau/pypi-deps-db;
      flake = false;
    };
 
    mach-nix = {
      url = github:DavHau/mach-nix;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pypi-deps-db.follows = "pypi-deps-db";
    };
    # mach-nix = import (builtins.fetchGit {
    #     url = "https://github.com/DavHau/mach-nix/";
    #     ref = "refs/tags/3.1.1";  # update this version
    #   }) {
    #     pypiDataRev = "8f86c2dbe751a7d05cc12ea6a099f85f2700d50a";
    #     pypiDataSha256 = "1nkni18sj279fz2fdj48jy91pqsc8pacn309iw5g42g52zfadnya";
    #     python = "python38";
    #   };
  };

  outputs = { self, nixpkgs, flake-utils, pypi-deps-db, mach-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pname = "archive_qr";
        version = "0.3";
        pkgs = nixpkgs.legacyPackages.${system};

        mach-nix-utils = import mach-nix {
          inherit pkgs;
          pypiDataRev = pypi-deps-db.rev;
          pypiDataSha256 = pypi-deps-db.narHash;

          # TODO: maybe doing this should be an error
          # pypi_deps_db_commit = pypi-deps-db..rev;
          # pypiDataSha256 = pypi-deps-db.narHash;
        };
        python = pkgs.python38;

        customOverrides = self: super: {
          # Overrides go here
        };

        app = mach-nix-utils.buildPythonApplication { 
          inherit pname version;
          requirements = ''
            pyqrcode==1.2.1 
            selenium==3.141.0
            requests==2.25.1
          '';
          # add missing webdriver dependencies to selenium
          packagesExtra = [
              pkgs.geckodriver
          ];

          # TODO: Find a way to make the geckodriver available at python's run-time. 
          _.selenium.buildInputs.add = [ pkgs.geckodriver ];
          src = ./.;
        };

        
          # overrides =
          #   [ pkgs.poetry2nix.defaultPoetryOverrides customOverrides ];
        #};
        
        packageName = "archive_qr";
      in {
          packages.${packageName} = app;

          defaultPackage = self.packages.${system}.${packageName};

          devShell = import ./shell.nix { inherit python; nixpkgs=pkgs; mach-nix=mach-nix-utils; };
          
          # apps.hello = flake-utils.lib.mkApp { drv = pkgs.hello; };
          # defaultApp = apps.hello;
        # devShell = pkgs.mkShell {
        #   buildInputs = with pkgs; [ 
        #     zsh
        #     locale
        #     ncurses
        #     poetry 
        #   ];
        #   shellHook = ''
        #     exec env zsh
        #   '';
        #   inputsFrom = builtins.attrValues self.packages.${system};
        # };
      });
}
