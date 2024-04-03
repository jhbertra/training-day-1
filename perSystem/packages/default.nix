flake: {
  perSystem = {
    config,
    pkgs,
    system,
    ...
  }: {
    packages.jsonld = (import ../../jsonld-nix { inherit pkgs system; inherit (pkgs) nodejs; }).nodeDependencies;
  };
}