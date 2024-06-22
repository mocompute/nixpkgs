{
  lib,
  stdenv,
  fetchFromGitHub,
  stripJavaArchivesHook,
  cmake,
  cmark,
  darwin,
  kdePackages,
  ninja,
  jdk17,
  zlib,
  extra-cmake-modules,
  tomlplusplus,
  ghc_filesystem,
  gamemode,
  msaClientID ? null,
  gamemodeSupport ? stdenv.isLinux,
}:
let
  libnbtplusplus = fetchFromGitHub {
    owner = "PrismLauncher";
    repo = "libnbtplusplus";
    rev = "a5e8fd52b8bf4ab5d5bcc042b2a247867589985f";
    hash = "sha256-A5kTgICnx+Qdq3Fir/bKTfdTt/T1NQP2SC+nhN1ENug=";
  };
in

assert lib.assertMsg (
  stdenv.isLinux || !gamemodeSupport
) "gamemodeSupport is only available on Linux";

stdenv.mkDerivation (finalAttrs: {
  pname = "prismlauncher-unwrapped";
  version = "8.4";

  src = fetchFromGitHub {
    owner = "PrismLauncher";
    repo = "PrismLauncher";
    rev = finalAttrs.version;
    hash = "sha256-460hB91M2hZm+uU1tywJEj20oRd5cz/NDvya8/vJdSA=";
  };

  nativeBuildInputs = [
    extra-cmake-modules
    cmake
    jdk17
    ninja
    stripJavaArchivesHook
  ];
  buildInputs =
    [
      kdePackages.qtbase
      zlib
      kdePackages.quazip
      ghc_filesystem
      tomlplusplus
      cmark
    ]
    ++ lib.optional gamemodeSupport gamemode
    ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Cocoa ];

  hardeningEnable = lib.optionals stdenv.isLinux [ "pie" ];

  cmakeFlags =
    [
      # downstream branding
      "-DLauncher_BUILD_PLATFORM=nixpkgs"
    ]
    ++ lib.optionals (msaClientID != null) [ "-DLauncher_MSA_CLIENT_ID=${msaClientID}" ]
    ++ lib.optionals (lib.versionOlder kdePackages.qtbase.version "6") [
      "-DLauncher_QT_VERSION_MAJOR=5"
    ]
    ++ lib.optionals stdenv.isDarwin [
      "-DINSTALL_BUNDLE=nodeps"
      "-DMACOSX_SPARKLE_UPDATE_FEED_URL=''"
      "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}/Applications/"
    ];

  postUnpack = ''
    rm -rf source/libraries/libnbtplusplus
    ln -s ${libnbtplusplus} source/libraries/libnbtplusplus
  '';

  dontWrapQtApps = true;

  meta = {
    mainProgram = "prismlauncher";
    homepage = "https://prismlauncher.org/";
    description = "A free, open source launcher for Minecraft";
    longDescription = ''
      Allows you to have multiple, separate instances of Minecraft (each with
      their own mods, texture packs, saves, etc) and helps you manage them and
      their associated options with a simple interface.
    '';
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    changelog = "https://github.com/PrismLauncher/PrismLauncher/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      minion3665
      Scrumplex
      getchoo
    ];
  };
})
