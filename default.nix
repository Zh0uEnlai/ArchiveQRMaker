{
    pkgs ? import <nixpkgs> {}
,   lib ? pkgs.lib
,   python ? pkgs.python39
}:
    let pname = "archive_qr";
        name=pname;
        version = "0.3";

        archiveQRMaker = python.pkgs.buildPythonPackage {

            inherit pname version;
        
            propagatedBuildInputs = [ 
                pkgs.geckodriver
                python.pkgs.pyqrcode
                python.pkgs.requests
                python.pkgs.selenium
            ];

            src = ./.;

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
        lib=archiveQRMaker;
        bin=(python.pkgs.toPythonApplication archiveQRMaker);
    }