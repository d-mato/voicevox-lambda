# FROM public.ecr.aws/lambda/python:3.10 as builder
# WORKDIR /opt

# RUN yum install -y tar unzip gzip wget gcc make bison

# # RUN wget -c https://ftp.gnu.org/gnu/glibc/glibc-2.29.tar.gz
# # RUN tar xf glibc-2.29.tar.gz
# # RUN cd glibc-2.29 && \
# #   mkdir glibc-build && \
# #   cd glibc-build && \
# #   ../configure --prefix=/opt/glibc-2.29/glibc-build && \
# #   make && make install

# RUN curl -sSfL https://github.com/VOICEVOX/voicevox_core/releases/latest/download/download.sh | bash -s
# RUN wget https://github.com/VOICEVOX/voicevox_core/releases/download/0.14.1/voicevox_core-0.14.1+cpu-cp38-abi3-linux_x86_64.whl
# RUN mv voicevox_core/libonnxruntime.so.1.13.1 $LAMBDA_TASK_ROOT/
# RUN mv voicevox_core/open_jtalk_dic_utf_8-1.11 $LAMBDA_TASK_ROOT/
# RUN pip install \
#   --target $LAMBDA_TASK_ROOT \
#   voicevox_core-0.14.1+cpu-cp38-abi3-linux_x86_64.whl


# FROM public.ecr.aws/lambda/python:3.10

# COPY --from=builder $LAMBDA_TASK_ROOT $LAMBDA_TASK_ROOT
# COPY app.py $LAMBDA_TASK_ROOT

# CMD ["app.handler"]



# Define function directory
ARG FUNCTION_DIR="/function"

# FROM python:buster as builder
FROM python:buster
ARG FUNCTION_DIR
RUN mkdir ${FUNCTION_DIR}

RUN apt-get update && \
  apt-get install -y \
  g++ \
  make \
  cmake \
  unzip \
  libcurl4-openssl-dev \
  gawk \
  bison

WORKDIR /opt
RUN curl -sSfL https://github.com/VOICEVOX/voicevox_core/releases/latest/download/download.sh | bash -s
RUN mv voicevox_core/libonnxruntime.so.1.13.1 ${FUNCTION_DIR}/
RUN mv voicevox_core/open_jtalk_dic_utf_8-1.11 ${FUNCTION_DIR}/
RUN wget https://github.com/VOICEVOX/voicevox_core/releases/download/0.14.1/voicevox_core-0.14.1+cpu-cp38-abi3-linux_x86_64.whl
RUN pip install \
  --target ${FUNCTION_DIR} \
  awslambdaric \
  voicevox_core-0.14.1+cpu-cp38-abi3-linux_x86_64.whl

WORKDIR /opt
RUN wget -c https://ftp.gnu.org/gnu/glibc/glibc-2.29.tar.gz
RUN tar xf glibc-2.29.tar.gz
WORKDIR /opt/glibc-build
RUN /opt/glibc-2.29/configure --prefix=${WORKDIR} && make && make install


# FROM python:buster
# ARG FUNCTION_DIR
# WORKDIR ${FUNCTION_DIR}

# COPY --from=builder /lib/x86_64-linux-gnu/libm.so.* /lib/x86_64-linux-gnu/
# COPY --from=builder ${FUNCTION_DIR} ${FUNCTION_DIR}
COPY app.py ${FUNCTION_DIR}

ENTRYPOINT [ "/usr/local/bin/python", "-m", "awslambdaric" ]
CMD [ "app.handler" ]
