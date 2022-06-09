# ----------------------------------------
# ROSTELECOM API calls for verification
# Designed by: Alex A. Taranov
# Support:     taransanya@pi-mezon.ru
# ----------------------------------------

import requests
import json
import time
import sys


def extract(baseurl, sample, logger):
    endpoint = "/extract"
    duration = 0
    try:
        begin = time.perf_counter()
        resp = requests.request("POST", url=f"{baseurl}{endpoint}", data=sample["bindata"],
                                headers={"Content-Type": sample["mimetype"]})
        duration = time.perf_counter() - begin
        resp_status_code = resp.status_code
        if resp_status_code == 200:
            logger.debug(f"{endpoint} for '{sample['label'] + '/' + sample['name']:70s}' - [{resp_status_code}]")
            return resp_status_code, resp.content, duration
        else:
            resp_json = json.loads(resp.text)
    except requests.exceptions.ConnectionError:
        resp_status_code = 0
        resp_json = {"code": "0", "message": "Не удалось подключиться"}
    logger.debug(f"{endpoint} for '{sample['label'] + '/' + sample['name']:70s}' - [{resp_status_code}] - {resp_json}")
    return resp_status_code, resp_json, duration


def compare(baseurl, etemplate, vtemplate, logger):
    endpoint = "/compare"
    files = {"bio_feature": (None, vtemplate['bindata'], "application/octet-stream"),
             "bio_template": (None, etemplate['bindata'], "application/octet-stream")}
    duration = 0
    try:
        begin = time.perf_counter()
        resp = requests.request("POST", url=f"{baseurl}{endpoint}", files=files)
        duration = time.perf_counter() - begin
        resp_status_code = resp.status_code
        resp_json = json.loads(resp.text)
        '''if resp_status_code == 200:
            logger.debug(f"{endpoint} for '{(etemplate['template_id'] + ' vs ' + vtemplate['template_id']):20s}' - \
            [{resp_status_code}]")'''
    except requests.exceptions.ConnectionError:
        resp_status_code = 0
        resp_json = {"code": "0", "message": "Не удалось подключиться"}
    if resp_status_code != 200:
        logger.debug(f"{endpoint} for '{(etemplate['template_id'] + ' vs ' + vtemplate['template_id']):20s}' - \
        [{resp_status_code}] - {resp_json}")
    return resp_status_code, resp_json, duration


def health(baseurl, logger):
    endpoint = "/health"
    duration = 0
    try:
        begin = time.perf_counter()
        resp = requests.request("GET", url=f"{baseurl}{endpoint}")
        duration = time.perf_counter() - begin
        resp_status_code = resp.status_code
        resp_json = json.loads(resp.text)
    except requests.exceptions.ConnectionError:
        resp_status_code = 0
        resp_json = {"code": "0", "message": "Не удалось подключиться"}
    logger.info(f"{endpoint} - [{resp_status_code}] - {resp_json}")
    if resp_status_code != 200:
        logger.critical(f"БП неисправен! Отмена теста...")
        sys.exit(1)
    elif resp_json['status'] != 0:
        logger.critical(f"БП неисправен! Отмена теста...")
        sys.exit(1)
    return resp_status_code, resp_json, duration
