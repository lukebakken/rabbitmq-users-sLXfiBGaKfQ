import logging
import pika
import signal
import ssl
import sys
import time
import traceback

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
logger.info("ssl.HAS_SNI: %s", ssl.HAS_SNI)
context = ssl.create_default_context(cafile="./certs/ca_certs.pem")
context.load_cert_chain("./certs/rmq-1/client_rmq-1_certificate.pem", "./certs/rmq-1/client_rmq-1_key.pem")
ssl_options = pika.SSLOptions(context, server_hostname="rmq-0")
conn_params = pika.ConnectionParameters(
    host="rmq-0", port=5671, ssl_options=ssl_options
)

sigterm_caught = False


def sigterm_handler(_signo, _stack_frame):
    logger.info("Saw SIGTERM, exiting...")
    sigterm_caught = True


signal.signal(signal.SIGTERM, sigterm_handler)

while not sigterm_caught:
    try:
        with pika.BlockingConnection(conn_params) as conn:
            ch = conn.channel()
            ch.queue_declare("foobar")
            ch.basic_publish("", "foobar", "Hello, world!")
            logger.info(ch.basic_get("foobar"))
            logger.info("sleeping 10 seconds...")
            for _x in range(10):
                if sigterm_caught:
                    break
                conn.sleep(1)
    except KeyboardInterrupt:
        logger.error("CAUGHT CTRL-C, exiting!")
        sys.exit(0)
    except:
        logger.error("CAUGHT EXCEPTION:")
        logger.error(traceback.format_exc())
        logger.info("sleeping 5 seconds...")
        time.sleep(5)
