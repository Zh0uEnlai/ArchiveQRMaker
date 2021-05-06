{
    nixpkgs ? import <nixpkgs> {}
#? import (
#        builtins.fetchGit {
#            url = "https://github.com/DavHau/mach-nix/";
#            ref = "2.0.0";
#        })
,   lib ? nixpkgs.lib
,   python ? nixpkgs.python39
,   mach-nix 
}:
let 
    #requirements = ./requirements.txt;
    archiveQRMaker = nixpkgs.callPackage ./default.nix { pkgs=nixpkgs; inherit lib python mach-nix ; };

    photoshop_python_api = mach-nix.buildPythonPackage {
        src = builtins.fetchGit {
            url = "https://github.com/loonghao/photoshop-python-api";
            ref = "0.15.1";
            # rev = "put_commit_hash_here";
        };
    };

    # Patch `packages.json` so that nix's *python* is used as default value for `python.pythonPath`.
    pathVsCodePythonHook = ''
        if [ -e ".vscode/settings.json" ]; then
            echo "Writing python.pythonPath..."
            sed 's|"python.pythonPath.*|"python.pythonPath": "${python}/yeet/bin/python"|g' -i ".vscode/settings.json"
        fi
    '';

    python_env = mach-nix.mkPython {
        requirements = ''
            setuptools
            pyqrcode==1.2.1 
            selenium==3.141.0
            requests==2.25.1
        '';
        packagesExtra = [
            mach-nix.nixpkgs.python
        ];
    };
in
#mach-nix.mkPythonShell {
nixpkgs.mkShell {
    #buildInputs=[
    #    nixpkgs.zsh
    #    nixpkgs.less
    #    nixpkgs.locale
    #    nixpkgs.ncurses
    #    python
    #];
    #propagatedBuildInputs=archiveQRMaker.bin.propagatedBuildInputs;

    propagatedBuildInputs=[python_env];

    shellHook=
       pathVsCodePythonHook + 
    ''
       exec env zsh 
    '' ;
}