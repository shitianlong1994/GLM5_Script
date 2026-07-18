此脚本为glm5.2-w4a8c8 memcache部署方案

参考:[glm5.1 4机池化方案](https://gitcode.com/Ascend/memcache/wiki/MMC%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E2%80%94GLM-5.1+A3-4%E6%9C%BAPD%E5%88%86%E7%A6%BB.md)

# 脚本部署
## memcache服务拉起
脚本在:`GLM5_Script/exec/memcache_pool`
1. 在p主节点启动meta服务
```bash
cd GLM5_Script/exec/memcache_pool
# host_ip为P节点ip
bash run_meta_service.sh --${host_ip}
```
2. 在p节点和d节点分别启动local服务
在P节点
```bash
cd GLM5_Script/exec/memcache_pool
bash run_standalone.sh
```
在D节点
```bash
cd GLM5_Script/exec/memcache_pool
bash run_standalone.sh
```

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