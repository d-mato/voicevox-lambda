from contextlib import suppress
import json
from pathlib import Path
from tempfile import TemporaryFile

import voicevox_core
from voicevox_core import AccelerationMode, AudioQuery, VoicevoxCore


OPEN_JTALK_DICT_DIR = "./voicevox_core/open_jtalk_dic_utf_8-1.11"


def handler(event, context):
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

    out = Path('/tmp/audio.wav')
    core = VoicevoxCore(
        open_jtalk_dict_dir=Path(OPEN_JTALK_DICT_DIR)
    )
    core.load_model(speaker_id)
    audio_query = core.audio_query(text, speaker_id)
    wav = core.synthesis(audio_query, speaker_id)
    # out.write_bytes(wav)

    return {
        "statusCode": 201,
        "headers": {"Content-Type": "audio/wav"},
        "body": wav,
        "isBase64Encoded": True,
    }
