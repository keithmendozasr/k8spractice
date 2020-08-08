from flask import Flask, Blueprint

bp = Blueprint('base', __name__)

@bp.route('/load')
def load():
    return {
        'state': "ok"
    }

def create_app():
    app = Flask(__name__, instance_relative_config=True)
    app.register_blueprint(bp, url_prefix='/api')

    return app
