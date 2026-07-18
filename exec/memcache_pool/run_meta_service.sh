meta_config_path=$(realpath ../../modules/mmc-meta.conf)
local_config_path=$(realpath ../../modules/mmc-local.conf)
host_ip="${1:-192.168.0.48}"  
if [[ ! -f "$meta_config_path" ]]; then
    echo "错误: 配置文件不存在: $meta_config_path"
    exit 1
fi

if [[ ! -f "$local_config_path" ]]; then
    echo "错误: 配置文件不存在: $local_config_path"
    exit 1
fi

sed -i \
    -e "s|^\(ock\.mmc\.meta_service_url\s*=\s*tcp://\)[0-9.]*|\1${host_ip}|" \
    -e "s|^\(ock\.mmc\.meta_service\.config_store_url\s*=\s*tcp://\)[0-9.]*|\1${host_ip}|" \
    "$meta_config_path"

sed -i \
    -e "s|^\(ock\.mmc\.meta_service_url\s*=\s*tcp://\)[0-9.]*|\1${host_ip}|" \
    -e "s|^\(ock\.mmc\.local_service\.config_store_url\s*=\s*tcp://\)[0-9.]*|\1${host_ip}|" \
    "$local_config_path"

export MMC_META_CONFIG_PATH=${meta_config_path}
python3 -c "from memcache_hybrid import MetaService; MetaService.main()"