flake: {
  perSystem = {
    config,
    pkgs,
    system,
    ...
  }: let
    jsonld = (import ../../jsonld-nix { inherit pkgs system; inherit (pkgs) nodejs; }).nodeDependencies;
    votingScripts = pkgs.runCommandNoCC "voting-scripts" {} ''
      mkdir -p $out/bin
      cp ${../../scripts}/* $out/bin
    '';
  in {
    cardano-parts.shell = {
      global = {
        defaultShell = "test";
        enableVars = false;
        defaultHooks = ''
          # CURRENTLY BROKEN!
          alias cardano-node=cardano-node-ng
          alias cardano-cli=cardano-cli-ng
        '';
      };
      test = {
        enableVars = true;
        defaultVars = {
          CARDANO_NODE_SOCKET_PATH = "./cc-public/node.socket";
          CARDANO_NODE_NETWORK_ID = "5";
          USE_ENCRYPTION = false;
          UNSTABLE = true;
          IPFS_PATH = "./cc-public/ipfs";
        };
        extraPkgs = [
          config.packages.run-cardano-node
          pkgs.asciinema
          pkgs.fx
          pkgs.ipfs
          jsonld
          votingScripts
        ];
      };
    };
    #cardano-parts.pkgs.cardano-cli = flake.inputs.cardano-cli-ng.legacyPackages.${system}.cardano-cli;
    #cardano-parts.pkgs.cardano-node = flake.inputs.cardano-node-ng.legacyPackages.${system}.cardano-node;
  };
}
