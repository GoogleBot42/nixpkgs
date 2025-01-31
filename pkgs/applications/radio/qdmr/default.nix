{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  writeText,
  cmake,
  libxslt,
  docbook_xsl_ns,
  wrapQtAppsHook,
  libusb1,
  libyamlcpp,
  qtlocation,
  qtserialport,
  qttools,
  qtbase,
}:

let
  inherit (stdenv) isLinux;
in

stdenv.mkDerivation rec {
  pname = "qdmr";
  version = "0.11.2";

  src = fetchFromGitHub {
    owner = "hmatuschek";
    repo = "qdmr";
    rev = "v${version}";
    sha256 = "sha256-zT31tzsm5OM99vz8DzGCdPmnemiwiJpKccYwECnUgOQ=";
  };

  nativeBuildInputs = [
    cmake
    libxslt
    wrapQtAppsHook
    installShellFiles
  ];

  buildInputs = [
    libyamlcpp
    libusb1
    qtlocation
    qtserialport
    qttools
    qtbase
  ];

  postPatch = lib.optionalString isLinux ''
    substituteInPlace doc/docbook_man.debian.xsl \
      --replace /usr/share/xml/docbook/stylesheet/docbook-xsl/manpages/docbook\.xsl ${docbook_xsl_ns}/xml/xsl/docbook/manpages/docbook.xsl
  '';

  cmakeFlags = [ "-DBUILD_MAN=ON" ];

  postInstall = ''
    installManPage doc/dmrconf.1 doc/qdmr.1
    mkdir -p "$out/etc/udev/rules.d"
    cp ${src}/dist/99-qdmr.rules $out/etc/udev/rules.d/
  '';

  meta = {
    description = "A codeplug programming tool for DMR radios";
    homepage = "https://dm3mat.darc.de/qdmr/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ janik _0x4A6F ];
    platforms = lib.platforms.linux;
  };
}
