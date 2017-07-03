FROM nvidia/cuda:8.0-cudnn6-devel
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# install needed packages
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y screen
RUN apt-get install -y tmux
RUN apt-get install -y vim
RUN apt-get install -y wget

# copy folder with setup files into container
RUN mkdir /var/setup
COPY docker_temp /var/setup

# create user
RUN groupadd --gid `cat /var/setup/gid` nips
RUN useradd --uid `cat /var/setup/uid` --gid `cat /var/setup/gid` --create-home --shell /bin/bash nips

# install conda
RUN wget --quiet --output-document /var/setup/install_conda.sh https://repo.continuum.io/archive/Anaconda3-4.4.0-Linux-x86_64.sh
RUN mkdir -p /opt
RUN bash /var/setup/install_conda.sh -b -p /opt/conda
RUN printf "\n\n# this was added by the docker setup\nexport PATH=/opt/conda/bin:\$PATH" >> /home/nips/.bashrc
ENV PATH /opt/conda/bin:$PATH

# install python dependencies
RUN conda install -y nltk pyyaml requests tqdm
RUN conda install -y numpy
RUN conda install -y matplotlib
RUN conda install -y pytorch -c soumith
RUN pip install git+https://github.com/pytorch/text

# cleanup
RUN rm -r /var/setup

# switch to user nips
USER nips

# clone project
WORKDIR /home/trial

