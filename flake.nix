{
	description = "LuaJIT development environment for an evidence-adaptive education system";

	inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
	# random: a cross-platform BLAKE3 DRBG; its LuaJIT library supplies seeded, unpredictable streams.
	inputs.random.url = "github:pmarreck/random/d2dd7e7fe71013008cbecc2897d8b1860896639a";

	outputs = { self, nixpkgs, random }:
		let
			systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
			forAllSystems = nixpkgs.lib.genAttrs systems;
			pkgsFor = system: import nixpkgs { inherit system; };
			# Match the LuaJIT-with-packages pattern in the maintainer's NixOS configuration:
			# modules are baked into LuaJIT's own search path, not assumed global.
			luaFor = pkgs: pkgs.luajit.withPackages (ps: with ps; [
				busted cjson luafilesystem sqlite http
			]);
			randomLib = system: random.packages.${system}.random-luajit-lib;
			# Trailing ;; keeps LuaJIT's default search path after the random library's.
			luaPathFor = system: "${randomLib system}/lib/?.lua;;";
			# unshare and prlimit for the activity sandbox (Linux only; elsewhere the sandbox refuses to run).
			sandboxToolsFor = pkgs: pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.util-linux ];
		in {
			devShells = forAllSystems (system: {
				default = (pkgsFor system).mkShell {
					packages = [ (luaFor (pkgsFor system)) (pkgsFor system).ripgrep ] ++ sandboxToolsFor (pkgsFor system);
					LUA_PATH = luaPathFor system;
				};
			});

			checks = forAllSystems (system:
				let pkgs = pkgsFor system;
				in {
					tests = pkgs.runCommand "ai-edu-tests" {
						nativeBuildInputs = [ (luaFor pkgs) pkgs.bash pkgs.ripgrep pkgs.coreutils ] ++ sandboxToolsFor pkgs;
						LUA_PATH = luaPathFor system;
						AI_EDU_IN_ENV = "1";
					} ''
						cd ${self}
						bash tests/run
						touch "$out"
					'';
				});
		};
}
