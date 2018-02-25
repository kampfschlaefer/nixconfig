
from scapy.all import *


def run():
    if len(sys.argv) > 1:
        print('Sending event dash')
        sendp(
            Ether(dst='ff:ff:ff:ff:ff:ff') / ARP(
                hwsrc='ac:63:be:be:01:95', pdst='192.168.1.1', op=ARP.who_has
            )
        )
    else:
        print('Sending action dash')
        sendp(
            Ether(dst='ff:ff:ff:ff:ff:ff') / ARP(
                hwsrc='ac:63:be:be:01:93', pdst='192.168.1.1', op=ARP.who_has
            )
        )
