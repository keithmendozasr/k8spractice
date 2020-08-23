"""Kubernetes Training backend payload

Back-end component for my own Kubernetes training purposes
"""

from flask import Flask, Blueprint

from .baseresponse import BaseResponse

bp = Blueprint('base', __name__)

@bp.route('/load')
def load():
    """ Handle /load request"""
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
    payload = BaseResponse()
    payload.body = {
        'par1': 'Par 1'
    }

    return dict(payload)

def create_app():
    """Application factory"""

    app = Flask(__name__, instance_relative_config=True)
    app.register_blueprint(bp, url_prefix='/api')

    return app

if __name__ == '__main__':
    create_app().run()
