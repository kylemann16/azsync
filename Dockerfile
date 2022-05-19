FROM continuumio/miniconda3:latest

ENV AZURE_CONTAINER_NAME="usgs-lidar"
ENV AZURE_PREFIX="Projects"

ENV AWS_S3_BUCKET_NAME="usgs-lidar"
ENV AWS_PREFIX="Projects/"

RUN apt-get update -y

SHELL ["/bin/bash", "-c"]

RUN cd /bin && \
	wget -O azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux && \
	tar -xf azcopy_v10.tar.gz --strip-components=1 && \
	rm azcopy_v10.tar.gz
RUN conda install python=3.9 --yes
RUN pip3 install adlfs boto3

RUN mkdir -p /src/

COPY diff.py /src/diff.py
COPY copy.sh /src/copy.sh
RUN chmod +x /src/copy.sh

WORKDIR /src
ENTRYPOINT [ "./copy.sh" ]