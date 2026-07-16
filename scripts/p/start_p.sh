# change ip to your own
python launch_online_dp.py --dp-size 2 --tp-size 8 --dp-size-local 2 --dp-rank-start 0 --dp-address 192.168.0.203 --dp-rpc-port 10521 --vllm-start-port 6700
