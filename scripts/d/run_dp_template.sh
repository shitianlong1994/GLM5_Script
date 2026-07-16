nic_name="enp23s0f3" # change to your own nic name
local_ip=192.168.0.78 # change to your own ip

export HCCL_OP_EXPANSION_MODE="AIV"
#export VLLM_VERSION=0.22.0
export HCCL_IF_IP=$local_ip
export GLOO_SOCKET_IFNAME=$nic_name
export TP_SOCKET_IFNAME=$nic_name
export HCCL_SOCKET_IFNAME=$nic_name

#Mooncake
export OMP_PROC_BIND=false
export OMP_NUM_THREADS=1

export PYTORCH_NPU_ALLOC_CONF=expandable_segments:True
export HCCL_BUFFSIZE=500

export ASCEND_AGGREGATE_ENABLE=1
export ASCEND_TRANSPORT_PRINT=1
export ACL_OP_INIT_MODE=1
export ASCEND_A3_ENABLE=1
export HCCL_INTRA_ROCE_ENABLE=1
export VLLM_NIXL_ABORT_REQUEST_TIMEOUT=300000

export TASK_QUEUE_ENABLE=1
export ASCEND_RT_VISIBLE_DEVICES=$1
export VLLM_ASCEND_ENABLE_FUSED_MC2=0
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export VLLM_ASCEND_ENABLE_SFA_KV_QUANT_SPARSE_ATTENTION=1
export VLLM_ASCEND_ENABLE_SFA_PROLOG_V3=1
vllm serve /mnt/sfs_turbo_glm5/model/GLM-5.2-W4A8C8/ \
    --host 0.0.0.0 \
    --port $2 \
    --data-parallel-size $3 \
    --data-parallel-rank $4 \
    --data-parallel-address $5 \
    --data-parallel-rpc-port $6 \
    --tensor-parallel-size $7 \
    --enable-expert-parallel \
    --profiler-config \
    '{"profiler": "torch",
    "torch_profiler_dir": "./vllm_profile1",
    "torch_profiler_with_stack": false}' \
    --seed 1024 \
    --served-model-name glm-5 \
    --disable-hybrid-kv-cache-manager \
    --max-model-len 200000 \
    --max-num-batched-tokens 128 \
    --compilation-config '{"cudagraph_mode":"FULL_DECODE_ONLY"}' \
    --additional-config '{"fuse_muls_add": true, "multistream_overlap_shared_expert": true, "enable_fused_mc2": true, "recompute_scheduler_enable": true, "ascend_compilation_config": {"enable_npugraph_ex": false},"enable_sparse_c8": true}' \
    --trust-remote-code \
    --speculative-config '{"num_speculative_tokens": 5, "method":"deepseek_mtp","enforce_eager":true}' \
    --max-num-seqs 48 \
    --gpu-memory-utilization 0.92 \
    --async-scheduling \
    --enable-prefix-caching \
    --quantization ascend \
    --enable-auto-tool-choice \
    --tool-call-parser glm47 \
    --reasoning-parser glm45 \
    --kv-transfer-config \
    '{"kv_connector": "MooncakeConnectorV1",
    "kv_role": "kv_consumer",
    "kv_port": "30100",
	"engine_id": "0",
	"kv_connector_extra_config": {
            	"use_ascend_direct": true,
            	"prefill": {
                    	"dp_size": 2,
                    	"tp_size": 8
            	},
            	"decode": {
                    	"dp_size": 4,
                    	"tp_size": 4
		}
    	}
	}'
