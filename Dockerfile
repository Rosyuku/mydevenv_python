FROM rosyuku/ubuntu-rdp:0.1.1
LABEL maintainer="KW_Rosyuku (https://twitter.com/KW_Rosyuku)"
LABEL version="0.2.1_no-conda"

#user setting
ARG root_password="super"
ARG user_name="my-python"
ARG user_password="my-Password"
RUN echo root:$root_password | chpasswd && \
    usermod -l $user_name "my-ubuntu" && \
    mv /home/my-ubuntu /home/$user_name && \
    echo $user_name:$user_password | chpasswd && \
    sed -i "s#my-ubuntu:#${user_name}:#" /etc/passwd

#python setting
ARG python_version="3.7"
RUN apt update -y && \
    apt install -y python${python_version} python${python_version}-venv \
    libpython${python_version}-dev python3-pip python3-dev && \
    echo "export PATH=/opt/python/bin:$PATH" >> /home/$user_name/.bashrc
ADD ./config/python/requirements.txt /root/requirements.txt
RUN  /opt/python/bin/python${python_version} -m pip install -r /root/requirements.txt

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

#Startup setting
ADD ./config/supervisord/* /etc/supervisor/conf.d/
RUN sed -i "s#defined#${user_name}#" /etc/supervisor/conf.d/python.conf && \
    chown -R $user_name:my-ubuntu /home/$user_name

CMD ["bash", "-c", "/usr/bin/supervisord -c /etc/supervisor/supervisord.conf"]