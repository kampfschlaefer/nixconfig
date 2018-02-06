
import argparse
import configparser
import json
import time
from scapy.all import *
import homeassistant.remote as ha


parser = argparse.ArgumentParser()
parser.add_argument(
    '--config', '-c',
    type=argparse.FileType('r')
)

args = parser.parse_args()

config = configparser.ConfigParser()
config.read_dict({
    'DEFAULT': {
        'interface': 'lo',
        'host': 'hass.io',
        'port': 8123,
        'use_ssl': False,
        # 'api_password': None
    }
})
print("Reading config from: %s" % str(config.read([
    './.dash_button.cfg',
    os.path.expanduser('~/.dash_button.cfg'),
    '/etc/dash_button/dash_button.cfg']
)))

if args.config:
    config.read_file(args.config)

if not config.sections():
    print("Need at least one section for a button/MAC address")
    sys.exit(1)

# print(
#     "Trying to connect to api with arguments: %s" %
#     str(config.items('DEFAULT'))
# )

api = ha.API(
    host=config.get('DEFAULT', 'host'),
    port=config.getint('DEFAULT', 'port'),
    use_ssl=config.getboolean('DEFAULT', 'use_ssl'),
    api_password=config.get('DEFAULT', 'api_password', fallback=None),
)
if not api.validate_api():
    print("API not reachable with the given parameters:")
    print(config.items('DEFAULT'))
    sys.exit(2)


last_trigger = time.time()


def arp_handle(pkt):
    global last_trigger
    if (
        ARP in pkt and pkt[ARP].op == 1 and  # who-has (request)
        abs(time.time() - last_trigger) > 10
    ):
        mac = pkt[ARP].hwsrc.lower()
        if mac in config.sections():
            domain = config.get(mac, 'domain')
            action = config.get(mac, 'action')
            data = json.loads(config.get(mac, 'data'))
            print(
                "Found Button %s, will execute %s.%s with data %s" % (
                    mac, domain, action, data
                )
            )
            ha.call_service(api, domain, action, data)
            last_trigger = time.time()


def run():
    while True:
        sniff(
            iface=[config.get('DEFAULT', 'interface')],
            prn=arp_handle,
            filter="arp",
            store=0,
            count=0,
        )
