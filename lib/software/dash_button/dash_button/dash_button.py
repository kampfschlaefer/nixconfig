
import argparse
import configparser
import homeassistant.remote as ha
import json
import logging
import time
from scapy.all import *


logger = logging.getLogger()

logging.basicConfig(level=logging.DEBUG)


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
        'blackout_time': 10,
        # 'api_password': None
    }
})
logger.debug(
    "Reading config from: %s",
    str(config.read([
        './.dash_button.cfg',
        os.path.expanduser('~/.dash_button.cfg'),
        '/etc/dash_button/dash_button.cfg'
    ]))
)

if args.config:
    config.read_file(args.config)

if not config.sections():
    logger.error("Need at least one section for a button/MAC address")
    sys.exit(1)

blackout_time = config.getint('DEFAULT', 'blackout_time')

logger.debug("1: creating API object")
api = ha.API(
    host=config.get('DEFAULT', 'host'),
    port=config.getint('DEFAULT', 'port'),
    use_ssl=config.getboolean('DEFAULT', 'use_ssl'),
    api_password=config.get('DEFAULT', 'api_password', fallback=None),
)

i = 20
logger.debug("2: try to validate api")
api_reachable = api.validate_api()
while not api_reachable and i > 0:
    logger.debug("3: failed to validate api, %i remaining tries", i)
    time.sleep(2)
    i -= 1
    api_reachable = api.validate_api()

if not api_reachable:
    logger.error("API not reachable with the given parameters:")
    logger.error(config.items('DEFAULT'))
    sys.exit(2)

logger.info("Dashbutton Daemon ready for action")

last_trigger = 0  # time.time()


def arp_handle(pkt):
    global last_trigger
    if (
        ARP in pkt and pkt[ARP].op == 1 and  # who-has (request)
        abs(time.time() - last_trigger) > blackout_time
    ):
        mac = pkt[ARP].hwsrc.lower()
        logger.debug("Found ARP request")
        if mac in config.sections():
            if (
                config.has_option(mac, 'domain') and
                config.has_option(mac, 'action')
            ):
                domain = config.get(mac, 'domain')
                action = config.get(mac, 'action')
                data = json.loads(config.get(mac, 'data', fallback=''))
                logger.info(
                    "Found Button %s, will execute %s.%s with data %s",
                    mac, domain, action, data
                )
                ha.call_service(api, domain, action, data)
            else:
                logger.info(
                    "Found Button %s, will fire event for that mac", mac
                )
                ha.fire_event(api, 'dash_button_pressed', {'mac': mac})
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
