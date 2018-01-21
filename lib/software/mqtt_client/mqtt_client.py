#!/usr/bin/python3

import argparse
import time

import paho.mqtt.client as mqtt

parser = argparse.ArgumentParser()
parser.add_argument(
    "--server",
    type=str,
    default="mqtt.arnoldarts.de",
)
parser.add_argument(
    '--port',
    type=int,
    default=1883,
)
parser.add_argument(
    '--wait',
    type=float,
    default=1.0,
)
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
    print("Does this get called?")
    client.loop_stop()


def on_message(client, userdata, message):
    print("Received message on topic %s: %s" % (
        message.topic,
        message.payload  # .decode()
    ))


def on_connect(client, userdata, flags, rc):
    print("Connected")
    if (rc != 0):
        raise ValueError("Connect with status %s" % str(rc))

    if userdata.command == 'send':
        sendmsg(client, userdata)
    elif userdata.command == 'send_persisting':
        sendmsg(client, userdata, persisting=True)
    elif userdata.command == 'recv':
        subscribe_topics(client, userdata)
    else:
        raise NotImplementedError


def sendmsg(client, args, persisting=False):
    global run
    rc, mid = client.publish(
        args.topic, args.message, qos=0, retain=persisting
    )
    print("Sent message mid %i: rc %i" % (mid, rc))
    if rc != 0:
        raise ValueError("Failed to send message (rc=%i)" % rc)


def subscribe_topics(client, args):
    results = client.subscribe(args.topic, 0)
    print("Subscribed to topic %s: %s" % (args.topic, str(results)))


def on_subscribe(client, userdata, mid, granted_qos):
    # print("Success subscribing to mid %i" % mid)
    pass


def on_publish(*args, **kwargs):
    global run
    run = False
    print("Should stop now")


client = mqtt.Client(
    client_id="nixos_test_client",
    clean_session=False,
    userdata=args
)

# client.on_publish = stop_loop
client.on_message = on_message
client.on_connect = on_connect
client.on_subscribe = on_subscribe
client.on_publish = on_publish

print("do connect")
client.connect(args.server, port=args.port)

run = True
till = time.time() + args.wait
print("Should loop until %i" % till)
while run and till > time.time():
    # print("loop")
    client.loop(timeout=1.)

# client.loop_start()
#
# if args.command == 'send':
#     # client.loop_start()
#     rc, mid = client.publish(args.topic, args.message, qos=0, retain=False)
#     print('mid = %i, rc = %i' % (mid, rc))
#     if (rc != 0):
#         print("something went wrong")
#         raise ValueError("Failed to send message")
#     # ** pyho-mqtt > 1.1 (tested 1.3.1)
#     # msginfo = client.publish(args.topic, args.message, qos=0, retain=False)
#     # msginfo.wait_for_publish()
#     # print('mid = %i, rc = %i' % (msginfo.mid, msginfo.rc))
#     # if (msginfo.rc != 0):
#     #     raise ValueError("Failed to send message")
#
# elif args.command == 'send_persisting':
#     # client.loop_start()
#     rc, mid = client.publish(args.topic, args.message, qos=0, retain=True)
#     print('mid = %i, rc = %i' % (mid, rc))
#     if (rc != 0):
#         raise ValueError("Failed to send message")
#
# elif args.command == 'recv':
#     results = client.subscribe(args.topic, 0)
#     # print("Subcribed to topics: %s" % str(results))
#     till = time.time() + args.wait
#     # time.sleep(args.wait)
#     while till > time.time():
#         # client.loop(timeout=args.wait)
#         time.sleep(0.1)
#
# else:
#     raise NotImplementedError
#
# # time.sleep(args.wait)
# # client.loop_stop()
