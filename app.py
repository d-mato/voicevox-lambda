from contextlib import suppress
import json
from pathlib import Path
from ctypes import CDLL

OPEN_JTALK_DICT_DIR = "./open_jtalk_dic_utf_8-1.11"
CDLL(str(Path('./libonnxruntime.so.1.13.1').resolve(strict=True)))


def handler(event, context):
    import os
    os.system('find / -name libm.so.6')
    os.system('ls -l /lib')
    os.system('ls -l /lib/x86_64-linux-gnu')

    from voicevox_core import VoicevoxCore

    params = {}
    with suppress(Exception):
        parsed = json.loads(event["body"])
        params = parsed if isinstance(parsed, dict) else {}

    text = params.get("text")
    if text is None or text == "":
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "text is required"}),
        }

    speaker_id = params.get("speaker_id", 1)

    core = VoicevoxCore(
        open_jtalk_dict_dir=Path(OPEN_JTALK_DICT_DIR)
    )
    core.load_model(speaker_id)
    audio_query = core.audio_query(text, speaker_id)
    wav = core.synthesis(audio_query, speaker_id)

    return {
        "statusCode": 201,
        "headers": {"Content-Type": "audio/wav"},
        "body": wav,
        "isBase64Encoded": True,
    }
