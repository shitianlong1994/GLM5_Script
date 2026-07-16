unset http_proxy
unset https_proxy

python load_balance_proxy_server_example.py \
    --port 8077 \
    --host 0.0.0.0 \
    --prefiller-hosts \
       192.168.0.203 \
       192.168.0.203 \
    --prefiller-ports \
       6700 \
       6701 \
    --decoder-hosts \
      192.168.0.78 \
      192.168.0.78 \
      192.168.0.78 \
      192.168.0.78 \
    --decoder-ports \
      6721 6722 6723 6724
