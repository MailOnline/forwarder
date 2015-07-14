import socket

class StompClient:
    def __init__(self, host, port):
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

        self.server.connect((host, port))

    def send_frame(self, cmd, headers, body=None):
        m = cmd + "\n"
        for key, value in headers.iteritems():
            m += "%s: %s\n" % (key, value)
        m += "\n"
        if body:
            m += body
        m += "\0"
        self.server.sendall(m)

    def connect(self, login, passcode, vhost):
        self.send_frame("CONNECT", {'login': login, 'passcode': passcode, 'host': vhost})

    def send(self, exchange, message):
        self.send_frame("SEND", {'destination': "/exchange/%s" % exchange}, message)
