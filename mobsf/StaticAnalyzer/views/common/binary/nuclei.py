# -*- coding: utf_8 -*-
"""Get secret text from binary in use nuclei."""
import subprocess
import logging
import json

from os import remove
from os.path import expanduser

home = expanduser("~") + '/'
logger = logging.getLogger(__name__)

def parse_json(json_path, app_dir):
    with open(json_path) as f:
        decode_json = json.load(f)
        
    for val in decode_json:
        val['matched-at'] = str(val['matched-at']).replace(app_dir, '')
    return decode_json


def get_secret_text_from_binary(app_type, src, bin_name):
    logger.info("Get Secrets Info from Binary")

    app_dir = ''
    if app_type == "apk":
        app_dir = src + 'apktool_out' + '/'
    elif app_type == 'ipa':
        app_dir = src + bin_name + '.app' + '/'
    elif app_type == 'dylib' or app_type == 'so' or app_type == 'aar':
        app_dir = src + bin_name
    command = ['echo', app_dir]
    command2 = ['nuclei', '-file', '-t', home + 'nuclei-templates/file/keys/', '-et', home + 'nuclei-templates/file/keys/credential-exposure-file.yaml', '-je', app_dir + 'tmp.json']

    try:
        result_echo = subprocess.Popen(command, stdout=subprocess.PIPE)
        subprocess.run(command2, capture_output=True, text=True, check=True, stdin=result_echo.stdout)
    except subprocess.CalledProcessError as e:
        logger.error(e.stderr)
    json_path = app_dir + 'tmp.json'
    secrets_json = parse_json(json_path, app_dir)

    remove(json_path)
    return secrets_json