{ config
, lib
, dream2nix
, ...
}:
let
  seaserv-pro = config.deps.python.pkgs.seaserv-pro;
  source = seaserv-pro.src;
  version = seaserv-pro.version;

  requirements = config.deps.stdenvNoCC.mkDerivation {
    pname = "requirements.txt";
    version = version;
    src = source;

    unpackCmd = ''
      tar xf "$curSrc" --strip-components 1 "seafile-pro-server-${version}/seahub/requirements.txt"
    '';

    patchPhase = ''
      sed -i '/^captcha/d' requirements.txt
    '';

    installPhase = ''
      cp requirements.txt $out
    '';
  };
in
{
  imports = [
    dream2nix.modules.dream2nix.pip
  ];

  deps = { nixpkgs, ... }: {
    python = nixpkgs.python311;
    inherit (nixpkgs) stdenvNoCC seafile-pro-server libmysqlclient openldap cyrus_sasl makeWrapper;
  };

  buildPythonPackage = {
    format = "other";
  };

  mkDerivation = {
    src = source;
    unpackCmd = ''
      tar xf "$curSrc" --strip-components 1 "seafile-pro-server-${version}/seahub"
    '';
    dontBuild = true;
    doCheck = false;

    nativeBuildInputs = [ config.deps.makeWrapper ];
    propagatedBuildInputs = [ seaserv-pro ];

    installPhase = ''
      cp -dr . $out/
      wrapProgram $out/manage.py \
        --prefix PYTHONPATH : "$PYTHONPATH:$out/thirdpart:"
    '';
  };

  name = "seahub-pro";
  version = version;

  public = {
    meta = with lib; {
      description = "The web end of seafile server";
      homepage = "https://github.com/haiwen/seahub";
      license = licenses.unfree;
      platforms = platforms.linux;
    };
    python = config.deps.python;
    inputs = config.mkDerivation.propagatedBuildInputs;
    pythonPath = config.deps.python.pkgs.makePythonPath config.mkDerivation.propagatedBuildInputs;
  };

  pip = {
    requirementsFiles = [
      "${requirements}"
    ];
    nativeBuildInputs = [
      config.deps.libmysqlclient.dev
    ];
    overrideAll = {
      mkDerivation = {
        doCheck = false;
      };
    };
    overrides = {
      mysqlclient = {
        mkDerivation = {
          nativeBuildInputs = [
            config.deps.libmysqlclient
          ];
          buildInputs = [
            config.deps.libmysqlclient
          ];
        };
      };
      python-ldap = {
        mkDerivation = {
          buildInputs = [
            config.deps.openldap
            config.deps.cyrus_sasl
          ];
        };
      };
    };
    flattenDependencies = true;
  };
}
