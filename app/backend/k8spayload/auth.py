""" Handle session info """

import functools
import logging
import uuid
from flask import g, abort, make_response, session, current_app, Blueprint, request
from werkzeug.exceptions import BadRequest
import redis
import psycopg2
import hashlib

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

def __db_connect():
    conn = psycopg2.connect(current_app.config['DB_DSN'])
    return (conn, conn.cursor())

def __retrieve_user_info(username):
    __logger = current_app.logger

    (conn, cursor) = __db_connect()
    cursor.execute('SELECT password, iv, version FROM k8spractice.user WHERE name=%s', (username,))

    if cursor.rowcount > 1:
        raise ValueError(f"Got multiple entries for user {username} from the database")

    if cursor.rowcount == 0:
        __logger.info(f"User {username} not registered")
        return None

    data = cursor.fetchone()
    return {
        'password': data[0].tobytes(),
        'iv': data[1].tobytes(),
        'version': data[2]
    }

def __calc_password_hash(iv, cleartext, hasher):
    hasher.update(iv)
    hasher.update(cleartext)
    return hasher.digest()

def __build_hasher(version=1):
    if version == 1:
        return hashlib.sha256()

    raise ValueError(f"Unexpected password hash version {version}")

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
            if g.user is None:
                __logger.info('Session expired')
                obj = make_response({'error': 'Session expired'}, 401)
            else:
                __logger.debug(f'g.user set to {g.user}')
                obj = view(**kwargs)
        return obj

    return wrapped_view

@bp.route('/login', methods=['POST'])
def __load_session_data():
    """ Handle login request"""
    __logger = current_app.logger
    obj = None
    try:
        payload = request.get_json()
        username = payload.get('user')
        password = payload.get('password')

        if(username is None or password is None):
            __logger.info("Username or password not sent in request")
            obj = make_response({'error': 'Missing data' }, 400)
        else:
            stored_data = __retrieve_user_info(username)

            if stored_data is not None:
                hasher = __build_hasher(stored_data['version'])
                hashed_password = __calc_password_hash(stored_data['iv'], password.encode(), hasher);
                __logger.debug(f"Hashed password: {hashed_password.hex()}")
                __logger.debug(f"Stored password: {stored_data['password'].hex()}")
                if stored_data['password'] == hashed_password:
                    __logger.debug('User authorized')
                    token_val = uuid.uuid4().hex
                    __save_session_to_cache(token_val, payload.get('user'))
                    session['token'] = token_val
                    obj = make_response({})
    except BadRequest:
        obj = make_response({'error': 'Failed to parse data'}, 400)

    if obj is None:
        __logger.warning('User rejected')
        obj = make_response({'error': 'Invalid creds'}, 401)

    return obj

@bp.route('/checksession', methods=['GET'])
@session_required
def __check_session_active():
    """ Handle active session checking.

        Note that the intent is for session_required to return the 401 response
        if there's indeed not an active session associated to the requester.
        For the time being, getting an HTTP 200 indicates an active session
    """
    __logger = current_app.logger
    __logger.debug('Inside checksession')
    return {}
