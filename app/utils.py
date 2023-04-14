import logging
import sys


def create_logger(name: str) -> logging.Logger:
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    if not logger.handlers:
        handler = logging.StreamHandler(stream=sys.stdout)
        formatter = logging.Formatter(
            "{'time': '%(asctime)s', 'name': '%(name)s', 'level': '%(levelname)s', 'message': '%(message)s'}"
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
    return logger
