#!/usr/bin/python3

import argparse
import time

import paho.mqtt.client as mqtt

parser = argparse.ArgumentParser()
parser.add_argument(
    "command",
    type=str,
    choices=['send', 'send_persisting', 'recv'],
)
parser.add_argument(
    "topic",
    type=str,
    help="The topic to send the message to, or the topic to subscribe and "
         "receive a message"
)
parser.add_argument(
    "message",
    nargs='?',
    default=None,
    help="Message to be sent"
)

args = parser.parse_args()


def stop_loop(client, *args, **kwargs):
    client.loop_stop()


def recv_message(client, userdata, message):
    print(message.payload.decode())


def on_connect(client, userdata, rc):
    # print("Connect with status %s" % str(rc))
    pass


def on_subscribe(client, userdata, mid, granted_qos):
    # print("Success subscribing to mid %i" % mid)
    pass


client = mqtt.Client(client_id="nixos_test_client", clean_session=False)

client.on_publish = stop_loop
client.on_message = recv_message
client.on_connect = on_connect
client.on_subscribe = on_subscribe

client.connect('mqtt.arnoldarts.de', port=1883)

client.loop_start()

if args.command == 'send':
    client.publish(args.topic, args.message, qos=0, retain=False)
elif args.command == 'send_persisting':
    client.publish(args.topic, args.message, qos=0, retain=True)
elif args.command == 'recv':
    client.subscribe(args.topic, 0)
    time.sleep(2)
else:
    raise NotImplementedError
