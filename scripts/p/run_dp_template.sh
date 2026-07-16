nic_name="enp23s0f3" # change to your own nic name
local_ip=192.168.0.203 # change to your own ip

export HCCL_OP_EXPANSION_MODE="AIV"
export HCCL_IF_IP=$local_ip
export GLOO_SOCKET_IFNAME=$nic_name
export TP_SOCKET_IFNAME=$nic_name
export HCCL_SOCKET_IFNAME=$nic_name

export OMP_PROC_BIND=false
export OMP_NUM_THREADS=1

export PYTORCH_NPU_ALLOC_CONF=expandable_segments:True
export HCCL_BUFFSIZE=500
export ACL_OP_INIT_MODE=1
export ASCEND_A3_ENABLE=1
export HCCL_INTRA_ROCE_ENABLE=1
export VLLM_NIXL_ABORT_REQUEST_TIMEOUT=300000

export ASCEND_RT_VISIBLE_DEVICES=$1
export VLLM_ASCEND_ENABLE_FLASHCOMM1=1
export VLLM_ASCEND_ENABLE_FUSED_MC2=0
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export VLLM_ASCEND_ENABLE_SFA_KV_QUANT_SPARSE_ATTENTION=1
vllm serve /mnt/sfs_turbo_glm5/model/GLM-5.2-W4A8C8/ \
    --host 0.0.0.0 \
    --port $2 \
    --data-parallel-size $3 \
    --data-parallel-rank $4 \
    --data-parallel-address $5 \
    --data-parallel-rpc-port $6 \
    --tensor-parallel-size $7 \
    --enable-expert-parallel \
    --speculative-config '{"num_speculative_tokens": 5, "method":"deepseek_mtp","enforce_eager":true}' \
    --profiler-config \
    '{"profiler": "torch",
    "torch_profiler_dir": "./vllm_profile",
    "torch_profiler_with_stack": false}' \
    --seed 1024 \
    --served-model-name glm-5 \
    --max-model-len 200000 \
    --additional-config '{"fuse_muls_add": true,"enable_dsa_cp": true, "enable_fused_mc2": true, "multistream_overlap_shared_expert": true, "recompute_scheduler_enable": true, "ascend_compilation_config": {"enable_npugraph_ex": false},"enable_sparse_c8": true}' \
    --max-num-batched-tokens 4096 \
    --trust-remote-code \
    --max-num-seqs 80 \
    --async-scheduling \
    --enable-prefix-caching \
    --enable-chunked-prefill \
    --quantization ascend \
    --gpu-memory-utilization 0.95 \
    --enforce-eager \
    --disable-hybrid-kv-cache-manager \
    --enable-auto-tool-choice \
    --tool-call-parser glm47 \
    --reasoning-parser glm45 \
    --kv-transfer-config \
    '{"kv_connector": "MooncakeConnectorV1",
    "kv_role": "kv_producer",
    "kv_port": "37160",
    "engine_id": "0",
    "kv_connector_extra_config": {
                "use_ascend_direct": true,
                "prefill": {
                        "dp_size": 2,
                        "tp_size": 8
                },
                "decode": {
                        "dp_size": 4,
                        "tp_size": 4                 }
        }
    }'
