# 1M 上下文配置说明

## 1. 显存与配置结论

启动日志中的以下关键信息可用于查看显存与 KV Cache 相关情况：

- `Available KV cache memory`：当前可用于 KV Cache 的显存大小。
- `GPU KV cache size`：按该配置可分配的 KV Cache 总 token 数。
- `Maximum concurrency for 1,024,000 tokens per request`：在 1M 上下文长度下，可同时处理的请求并发倍数。

### 1.1 P 节点（预填充节点）

配置：`TP=16, DP=1`

```
(Worker_TP0_DCP0_EP0 pid=239896) INFO 07-24 01:54:16 [worker.py:593] Available KV cache memory: 12.75 GiB
(EngineCore pid=239869) INFO 07-24 01:54:17 [kv_cache_utils.py:1744] GPU KV cache size: 1,996,800 tokens
(EngineCore pid=239869) INFO 07-24 01:54:17 [kv_cache_utils.py:1745] Maximum concurrency for 1,024,000 tokens per request: 1.95x
```

### 1.2 D 节点（解码节点）

配置：`DP=4, TP=4`

```
(Worker_DP3_TP0_DCP0_EP12 pid=256905) INFO 07-23 09:53:18 [worker.py:593] Available KV cache memory: 21.16 GiB
(EngineCore_DP3 pid=256763) INFO 07-23 09:53:18 [kv_cache_utils.py:1744] GPU KV cache size: 1,370,624 tokens
(EngineCore_DP3 pid=256763) INFO 07-23 09:53:18 [kv_cache_utils.py:1745] Maximum concurrency for 1,024,000 tokens per request: 1.34x
```

### 1.3 DP 调参结论

经过实验验证：

- **P 节点 `DP=2` 会 OOM**，因此不再往上调整 P 节点的 DP。
- **D 节点 `DP=8` 会 OOM**，因此不再往上调整 D 节点的 DP。

**P 节点**：计算量大。若追求更大吞吐，可向上调整 DP；若追求更好的 TTFT，应优先增大 TP 以提升计算能力。

**D 节点**：属于访存 bound 场景，计算量不大。若调大 TP，通信反而会成为瓶颈。

## 2. 为什么开启 DCP

### 2.1 vLLM TP 切分原理

vLLM 的 TP 通常沿注意力头维度切分 Q/K/V/O 投影及 MLP 权重。对于 KV Cache，若 `num_kv_heads >= TP`，则可沿 `kv_heads` 维度切分；否则每个 TP rank 需保留完整 KV Cache 副本。

### 2.2 问题背景

在 1M 长上下文场景下，KV Cache 占用显存巨大。MLA 模型的 `num_kv_heads` 为 1，当 `TP > 1` 时无法沿 `kv_heads` 维度进行 TP 切分，导致每个 TP rank 都必须保留一份完整的 KV Cache 副本，显存压力进一步放大，甚至出现显存爆炸（OOM）。

### 2.3 DCP 作用

为缓解 1M 长上下文下的显存爆炸问题，开启 DCP：在一个 TP 域内沿序列维度切分 KV Cache，降低单卡显存占用。

### 2.4 约束条件

DCP 使用需满足相关约束，详见官方文档：

[vLLM Ascend Context Parallel 特性指南](https://docs.vllm.ai/projects/vllm-ascend-cn/zh-cn/latest/user_guide/feature_guide/context_parallel.html#_5)
