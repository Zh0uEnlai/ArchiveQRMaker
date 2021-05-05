# Thanks to 
{ python }:
let pypng = python.mkDerivation {
        name = "pypng-0.0.20";
        src = pkgs.fetchurl {
            url = "https://files.pythonhosted.org/packages/bc/fb/f719f1ac965e2101aa6ea6f54ef8b40f8fbb033f6ad07c017663467f5147/pypng-0.0.20.tar.gz";
            sha256 = "1032833440c91bafee38a42c38c02d00431b24c42927feb3e63b104d8550170b";
        };
    doCheck = commonDoCheck;
    format = "setuptools";
    buildInputs = commonBuildInputs ++ [ ];
    propagatedBuildInputs = [ ];
    meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/drj11/pypng";
        license = licenses.mit;
        description = "Pure Python PNG image encoder/decoder";
    };
};
in 
pypng