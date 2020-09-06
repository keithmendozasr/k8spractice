""" Handle session info """

import functools
import logging
import uuid
from flask import g, abort, make_response, session, current_app, Blueprint, request
from werkzeug.exceptions import BadRequest
import redis

bp = Blueprint('auth', __name__)

def __connect_to_cache():
    return redis.Redis(host='localhost', port=6379, ssl_cert_reqs=None)

def __save_session_to_cache(token, value):
    """ Save session info to Redis cache wtih 10 minute lifetime"""
    __logger = current_app.logger
    r = __connect_to_cache()
    r.set(f'token:{token}', value, ex=600)

def __get_session_from_cache(token):
    __logger = current_app.logger
    r = __connect_to_cache()
    user = r.get(f'token:{token}')
    __logger.debug(f'Token value: {user}')
    return user

def session_required(view):
    @functools.wraps(view)
    def wrapped_view(**kwargs):
        obj = None
        __logger = current_app.logger
        __logger.debug('Checking session')

        token = session.get('token')
        if token is None:
            __logger.debug('No active session')
            obj = make_response({'error': 'Invalid session'}, 401)
        else:
            g.user = __get_session_from_cache(token)
            __logger.debug(f'g.user set to {g.user}')
            obj = view(**kwargs)
        return obj

    return wrapped_view

@bp.route('/login', methods=['POST'])
def __load_session_data():
    """ Handle /authenticate request"""
    __logger = current_app.logger
    obj = None
    try:
        payload = request.get_json()
        if payload.get('user') == 'user' and payload.get('password') == 'password':
            __logger.debug('User authorized')
            token_val = uuid.uuid4().hex
            __save_session_to_cache(token_val, payload.get('user'))
            session['token'] = token_val
            obj = make_response({})
        else:
            __logger.warning('User rejected')
            obj = make_response({'error': 'Invalid creds'}, 401)
    except BadRequest:
        obj = make_response({'error': 'Failed to parse data'}, 400)

    return obj
