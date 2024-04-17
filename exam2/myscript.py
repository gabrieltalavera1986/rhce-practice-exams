#!/usr/bin/env python

import sys
import json
import base64

# Encoded host names (replace the below with the output from the previous Python code)
encoded_host_names = ["aG9zdDEuZXhhbXBsZS5jb20=", "aG9zdDIuZXhhbXBsZS5jb20=", "aG9zdDMuZXhhbXBsZS5jb20="]

def decode_host_names(encoded_names):
    return [base64.b64decode(name.encode()).decode() for name in encoded_names]

def main():
    # Decoding host names
    host_names = decode_host_names(encoded_host_names)

    # Constructing the inventory dictionary
    inventory = {
        "_meta": {
            "hostvars": {}
        },
        "all": {
            "hosts": host_names,
            "vars": {}
        }
    }

    # Ansible checks the CLI argument to decide what to do
    if len(sys.argv) == 2 and sys.argv[1] == '--list':
        print(json.dumps(inventory))
    elif len(sys.argv) == 2 and sys.argv[1] == '--host':
        print(json.dumps({}))
    else:
        print("Usage: {} --list or --host <hostname>".format(sys.argv[0]))
        sys.exit(1)

if __name__ == "__main__":
    main()
