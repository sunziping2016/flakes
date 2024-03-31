{ lib
, seafile-server
, autoPatchelfHook
, libceph
, fetchurl
}:
seafile-server.overrideAttrs (old: rec {
  pname = "seafile-pro-server";
  version = "11.0.5";
  src = fetchurl {
    url = "https://download.seafile.com/d/6e5297246c/files/?p=%2Fpro%2Fseafile-pro-server_${version}_x86-64_Ubuntu.tar.gz&dl=1";
    name = "seafile-pro-server_${version}_x86-64_Ubuntu.tar.gz";
    sha256 = "sha256-iyvfy5rJg3VVDLz8lsVDLjbHEkpK+lf77OBe1vbOTJQ=";
  };
  nativeBuildInputs = [ autoPatchelfHook ];
  installPhase = ''
    mkdir -p $out/share/seafile

    cp -r seafile/bin $out
    cp -r seafile/include $out
    cp -r seafile/lib $out
    cp -r sql $out/share/seafile

    mv $out/lib/python3 $out/lib/python3.11

    rm $out/bin/fileserver
  '';
  postInstall = ''
  '';

  meta = old.meta // {
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
})
