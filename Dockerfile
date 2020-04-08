FROM gapsystem/gap-docker

MAINTAINER J. D. Mitchell <jdm3@st-andrews.ac.uk>

COPY --chown=1000:1000 . $HOME/digraphs

RUN rm -rf $HOME/inst/gap-${GAP_VERSION}/pkg/digraphs-* && mv $HOME/digraphs $HOME/inst/gap-${GAP_VERSION}/pkg/ && cd $HOME/inst/gap-${GAP_VERSION}/pkg/digraphs && ./autogen.sh && ./configure && make  

RUN sudo pip3 install ipywidgets RISE jupyter_francy

RUN jupyter-nbextension install rise --user --py

RUN jupyter-nbextension enable rise --user --py

RUN sudo jupyter nbextension enable --user --py --sys-prefix jupyter_francy

USER gap

WORKDIR $HOME/inst/gap-${GAP_VERSION}/pkg/digraphs/notebooks
