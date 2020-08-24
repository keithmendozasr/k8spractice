import logging
from flask import Blueprint

from . import baseresponse

bp = Blueprint('base', __name__)

@bp.route('/load')
def load():
    """ Handle /load request"""
    logger = logging.getLogger(__name__)
    logger.info('Handling "load" REST API')

    payload = baseresponse.BaseResponse()
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

    return dict(payload)

@bp.route('/nomenu')
def no_menu():
    """ Handle /nomenu request"""
    logger = logging.getLogger(__name__)
    logger.info('Handling "nomenu" REST API')

    payload = baseresponse.BaseResponse()
    payload.body = {
        'par1': 'Par 1'
    }

    return dict(payload)
