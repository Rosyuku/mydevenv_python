FROM uphy/ubuntu-desktop-jp:18.04

#preference
RUN apt update && \
    echo 'root:mypydevenv' | chpasswd

#editor and git
RUN apt install -y gedit git tig

#setting SSH
RUN apt update && apt install -y openssh-server=1:7.6p1-4ubuntu0.3 && mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config && \
    sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/' /etc/ssh/sshd_config
EXPOSE 22
    
#setting rdp
RUN apt update && apt install -y  xrdp=0.9.5-2 &&\
    sed -i 's/lib=libxup.so/lib=libvnc.so/' /etc/xrdp/xrdp.ini &&\
    sed -i 's/username=ask/username=askroot/' /etc/xrdp/xrdp.ini &&\
    sed -i 's/password=ask/password=askmypydevenv/' /etc/xrdp/xrdp.ini &&\
    sed -i 's/ip=127.0.0.1/ip=ask127.0.0.1/' /etc/xrdp/xrdp.ini &&\
    sed -i 's/port=-1/port=ask5900/' /etc/xrdp/xrdp.ini &&\
    sed -i 's/code=20//' /etc/xrdp/xrdp.ini
EXPOSE 3389

#setting anaconda3
#ENV PATH /opt/conda/bin:$PATH
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    echo "export PATH=/opt/conda/bin:$PATH" >> ~/.bashrc

#setting jupyter
ADD .jupyter ./root/.jupyter/
EXPOSE 8888

#setting matplotlib font
RUN apt install -y fonts-takao-gothic
ADD .matplotlib ./root/.config/matplotlib/      

ADD supervisord/* /etc/supervisor/conf.d/