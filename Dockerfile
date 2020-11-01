FROM rosyuku/ubuntu-rdp:0.1.1
LABEL maintainer="KW_Rosyuku (https://twitter.com/KW_Rosyuku)"
LABEL version="0.2.0"

#user setting
ARG root_password="super"
ARG user_name="my-python"
ARG user_password="my-Password"
RUN echo root:$root_password | chpasswd && \
    usermod -l $user_name "my-ubuntu" && \
    mv /home/my-ubuntu /home/$user_name && \
    echo $user_name:$user_password | chpasswd && \
    sed -i "s#my-ubuntu:#${user_name}:#" /etc/passwd

#anaconda setting
ARG conda_url="https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh"
RUN wget --quiet $conda_url -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    echo "export PATH=/opt/conda/bin:$PATH" >> /home/$user_name/.bashrc

#jupyter setting
ADD ./config/python/.jupyter /home/$user_name/.jupyter/
RUN sed -i "s#c.NotebookApp.notebook_dir = define#c.NotebookApp.notebook_dir = '/home/${user_name}'#" /home/$user_name/.jupyter/jupyter_notebook_config.py
EXPOSE 8888

#matplotlib setting
ADD ./config/python/.matplotlib /home/$user_name/.config/matplotlib/

#spyder setting
ADD ./config/python/.spyder-py3/langconfig /home/$user_name/.config/spyder-py3/langconfig

#web applicaion server setting
EXPOSE 8080

#pyode setting
ENV PATH $PATH:/opt/conda/bin
ADD ./config/python/requirements-pyode.txt /home/$user_name/.config/requirements-pyode.txt
RUN apt-get update -y && apt-get install -y libglu1-mesa-dev freeglut3-dev mesa-common-dev && \
    /opt/conda/bin/pip install -r /home/$user_name/.config/requirements-pyode.txt

#Startup setting
ADD ./config/supervisord/* /etc/supervisor/conf.d/
RUN sed -i "s#defined#${user_name}#" /etc/supervisor/conf.d/python.conf && \
    chown -R $user_name:my-ubuntu /home/$user_name

CMD ["bash", "-c", "/usr/bin/supervisord -c /etc/supervisor/supervisord.conf"]