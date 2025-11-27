FROM nvidia/cuda:13.0.2-cudnn-devel-ubuntu24.04

# Install essentials

RUN apt-get update && apt-get install -y python3.12 python3.12-venv python3-pip git wget patch && rm -rf /var/lib/apt/lists/

# Set working directory

WORKDIR /app

# Create virtual env

RUN python3.12 -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip

RUN pip install --upgrade pip

# Install PyTorch + CUDA

RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130

# Install pre-release deps

RUN pip install xgrammar triton

RUN pip install -U --pre flashinfer-python --no-deps

RUN pip install flashinfer-python

RUN pip install -U --pre flashinfer-cubin 
# JIT cache package (replace cu129 with your CUDA version: cu128, cu129, or cu130)

RUN pip install -U --pre flashinfer-jit-cache --index-url https://flashinfer.ai/whl/cu130

# Clone vLLM

RUN git clone https://github.com/vllm-project/vllm

WORKDIR /app/vllm

RUN git fetch origin pull/26844/head:pr-26844

#RUN git -c user.name="alarmed-ground" -c user.email="peratchikannan@hyperscalers.com" merge --no-ff --no-edit pr-26844

RUN python3 use_existing_torch.py

RUN sed -i "/flashinfer/d" requirements/cuda.txt

RUN pip install -r requirements/build.txt

RUN apt-get update && apt-get install -y cmake build-essential ninja-build && rm -rf /var/lib/apt/lists/

# Set essential environment variables

ENV TORCH_CUDA_ARCH_LIST=12.1a

ENV TRITON_PTXAS_PATH=/usr/local/cuda/bin/ptxas

ENV TIKTOKEN_ENCODINGS_BASE=/app/tiktoken_encodings

# Install vLLM with local build

RUN pip install --no-build-isolation -e . -v --pre

RUN pip install --no-build-isolation -e .[audio] -v --pre

# Download tiktoken encodings

WORKDIR /app

RUN mkdir -p tiktoken_encodings && wget -O tiktoken_encodings/o200k_base.tiktoken "https://openaipublic.blob.core.windows.net/encodings/o200k_base.tiktoken" && wget -O tiktoken_encodings/cl100k_base.tiktoken "https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken"

WORKDIR /app/vllm

# Expose port

EXPOSE 8888
ENTRYPOINT ["vllm", "serve"]
