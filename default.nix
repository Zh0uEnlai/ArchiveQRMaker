{
    pkgs ? import <nixpkgs> {}
,   lib ? pkgs.lib
,   python ? pkgs.python39
}:
    let 
        pname = "archive_qr";
        name=pname;
        version = "0.3";

        mach-nix = import (builtins.fetchGit {
            url = "https://github.com/DavHau/mach-nix/";
            ref = "refs/tags/3.1.1";  # update this version
            }) {
                pypiDataRev = "8f86c2dbe751a7d05cc12ea6a099f85f2700d50a";
                pypiDataSha256 = "1nkni18sj279fz2fdj48jy91pqsc8pacn309iw5g42g52zfadnya";
                python = "python38";
            };

        archiveQRMaker = mach-nix.buildPythonApplication {

            inherit pname version;
        
            propagatedBuildInputs = [ 
                pkgs.geckodriver
                python.pkgs.pyqrcode
                python.pkgs.requests
                python.pkgs.selenium
            ];

            src = ./.;

            requirements = ./requirements.txt;

            # No tests in PyPI tarball
            doCheck = false;

            meta = with lib; {
                description = "Archives a URL and returns a QR code.";
                homepage = "https://github.com/Zh0uEnlai/ArchiveQRMaker";
                license = licenses.gpl3;
                maintainers = with maintainers; [ zhouenlai ];
            };
        };
in 
    {
        bin=archiveQRMaker;
        lib=(python.pkgs.toPythonModule archiveQRMaker);
    }