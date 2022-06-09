# ------------------------------------
# Util for system load monitoring
# Alex A. Taranov, 2021
# ------------------------------------

import psutil
import argparse


def output2json(output: bytes):
    lines = output.split(b'\n')
    cpu = []
    mem = []
    for line in lines:
        parts = line.split(b',', 1)
        if len(parts) == 2:
            cpu.append(float(parts[0]))
            mem.append(int(parts[1]))
        else:
            break
    return cpu, mem


if __name__ == '__main__':
    argparser = argparse.ArgumentParser(description='System load monitoring utility')
    argparser.add_argument('--interval', default=10, type=float, help='measurements interval, seconds')
    args = argparser.parse_args()
    while True:
        cpu_usage = psutil.cpu_percent(interval=args.interval)
        mem_usage = psutil.virtual_memory().used
        print(f"{cpu_usage},{mem_usage}", flush=True)

