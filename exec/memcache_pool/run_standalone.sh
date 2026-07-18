config_path=$(realpath ../../modules/mmc-local-standalone.conf)
if [[ ! -f "$config_path" ]]; then
    echo "错误: 配置文件不存在: $config_path"
    exit 1
fi


export MMC_LOCAL_CONFIG_PATH=$config_path
python3 memcache_standalone.py