# -*- coding: utf-8 -*-
# pylint: disable=C0111,C0103,R0205

import logging
import threading
import pika
import random
import ssl
import time

LOG_FORMAT = (
    "%(levelname) -10s %(asctime)s %(name) -30s %(funcName) "
    "-35s %(lineno) -5d: %(message)s"
)
LOGGER = logging.getLogger(__name__)

logging.basicConfig(level=logging.ERROR, format=LOG_FORMAT)

stopping = False

threads = []


def do_work(i):
    while True and not stopping:
        context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
        context.verify_mode = ssl.CERT_REQUIRED
        context.load_verify_locations('./cluster/certs/ca_certificate.pem')

        thread_id = threading.get_ident()
        LOGGER.info("i: %s thread id: %s", i, thread_id)
        credentials = pika.PlainCredentials("bakkenl", "test1234")
        p = 5682 + (i % 3)
        parameters = pika.ConnectionParameters(
            host="localhost", port=p,
            credentials=credentials, heartbeat=5,
            ssl_options=pika.SSLOptions(context)
        )
        connection = pika.BlockingConnection(parameters)
        for i in range(1, random.randrange(5, 10)):
            connection.channel()
        connection.sleep(random.randrange(5, 10))
        connection.close()


for i in range(0, 63):
    t = threading.Thread(target=do_work, args=(i,))
    t.start()
    threads.append(t)

input("ANY KEY TO STOP")
print()
stopping = True
# Wait for all to complete
for thread in threads:
    thread.join()
