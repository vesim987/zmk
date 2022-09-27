with import <nixpkgs> { };
let
  zephyr-toolchain = stdenv.mkDerivation rec {
    version = "0.13.2";
    pname = "zephyr-toolchain";

    src = fetchurl {
      sha256 = "sha256-D4CI4hgipnJwy9OPxurGA9PH0b7g0XhsygPrvlXOzFo=";
      url =
        "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${version}/zephyr-toolchain-arm-${version}-linux-x86_64-setup.run";
    };

    nativeBuildInputs = [ autoPatchelfHook bash coreutils which python38 ];

    buildInputs = [ python38 ];

    unpackPhase = ''
      cp $src setup.run
      chmod +x setup.run
      ./setup.run --target $PWD/unpacked --noexec
      patchShebangs unpacked
    '';

    installPhase = ''
      cd unpacked
      ./setup.sh -norc -d $out -nocmake -y
      patchShebangs $out
    '';
  };
in mkShell rec {
  packages = [ cmake ninja gnumake dtc python3 ] ++ (with python3.pkgs; [
    west
    # requirements-base.txt
    pyelftools
    pykwalify
    pyyaml
    canopen
    packaging
    progress
    psutil
    pylink-square
    anytree
    intelhex
  ]);

  ZEPHYR_TOOLCHAIN_VARIANT = "zephyr";
  ZEPHYR_SDK_INSTALL_DIR = "${zephyr-toolchain}";
}
