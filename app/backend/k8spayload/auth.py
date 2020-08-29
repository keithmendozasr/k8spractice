""" Handle session info """

import functools
import logging
from flask import g, abort, make_response, session, current_app, Blueprint, request
from werkzeug.exceptions import BadRequest

bp = Blueprint('auth', __name__)

@bp.route('/login', methods=['POST'])
def __load_session_data():
    """ Handle /authenticate request"""
    __logger = current_app.logger
    obj = None
    try:
        payload = request.get_json()
        if payload.get('user') == 'user' and payload.get('password') == 'password':
            __logger.debug('User authorized')
            session['token'] = 'token'
            obj = make_response({})
        else:
            __logger.warning('User rejected')
            obj = make_response({'error': 'Invalid creds'}, 401)
    except BadRequest:
        obj = make_response({'error': 'Failed to parse data'}, 400)

    return obj
