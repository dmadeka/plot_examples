# Read: https://hub.docker.com/r/jupyter/scipy-notebook/
# Tags: https://hub.docker.com/r/jupyter/scipy-notebook/tags/
# https://github.com/jupyter/docker-stacks/tree/master/scipy-notebook

FROM jupyter/scipy-notebook:033056e6d164

# Set variables
ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

# Set root
USER root

# Get packages
ENV BUILD_PACKAGES="curl wget unzip subversion git"

# Install. # Install all packages in 1 RUN
RUN echo "Installing these packages" $BUILD_PACKAGES
RUN apt-get update && \
    apt-get install --no-install-recommends -y $BUILD_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

# Set user back
USER ${NB_USER}

#ENV ANACONDA_PACKAGES=""
#conda install -c anaconda $ANACONDA_PACKAGES && \

ENV CONDA_PACKAGES="bqplot"
#conda install -c conda-forge $CONDA_PACKAGES && \

ENV PIP_PACKAGES="nmrglue plotly"
# Convert .py files to .ipynb
ENV PIP_PACKAGES="$PIP_PACKAGES https://github.com/sklam/py2nb/archive/master.zip"
#pip install $PIP_PACKAGES

# RISE: Quickly turn your Jupyter Notebooks into a live presentation.
# datashader: creating meaningful representations of large amounts of data.
# HoloViews: Make data analysis and visualization seamless and simple

# Install packages
RUN echo "" && \
    conda install -c conda-forge $CONDA_PACKAGES && \
    pip install $PIP_PACKAGES && \
    conda install -c conda-forge pythreejs && \
    pip install mne && \
    pip install mxnet && \
    pip install tensorflow && \
    pip install keras

# jupyter notebook password remove
RUN echo "" && \
    mkdir -p $HOME/.jupyter && \
    cd $HOME/.jupyter && \
    echo "c.NotebookApp.token = u''" > jupyter_notebook_config.py

# Copy examples from:
# https://github.com/bloomberg/bqplot
RUN echo "" && \
    git clone http://github.com/dmadeka/PyDataNYC2017 PyDataExamples && \
    svn export https://github.com/bloomberg/bqplot/trunk/examples bqplot_examples

# Possible sign Notebooks
#RUN find . -type f -name '*.ipynb'|while read fname; do echo $fname; jupyter trust "$fname"; done

# Possible copy other files to home. ${HOME}
#COPY Dockerfile ${HOME}
#COPY build_Dockerfile.sh ${HOME}

### Set root, and make folder writable
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}
