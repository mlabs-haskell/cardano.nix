{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cardano.private-testnet-node;
in
{

  imports = [
    ./cardano.nix
    ./node.nix
  ];

  options.cardano.private-testnet-node = {
    enable = lib.mkEnableOption ''
      cardano-devnet node (a private testnet node) which -- when enabled --
      switches the system's cardano-node to a private testnet node (with its
      own testnet network magic) with the environment variable $FAUCET as an address
      loaded with LOVELACE (approx. 1000000000000 LOVELACE) that can be
      distributed with the CLI utility `request-from-faucet --address
      addr_test1vztc80na8320zymhjekl40yjsnxkcvhu58x59mc2fuwvgkc332vxv
      --amount 10000000`'';

    initialFunds = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          (lib.types.nonEmptyListOf lib.types.ints.unsigned)
          lib.types.ints.unsigned
        ]
      );
      default = { };

      example = {
        addr_test1vzrv7az4xq620y20pyn44yhvl89r7nwa7ga5ftn9rleenxqharu33 = [
          10000000
          1000000
        ];
        addr_test1vr6ue2hmlnj8pzzqy7353lv3yj8xu7m24pgpctv7z3qhv8c3qdt46 = 1000000;
      };
      description = ''
        A mapping from bech32 encoded addresses to either a single LOVELACE
        amount or a non-empty list of LOVELACE amounts which initializes the
        addresses with UTxOs containing the provided LOVELACE amounts from the
        FAUCET.

        When using the [NixOS
        Tests](https://nixos.org/manual/nixos/stable/index.html#sec-call-nixos-test-outside-nixos),
        it's good to wait for the unit `test-cardano-node-initial-funds.service` before
        spending from these wallets i.e., having the following in the
        `testScript` would be a good idea:
        ```
        machine.wait_for_unit("test-cardano-node-initial-funds")
        ```
      '';
    };

    testNodeConfigDirectory = lib.mkOption {
      internal = true;
      type = lib.types.str;
      default = "cardano-node";
      description = ''
        The ConfigurationDirectory (see `man systemd.exec (5)`) to put the test
        Cardano node's configuration in. Thus, the node's configuration
        will be in `/etc/<testNodeConfigDirectory>`.
      '';
    };

    # The following options are the genesis files for specific eras
    genesisAlonzo = lib.mkOption {
      internal = true;
      type = lib.types.path;
      default = ./fixtures/test-node/genesis-alonzo.json;
    };

    genesisConway = lib.mkOption {
      internal = true;
      type = lib.types.path;
      default = ./fixtures/test-node/genesis-conway.json;
    };

    genesisByron = lib.mkOption {
      internal = true;
      type = lib.types.path;
      default = ./fixtures/test-node/genesis-byron.json;
    };

    genesisShelley = lib.mkOption {
      internal = true;
      type = lib.types.path;
      default = ./fixtures/test-node/genesis-shelley.json;
    };

    # The following options are wrappers for the options provided by the cardano-node
    nodeConfigFile = lib.mkOption {
      internal = true;
      type = lib.types.path;
      default = ./fixtures/test-node/config.json;
    };

    vrfKey = lib.mkOption {
      internal = true;
      type = lib.types.path;
      default = ./fixtures/test-node/vrf.skey;
    };

    kesKey = lib.mkOption {
      internal = true;
      type = lib.types.path;
      default = ./fixtures/test-node/kes.skey;
    };

    delegationCertificate = lib.mkOption {
      internal = true;
      type = lib.types.path;
      default = ./fixtures/test-node/byron-delegation.cert;
    };

    operationalCertificate = lib.mkOption {
      internal = true;
      type = lib.types.path;
      default = ./fixtures/test-node/opcert.cert;
    };

    signingKey = lib.mkOption {
      internal = true;
      type = lib.types.path;
      default = ./fixtures/test-node/byron-delegate.key;
    };

    topology = lib.mkOption {
      internal = true;
      type = lib.types.path;
      default = ./fixtures/test-node/topology.json;
    };

  };

  config = lib.mkIf cfg.enable {
    # Set the `cardano.network` option to `private` which has network magic 42.
    # In particular, this matches the `networkMagic` value in
    # `./fixtures/test-node/genesis-shelley.json`
    cardano.network = lib.mkForce "private";

    # Create a directory of the test node's config files
    # We don't just link the Cardano node directly to the files in
    # `./fixtures/test-node/`? This is because we need to dynamically fill some
    # values in when the system is running e.g. the system start time.
    systemd.services.cardano-node-config = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      before = [ "cardano-node.service" ];
      serviceConfig = {
        Type = "oneshot";
        Restart = "on-failure";
        RemainAfterExit = true;
        User = "cardano-node";
        Group = "cardano-node";
        ConfigurationDirectory = [ cfg.testNodeConfigDirectory ];
      };

      path = [ pkgs.jq ];
      script = ''
        # If we've built the configuration before, then don't do
        # anything.
        if test -f "$CONFIGURATION_DIRECTORY/done" # REMARK: we know that ConfigurationDirectory has only one element
        then
            exit 0
        fi

        # Copy most of the configuration files over
        install -o cardano-node -g cardano-node -m 664 ${cfg.nodeConfigFile} "$CONFIGURATION_DIRECTORY/config.json"
        install -o cardano-node -g cardano-node -m 664 ${cfg.genesisAlonzo} "$CONFIGURATION_DIRECTORY/genesis-alonzo.json"
        install -o cardano-node -g cardano-node -m 664 ${cfg.genesisConway} "$CONFIGURATION_DIRECTORY/genesis-conway.json"
        install -o cardano-node -g cardano-node -m 600 ${cfg.vrfKey} "$CONFIGURATION_DIRECTORY/vrf.skey"
        install -o cardano-node -g cardano-node -m 600 ${cfg.kesKey} "$CONFIGURATION_DIRECTORY/kes.skey"
        install -o cardano-node -g cardano-node -m 600 ${cfg.delegationCertificate} "$CONFIGURATION_DIRECTORY/byron-delegation.cert"
        install -o cardano-node -g cardano-node -m 600 ${cfg.operationalCertificate} "$CONFIGURATION_DIRECTORY/opcert.cert"
        install -o cardano-node -g cardano-node -m 600 ${cfg.signingKey} "$CONFIGURATION_DIRECTORY/byron-delegate.key"
        install -o cardano-node -g cardano-node -m 600 ${cfg.topology} "$CONFIGURATION_DIRECTORY/topology.json"

        # Copy the configuration files that require additional initialization
        # on boot
        START_TIME="$(date -u)"

        jq '.startTime |= $start_time' \
          --argjson start_time "$(date -d "$START_TIME" +%s)" \
          < ${cfg.genesisByron} \
          > "$CONFIGURATION_DIRECTORY/genesis-byron.json"

        jq '.systemStart |= $start_time' \
          --arg start_time "$(date -d "$START_TIME" -u +%FT%TZ)" \
          < ${cfg.genesisShelley} \
          > "$CONFIGURATION_DIRECTORY/genesis-shelley.json"

        touch "$CONFIGURATION_DIRECTORY/done"
      '';
    };

    # Setup the cardano node
    cardano.node.enable = true;
    cardano.node.copyCardanoNodeConfigToEtc = lib.mkForce false;

    # Change the cardano node s.t. it uses a custom setup
    services.cardano-node = {
      nodeConfigFile = "/etc/${cfg.testNodeConfigDirectory}/config.json";
      topology = "/etc/${cfg.testNodeConfigDirectory}/topology.json";
      kesKey = "/etc/${cfg.testNodeConfigDirectory}/kes.skey";
      vrfKey = "/etc/${cfg.testNodeConfigDirectory}/vrf.skey";
      operationalCertificate = "/etc/${cfg.testNodeConfigDirectory}/opcert.cert";
      delegationCertificate = "/etc/${cfg.testNodeConfigDirectory}/byron-delegation.cert";
      signingKey = "/etc/${cfg.testNodeConfigDirectory}/byron-delegate.key";

      # Override the `useSystemdReload` from the `./node.nix` defaults that
      # messes with things. Note that if `useSystemdReload` is true, it makes
      # the `cardano-node` go looking in `/etc/cardano-node/topology-0.yaml`
      # instead of whatever value we provide. See
      # https://github.com/IntersectMBO/cardano-node/blob/aec56982f99a3e94d6cde969f666133ff2f68890/nix/nixos/cardano-node-service.nix#L586-L599
      # for details.
      useSystemdReload = lib.mkForce false;
    };

    systemd.services.test-cardano-node-initial-funds = {
      description = "Pays LOVELACE to the initialFunds at most once.";
      after = [ "cardano-node-socket.service" ];
      requires = [ "cardano-node.service" ];
      bindsTo = [ "cardano-node.service" ];
      requiredBy = [ "cardano-node.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StateDirectory = [ "test-cardano-node-initial-funds" ];
      };
      environment = {
        inherit (config.environment.variables)
          FAUCET
          FAUCET_SKEY
          CARDANO_NODE_SOCKET_PATH
          CARDANO_NODE_NETWORK_ID
          ;
      };
      path = [ pkgs.request-from-faucet ];
      script = ''
        # Check if we've already initialized. If we have, then we're done.
        if test -f /var/lib/test-cardano-node-initial-funds/done
        then
            1>&2 echo "Initial funds have already been distributed, so doing nothing."
            exit 0
        fi

        1>&2 echo "Distributing initial funds."
        ${lib.attrsets.foldlAttrs (
          acc: addr: amountOrAmounts:
          # WARNING(jaredponn): probably terrible time complexity.
          # NOTE(jaredponn): Loosely, this convoluted nix
          # expression builds a shell script like
          # ```
          # request-from-faucet --address <addr1> --amount <amount11>
          # request-from-faucet --address <addr1> --amount <amount12>
          # request-from-faucet --address <addr2> --amount <amount2>
          # ```
          # when given an `initialFunds` like
          # ```
          # { <addr1> = [ <amount11> <amount12> ]; <addr2> =  <amount2>; }
          # ```
          let
            amounts = if builtins.typeOf amountOrAmounts == "int" then [ amountOrAmounts ] else amountOrAmounts;
          in
          ''
            ${acc}
            ${builtins.concatStringsSep "\n" (builtins.map (amount: ''request-from-faucet --address  ${lib.escapeShellArg addr} --amount ${builtins.toString amount}'') amounts)}
          ''
        ) "" cfg.initialFunds}

        touch /var/lib/test-cardano-node-initial-funds/done

        1>&2 echo "Finished distributing initial funds."
      '';
    };

    nixpkgs.overlays = [
      (_self: _super: {
        # Add the package `request-from-faucet`
        request-from-faucet = pkgs.writeShellApplication {
          name = "request-from-faucet";
          runtimeInputs = [
            pkgs.jq
            pkgs.cardano-cli
          ];

          text = ''
            while test "$#" -gt 0; do
                case "$1" in
                    --address)
                        shift
                        ADDRESS="$1"
                        shift
                        ;;
                    --amount)
                        shift
                        AMOUNT="$1"
                        shift
                        ;;
                    -h|--help)
                        1>&2 echo "Usage: $0 --address <BECH32-ADDRESS> --amount <AMOUNT>"
                        1>&2 echo "Pays <AMOUNT> lovelace (a base 10 integer) to <BECH32-ADDRESS> (human readable bech32 address) from the address specified by the \$FAUCET environment variable using the private key located in the file specified by the \$FAUCET_SKEY environment variable. This uses 'cardano-cli' internally, and hence requires the \$CARDANO_NODE_SOCKET_PATH and \$CARDANO_NODE_NETWORK_ID environment variables to be set appropriately."
                        exit 1
                        ;;
                    *)
                        1>&2 echo "$0: unrecognized option '$1'"
                        1>&2 echo "Try '$0 --help' for more information."
                        exit 1
                        ;;
                esac
            done

            1>&2 echo "Creating a UTxO for $ADDRESS with $AMOUNT lovelace from $FAUCET"

            # Temporary working directory
            TMP="$(mktemp -d)"
            trap "rm -rf \$TMP" EXIT

            # Build and sign the tx from the faucet

            # NOTE(jaredponn) Most of the tx building follows from the following articles:
            # - https://developers.cardano.org/docs/get-started/create-simple-transaction/
            # - https://github.com/cardano-scaling/hydra/blob/master/demo/seed-devnet.sh

            1>&2 echo "Building and signing the transaction"

            # Create a tx which:
            # - Uses the first largest in lovelace 64 UTxOs
            #   from the FAUCET address to finance the
            #   transaction. We limit it to using 64 UTxOs
            #   to help stay under transaction size limits.
            # - Pay a single transaction output to ADDRESS
            #   with the specified AMOUNT

            # We ignore these shellcheck warnings (they
            # arise from getting the tx-ins from the FAUCET
            # address) because we know the form of the
            # tx-ins is `<base16-digits>#<base10-digits>`
            # shellcheck disable=SC2162
            # shellcheck disable=SC2046
            1>&2 cardano-cli conway transaction build \
                --change-address "$FAUCET" \
                $(cardano-cli query utxo --output-json --address "$FAUCET" \
                    | jq -r 'to_entries | sort_by(- .value.value.lovelace) | map(.key) | .[0:64] | .[]' \
                    | while read FAUCET_TX_IN; do echo "--tx-in" "$FAUCET_TX_IN" ; done) \
                --tx-out "$ADDRESS"+"$AMOUNT" \
                --out-file tx.draft

            1>&2 cardano-cli conway transaction sign \
                --tx-body-file  tx.draft \
                --signing-key-file "$FAUCET_SKEY" \
                --out-file tx.signed

            TX_ID="$(cardano-cli conway transaction txid --tx-file tx.signed)"
            TX_IN="$TX_ID#0"

            1>&2 cardano-cli conway transaction submit --tx-file tx.signed

            1>&2 echo "Finished building and signing transaction $TX_ID"

            # Await the tx
            1>&2 echo "Awaiting $TX_ID by waiting for tx-in $TX_IN"

            while test "$(cardano-cli query utxo --tx-in "$TX_IN" --output-json | jq length)" -eq 0; do
                sleep 1
                1>&2 echo -n "."
            done

            1>&2 echo ""

            1>&2 echo "Done"
          '';
        };
      })
    ];

    environment = {
      variables = {
        FAUCET = "addr_test1vztc80na8320zymhjekl40yjsnxkcvhu58x59mc2fuwvgkc332vxv";
        FAUCET_SKEY = ./fixtures/test-node/faucet.skey;
      };

      systemPackages = [ pkgs.request-from-faucet ];
    };
  };
}
