#!/bin/bash

# 使用方法: ./run_proxy_simple.sh <P节点IP> <D节点IP>
# 示例: ./run_proxy_simple.sh 192.168.0.55 192.168.0.175

# 检查参数

read node_p0_ip node_p1_ip node_d0_ip node_d1_ip <<< $(PYTHONUNBUFFERED=1 python ../../modules/get_ips.py)

PREFILL_REPEAT=2      # P节点重复次数（2个P实例）
DECODER_REPEAT=4      # D节点重复次数（4个D实例）

# 自动生成参数
prefiller0_hosts=""
prefiller1_hosts=""
for i in $(seq 1 $PREFILL_REPEAT); do
    prefiller0_hosts="$prefiller0_hosts $node_p0_ip"
    prefiller1_hosts="$prefiller1_hosts $node_p1_ip"
done

decoder0_hosts=""
decoder1_hosts=""
for i in $(seq 1 $DECODER_REPEAT); do
    decoder0_hosts="$decoder0_hosts $node_d0_ip"
    decoder1_hosts="$decoder1_hosts $node_d1_ip"
done

echo $prefiller0_hosts
echo $prefiller1_hosts
echo $decoder0_hosts
echo $decoder1_hosts


echo ""
echo "=========================================="
echo "Proxy 配置"
echo "=========================================="
echo "P节点: $P_IP (重复${PREFILL_REPEAT}次)"
echo "D节点: $D_IP (重复${DECODER_REPEAT}次)"
echo "=========================================="
echo ""

# 取消代理
unset http_proxy
unset https_proxy

export INFER_SERVICE_ID=`echo $HOSTNAME | awk -F'.' '{print $1}'`
## export vllm env
VLLM_LOG_DIR=/mnt/sfs_turbo/logs/${INFER_SERVICE_ID}/vllm
mkdir -p "$VLLM_LOG_DIR"

# 启动proxy
python ../../modules/1p1d_200k/load_balance_proxy_server_example.py \
    --port 8000 \
    --host 0.0.0.0 \
    --prefiller-hosts \
        $prefiller0_hosts \
        $prefiller1_hosts \
    --prefiller-ports \
        6700 6701 \
        6700 6701 \
    --decoder-hosts \
        $decoder0_hosts \
        $decoder1_hosts \
    --decoder-ports \
        6721 6722 6723 6724 \
        6721 6722 6723 6724 2>&1|tee -a "${VLLM_LOG_DIR}/proxy.log"
