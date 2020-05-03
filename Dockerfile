FROM rosyuku/ubuntu-rdp:0.1.1
LABEL maintainer="KW_Rosyuku (https://twitter.com/KW_Rosyuku)"
LABEL version="0.2.0"

#user setting
ARG root_password="super"
ARG user_name="my-python"
ARG user_password="my-Password"
RUN echo root:$root_password | chpasswd && \
    usermod -l $user_name "my-ubuntu" && \
    echo $user_name:$user_password | chpasswd

#anaconda setting
ARG conda_url="https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh"
RUN wget --quiet $conda_url -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    echo "export PATH=/opt/conda/bin:$PATH" >> ~/.bashrc

#jupyter setting
ADD ./config/python/.jupyter /home/$user_name/.jupyter/
RUN sed -i 's/c.NotebookApp.notebook_dir = define c.NotebookApp.notebook_dir = /home/${user_name}' /home/$user_name/.jupyter/jupyter_notebook_config.py
EXPOSE 8888

#matplotlib setting
ADD ./config/python/.matplotlib /home/$user_name/.config/matplotlib/

#spyder setting
ADD ./config/python/.spyder-py3/langconfig /home/$user_name/.config/spyder-py3/langconfig

#web applicaion server setting
EXPOSE 8080

#Startup setting
ADD ./config/supervisord/* /etc/supervisor/conf.d/
RUN sed -i 's/user=defined user=${user_name}' /etc/supervisor/conf.d/python.conf

CMD ["bash", "-c", "/usr/bin/supervisord -c /etc/supervisor/supervisord.conf"]