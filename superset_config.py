SQLALCHEMY_DATABASE_URI='postgresql://postgres:postgres@localhost:5432/superset'
FAB_PASSWORD_HASH_METHOD="pbkdf2:sha256"
WTF_CSRF_ENABLED=False
WTF_CSRF_EXEMPT_LIST=[]
SESSION_TYPE = 'redis'
SESSION_REDIS = {
    'host': 'localhost',
    'port': 6379,
    'db': 0,
    'password': None,
    'socket_timeout': 10
}
TALISMAN_ENABLED=False
