#!/bin/bash
sftp 192.168.1.254 <<EOF
ls
exit
EOF
# http://www.tldp.org/LDP/abs/html/here-docs.html
