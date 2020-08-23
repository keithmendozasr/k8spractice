"""Kubernetes Training backend payload

Back-end component for my own Kubernetes training purposes
"""

import logging
from logging.config import dictConfig

from flask import Flask, Blueprint

from .baseresponse import BaseResponse

bp = Blueprint('base', __name__)

@bp.route('/load')
def load():
    """ Handle /load request"""
    logger = logging.getLogger(__name__)
    logger.info('Handling "load" REST API')

    payload = BaseResponse()
    payload.add_menu('item 1', '/item1')
    payload.add_menu('item 2', '/item2')
    payload.add_menu('item 3', '/item3')

    payload.body = {
        'parta': 1,
        'partb' : ('a', 'b', 'c', 'd'),
        'partc': {
            'grp1': '1',
            'grp2': 'Group 2',
            'grp3': (1, 2, 3)
        }
    }

    return dict(payload) #.to_response()

@bp.route('/nomenu')
def no_menu():
    """ Handle /nomenu request"""
    logger = logging.getLogger(__name__)
    logger.info('Handling "nomenu" REST API')

    payload = BaseResponse()
    payload.body = {
        'par1': 'Par 1'
    }

    return dict(payload)

def create_app():
    """Application factory"""

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
    app.register_blueprint(bp, url_prefix='/api')
    app.logger.info('App ready')

    return app

if __name__ == '__main__':
    create_app().run()
