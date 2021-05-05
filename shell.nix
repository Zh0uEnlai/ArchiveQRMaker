{
    pkgs ? import <nixpkgs> {}
,   lib ? pkgs.lib
,   python ? pkgs.python39
}:
let archiveQRMaker = pkgs.callPackage ./default.nix {inherit pkgs lib python; };
pathVsCodePythonHook = ''
    # Patch `packages.json` so that nix's *python* is used as default value for `python.pythonPath`.
    if [ -e ".vscode/settings.json" ]; then
        echo "Writing python.pythonPath..."
        sed 's|"python.pythonPath.*|"python.pythonPath": "${python}/bin/python"|g' -i ".vscode/settings.json"
    fi
'';
in
pkgs.mkShell {
    nativeBuildInputs=[
        pkgs.zsh
        pkgs.less
        pkgs.locale
        pkgs.ncurses
        python
    ];
    propagatedBuildInputs=archiveQRMaker.bin.propagatedBuildInputs
    ++ [ python python.pkgs.bpython]
    ;

    shellHook=
        pathVsCodePythonHook + 
    ''
        exec env zsh 
    '' ;
}