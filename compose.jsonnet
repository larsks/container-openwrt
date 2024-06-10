function(lan0_nodes=1, lan1_nodes=1)
  local node(hostname, network, gateway) = {
    hostname: hostname,
    build: {
      context: 'node',
      dockerfile: 'Containerfile',
    },
    init: true,
    cap_add: [
      'NET_ADMIN',
    ],
    networks: [
      network,
    ],
    environment: {
      DEFAULT_GATEWAY: gateway,
    },
  };

  {
    volumes: {
      state: null,
    },
    networks: {
      wan: {
        driver: 'bridge',
        ipam: {
          driver: 'default',
          config: [
            {
              subnet: '10.1.3.0/24',
              ip_range: '10.1.3.192/26',
              gateway: '10.1.3.1',
            },
          ],
        },
      },
      lan0: {
        driver: 'bridge',
        internal: true,
        driver_opts: {
          'com.docker.network.bridge.inhibit_ipv4': 'true',
        },
        ipam: {
          driver: 'default',
          config: [
            {
              subnet: '10.1.5.0/24',
            },
          ],
        },
      },
      lan1: {
        driver: 'bridge',
        internal: true,
        driver_opts: {
          'com.docker.network.bridge.inhibit_ipv4': 'true',
        },
        ipam: {
          driver: 'default',
          config: [
            {
              subnet: '10.1.7.0/24',
            },
          ],
        },
      },
    },
    services: {
      openwrt: {
        build: {
          context: '.',
          dockerfile: 'Containerfile',
          args: {
            OPENWRT_VERSION: '23.05.3',
          },
        },
        networks: [
          'wan',
          'lan0',
          'lan1',
        ],
        environment: {
          DEFAULT_GATEWAY: '10.1.3.1',
        },
        ports: [
          '8080:80',
          '8443:443',
          '8222:22',
        ],
        cap_add: [
          'NET_ADMIN',
        ],
        devices: [
          '/dev/net/tun',
          '/dev/kvm',
        ],
        init: true,
        stdin_open: true,
        tty: true,
        volumes: [
          'state:/state',
        ],
        healthcheck: {
          test: [
            'CMD',
            'curl',
            '-Ssf',
            'http://localhost',
          ],
          interval: '10s',
          timeout: '5s',
          retries: 3,
        },
      },
      dnsmasq: {
        build: {
          context: 'dnsmasq/',
          dockerfile: 'Containerfile',
        },
        networks: [
          'wan',
        ],
        cap_add: [
          'NET_ADMIN',
        ],
        init: true,
        environment: {
          DHCP_RANGE_START: '10.1.3.10',
          DHCP_RANGE_END: '10.1.3.100',
          DHCP_NETMASK: '255.255.255.0',
          DEFAULT_GATEWAY: '10.1.3.1',
        },
      },
    } {
      ['node-0-%d' % i]: node('node-0-%d' % i, 'lan0', '10.1.5.1')
      for i in std.range(0, lan0_nodes - 1)
    } {
      ['node-1-%d' % i]: node('node-1-%d' % i, 'lan1', '10.1.7.1')
      for i in std.range(0, lan1_nodes - 1)
    },
  }
