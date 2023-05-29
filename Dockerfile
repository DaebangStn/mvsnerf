FROM nvidia/cuda:11.3.0-devel-ubuntu20.04

ENV MVSNERF_ROOT=/root/mvsnerf
ENV USER_ROOT=/root

# GPU architecture CUDA compute capability
ENV gpu_arch=7.5

# update apt and install python3.8 and pip3
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq python3.8 python3-pip

# install jupyter notebook
RUN pip3 install jupyter

# install python packages
RUN pip install torch==1.10.1+cu113 torchvision==0.11.2+cu113 torchaudio==0.10.1+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html
RUN pip install pytorch-lightning==1.3.5 imageio pillow scikit-image opencv-python configargparse lpips kornia warmup_scheduler matplotlib test-tube imageio-ffmpeg

# there is an error on torchmetric, so we need to change the version manually
RUN pip uninstall -y torchmetrics
RUN pip install torchmetrics==0.5

# to install inplace-abn, force the compilation of the native CUDA is needed
ENV TORCH_CUDA_ARCH_LIST=$gpu_arch
ENV IABN_FORCE_CUDA=1

# inplace-abn is not needed, but it is not installed by the original MVSNeRF
RUN pip install inplace-abn

# copy source code
COPY . $MVSNERF_ROOT

# copy jupyter configuration
COPY .jupyter/ $USER_ROOT/.jupyter

# set the working directory
WORKDIR $MVSNERF_ROOT

# make port 8888 available to the world outside this container
EXPOSE 8888

# run jupyter notebook
CMD ["jupyter", "notebook"]