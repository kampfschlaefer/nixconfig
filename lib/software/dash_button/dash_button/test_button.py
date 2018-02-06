
from scapy.all import *


def run():
    sendp(
        Ether(dst='ff:ff:ff:ff:ff:ff') / ARP(
            hwsrc='ac:63:be:be:01:93', pdst='192.168.1.1', op=ARP.who_has
        )
    )
