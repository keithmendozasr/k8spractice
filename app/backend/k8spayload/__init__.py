"""Kubernetes Training backend payload

Back-end component for my own Kubernetes training purposes
"""

import logging
from logging.config import dictConfig

from flask import Flask

from . import front

dictConfig({
    'version': 1,
    'formatters': {
        'default': {
            'format': '[%(asctime)s] %(levelname)s %(module)s: %(message)s',
    }},
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'default',
            'stream': 'ext://sys.stdout'
    }},
    'root': {
        'level': 'DEBUG',
        'handlers': ['console']
}})

app = Flask(__name__, instance_relative_config=True)
app.register_blueprint(front.bp, url_prefix='/api')
app.logger.info('App ready')

