FROM python

RUN curl -sSfL https://github.com/VOICEVOX/voicevox_core/releases/latest/download/download.sh | bash -s
RUN wget https://github.com/VOICEVOX/voicevox_core/releases/download/0.14.1/voicevox_core-0.14.1+cpu-cp38-abi3-linux_x86_64.whl
RUN pip install voicevox_core-0.14.1+cpu-cp38-abi3-linux_x86_64.whl

# RUN curl -sSfL https://github.com/VOICEVOX/voicevox_core/releases/latest/download/download.sh | bash -s -- --cpu-arch arm64
# RUN wget https://github.com/VOICEVOX/voicevox_core/releases/download/0.14.1/voicevox_core-0.14.1+cpu-cp38-abi3-linux_aarch64.whl
# RUN pip install voicevox_core-0.14.1+cpu-cp38-abi3-linux_aarch64.whl

ENV LD_LIBRARY_PATH=./voicevox_core

COPY app.py . 
