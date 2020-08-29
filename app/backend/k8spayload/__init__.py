"""Kubernetes Training backend payload

Back-end component for my own Kubernetes training purposes
"""

import logging
from logging.config import dictConfig
import os

from flask import Flask

from . import front, auth

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
app.config['SECRET_KEY']=os.environ.get('SECRET_KEY')
app.register_blueprint(front.bp, url_prefix='/api')
app.register_blueprint(auth.bp, url_prefix='/api/auth')
app.logger.debug(f"Secret key set to {app.secret_key}")
app.logger.debug(f"Full config: {app.config}")
app.logger.info('App ready')

