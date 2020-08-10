"""Kubernetes Training backend payload

Back-end component for my own Kubernetes training purposes
"""

from flask import Flask, Blueprint

bp = Blueprint('base', __name__)

class BaseResponse:
    """Base response object

    To be used for what to send back to the HTTP caller
    """

    def __init__(self):
        self.menu = None
        self.body = None

    def add_menu(self, title, link):
        """Add item to menu response property
        Parameters
        ----------
        title : str
            Title to display for menu item
        link : str
            Link path
        """

        if self.menu:
            self.menu.append({
                'title': title,
                'link': link
            })
        else:
            self.menu = [{
                'title': title,
                'link': link
            }]

    def __iter__(self):
        """Generate the response object items"""

        yield 'menu', self.menu
        yield 'body', self.body

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
