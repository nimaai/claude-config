#!/usr/bin/env python3
import socket
import sys
import re

def nrepl_eval(port, code):
    """Send eval command to nREPL server and return response"""
    msg = f'd2:op4:eval4:code{len(code)}:{code}e'

    try:
        s = socket.socket()
        s.settimeout(5)
        s.connect(('localhost', port))
        s.send(msg.encode())

        # Read all responses until done
        responses = []
        while True:
            try:
                chunk = s.recv(8192).decode('utf-8', errors='ignore')
                if not chunk:
                    break
                responses.append(chunk)
                if 'status' in chunk and 'done' in chunk:
                    break
            except:
                break
        s.close()

        full_resp = ''.join(responses)

        # Look for error/exception in response
        if 'error' in full_resp or 'Exception' in full_resp or 'Error' in full_resp:
            print('RELOAD ERRORS:', full_resp)
            sys.exit(2)

        # Extract value if present (bencode format: 5:valueNN:content)
        value_match = re.search(r'5:value(\d+):', full_resp)
        if value_match:
            length = int(value_match.group(1))
            start = value_match.end()
            value = full_resp[start:start+length]
            print('Reload result:', value)
        else:
            print('Reload OK')

    except Exception as e:
        print(f'Connection error: {e}')
        sys.exit(2)

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('Usage: nrepl-eval.py <port> <code>')
        sys.exit(1)

    port = int(sys.argv[1])
    code = sys.argv[2]
    nrepl_eval(port, code)
