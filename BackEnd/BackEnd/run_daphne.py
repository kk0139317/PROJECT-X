import os
import ssl
from daphne.server import Server
from django.core.asgi import get_asgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "BackEnd.settings")

ssl_context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
ssl_context.load_cert_chain(certfile="certificates/cert.pem", keyfile="certificates/key.pem")

application = get_asgi_application()

server = Server(
    application,
    endpoints=[
        "ssl:8443:privateKey=D:=certificates/key.pem:cert=certificates/cert.pem"
    ],
)

server.run()
