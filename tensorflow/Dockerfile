FROM tensorflow/tensorflow:latest

RUN apt update && \
    apt install -y graphviz && \
    apt clean && rm -rf /var/lib/apt/lists/*

RUN pip install sklearn pydot graphviz

CMD ["/run_jupyter.sh"]