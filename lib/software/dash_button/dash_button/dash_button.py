
import argparse
import configparser
import json
import logging
import time
from scapy.all import *
import paho.mqtt.client as mqtt

last_trigger = 0
blackout_time = 0
session = None
config = None
logger = None


def run():

    def arp_handle(pkt):
        global last_trigger
        global blackout_time
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
                else:
                    logger.info(
                        "Found Button %s, will fire event for that mac", mac
                    )
                    last_trigger = time.time()

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
            'server': 'mqtt',
            'port': 1883,
            'user': '',
            'password': '',
            'client_id': 'dash_button_daemon',
            'blackout_time': 10,
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

    client = mqtt.Client(
        client_id=config.get('DEFAULT', 'client_id'),
        clean_session=True
    )
    client.username_pw_set(
        username=config.get('DEFAULT', 'user'),
        password=config.get('DEFAULT', 'password')
    )
    client.connect(
        config.get('DEFAULT', 'server'),
        config.getint('DEFAULT', 'port')
    )

    logger.info("Dashbutton Daemon ready for action")

    while True:
        sniff(
            iface=[config.get('DEFAULT', 'interface')],
            prn=arp_handle,
            filter="arp",
            store=0,
            count=0,
        )
