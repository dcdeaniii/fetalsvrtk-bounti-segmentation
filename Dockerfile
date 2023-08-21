# Use the latest Python 3 docker image
FROM nialljb/fw-svrtk as base

ENV HOME=/root
ENV FLYWHEEL="/flywheel/v0"
WORKDIR $FLYWHEEL
RUN mkdir -p $FLYWHEEL/input
ENV PATH=/root/miniconda3/bin/:$PATH

# Installing the current project (most likely to change, above layer can be cached)
COPY ./ $FLYWHEEL/

# Dev dependencies
RUN apt-get update && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN python3.9 -m pip install --upgrade pip && \
    pip install flywheel-sdk && pip install flywheel-gear-toolkit 

# Configure entrypoint
RUN bash -c 'chmod +rx $FLYWHEEL/run.py' && \
    bash -c 'chmod +rx $FLYWHEEL/app/'
ENTRYPOINT ["python3","/flywheel/v0/run.py"] 
# Flywheel reads the config command over this entrypoint