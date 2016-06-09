FROM tensorflow/tensorflow:latest

RUN apt-get update && \
    apt-get install -y graphviz && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install sklearn pydot graphviz

CMD ["/run_jupyter.sh"]