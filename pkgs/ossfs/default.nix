{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, fuse
, curl
, libxml2
, pkg-config
, openssl
}:
stdenv.mkDerivation rec {
  pname = "ossfs";
  version = "1.91.1";
  src = fetchFromGitHub {
    owner = "aliyun";
    repo = "ossfs";
    rev = "v${version}";
    sha256 = "sha256-RsnMgfH+itU+6RnLQ/zA5K2LsffU3fsAEOHG/D4cvT8=";
  };

  buildInputs = [ fuse curl libxml2 openssl ];
  nativeBuildInputs = [ autoreconfHook pkg-config ];

  configureFlags = [
    "--with-openssl"
  ];

  meta = with lib; {
    description = "Export s3fs for aliyun oss";
    homepage = "https://github.com/aliyun/ossfs";
    changelog = "https://github.com/aliyun/ossfs/raw/v${version}/ChangeLog";
    maintainers = [ ];
    license = licenses.gpl2Only;
    platforms = platforms.unix;
  };
}
