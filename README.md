此脚本为glm5.2-w4a8c8 dcp部署方案

# 脚本部署
## vllm服务拉起
### p节点服务拉起
```bash
cd GLM5_Script/exec/1p1d_200k_1k
bash run_server_p_200k_1k_0601.sh
```

### d节点服务拉起
```bash
cd GLM5_Script/exec/1p1d_200k_1k
bash run_server_d_200k_1k_0601.sh
```

### proxy服务拉起
修改`GLM5_Script/modules/get_ips.py`中的,为P的ip和D的ip
```python
def get_p_and_d_ips():
    return "192.168.0.48" , "192.168.0.47"
```

```bash
cd GLM5_Script/exec/1p1d_200k_1k
bash run_proxy_200k_1k_0601.sh
```

## DCP主要修改点
### P节点
```bash
    --prefill-context-parallel-size 1 \ # pcp的size
    --decode-context-parallel-size 8 \ # dcp的size
    --cp-kv-cache-interleave-size 128 \ # kvcache 传输,需要和block_size一样
```

### D节点
```bash
    --prefill-context-parallel-size 1 \ # pcp的size
    --decode-context-parallel-size 8 \ # dcp的size
    --cp-kv-cache-interleave-size 128 \ # kvcache 传输,需要和block_size一样
```

### DCP size确定
DCP为kvcache的切分,需要和kv_head_num 以及 TP一起使用,基本的逻辑为:
kv_head_num*dcp_size = tp_size
MLA类模型kv_head_size为1