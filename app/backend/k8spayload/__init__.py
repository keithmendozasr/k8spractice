"""Kubernetes Training backend payload

Back-end component for my own Kubernetes training purposes
"""

import logging
from logging.config import dictConfig
import os

from flask import Flask

from . import front, auth # pylint: disable=import-self

dictConfig({
    'version': 1,
    'formatters': {
        'default': {
            'format': '[%(asctime)s] %(levelname)s %(module)s: %(message)s',
        }
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'default',
            'stream': 'ext://sys.stdout'
        }
    },
    'root': {
        'level': 'INFO',
        'handlers': ['console']
    }
})

app = Flask(__name__, instance_relative_config=True)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY')
app.config['DB_DSN'] = os.environ.get('DB_DSN')
app.config['REDIS_HOST'] = os.environ.get('REDIS_HOST')
app.config['REDIS_PORT'] = os.environ.get('REDIS_PORT')
app.register_blueprint(front.bp, url_prefix='/api')
app.register_blueprint(auth.bp, url_prefix='/api/auth')
app.logger.info('App ready')
