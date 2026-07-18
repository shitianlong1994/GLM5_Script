import time

from memcache_hybrid import DistributedObjectStore


if __name__ == "__main__":
    store = DistributedObjectStore()
    res = store.init(0)
    if res != 0:
        print(f"Failed to initialize memcache, res = {res}")
        exit(1)
    print("Successfully initialized memcache. ")

    while True:
        time.sleep(1)