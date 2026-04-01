{
  description = "The GAP package Digraphs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          gap = pkgs.gap;
          gaproot = "${gap}/lib/gap";
        in
        {
          default = self.packages.${system}.digraphs;

          digraphs = pkgs.stdenv.mkDerivation {
            pname = "gap-digraphs";
            version = "1.14.0";

            src = ./.;

            nativeBuildInputs = with pkgs; [
              autoconf
              automake
              gcc
              gnumake
            ];

            buildInputs = [
              gap
            ];

            configurePhase = ''
              runHook preConfigure

              # Generate the configure script
              mkdir -p gen
              aclocal -Wall --force
              autoconf -Wall -f
              autoheader -Wall -f

              # Run configure, pointing at the GAP root
              ./configure --with-gaproot=${gaproot}

              runHook postConfigure
            '';

            buildPhase = ''
              runHook preBuild
              make
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p "$out/digraphs"

              # Copy GAP source files
              cp -r gap "$out/digraphs/"
              cp -r lib "$out/digraphs/" 2>/dev/null || true
              cp -r doc "$out/digraphs/" 2>/dev/null || true
              cp -r data "$out/digraphs/" 2>/dev/null || true
              cp -r tst "$out/digraphs/" 2>/dev/null || true

              # Copy the compiled shared object
              cp -r bin "$out/digraphs/"

              # Copy package metadata files
              cp PackageInfo.g "$out/digraphs/"
              cp init.g "$out/digraphs/"
              cp read.g "$out/digraphs/"
              cp -r makedoc.g "$out/digraphs/" 2>/dev/null || true
              cp LICENSE "$out/digraphs/" 2>/dev/null || true
              cp CHANGELOG.md "$out/digraphs/" 2>/dev/null || true
              cp README.md "$out/digraphs/" 2>/dev/null || true

              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "GAP methods for graphs, digraphs, and multidigraphs";
              homepage = "https://digraphs.github.io/Digraphs";
              license = licenses.gpl3Plus;
              platforms = platforms.unix;
            };
          };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          gap = pkgs.gap;
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.digraphs ];

            packages = with pkgs; [
              gap-full
            ];

            shellHook = ''
              export GAPROOT="${gap}/lib/gap"
              echo "\$GAPROOT=$GAPROOT"
            '';
          };
        }
      );
    };
}
