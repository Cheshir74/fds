#To make an image from this:  docker build -t [image name] -f [Dockerfile name] .
#On host, ufw allow [some other port than 22]
#Run container:  docker run -d -it -p [other port from above]:22 -p [other port from above]:80 [image_name]
FROM ubuntu:18.04
LABEL maintainer="your_email"
ENV RUBY_V 2.6.5
ENV USER your_username
ENV PASS='your_password'
ENV DEBIAN_FRONTEND=noninteractive
ENV APP=app_deploy

#install openssh server
RUN apt update && apt install -y openssh-server
RUN mkdir /var/run/sshd
 
#add a user
RUN useradd -ms /bin/bash 'depus'

#give her sudo privileges
RUN adduser $USER sudo
RUN echo $USER:$PASS | chpasswd




#install git

RUN apt install -y git

#install ruby and other packages

RUN apt install -y curl sudo
RUN apt install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev nano vim libsqlite3-dev
RUN ["/bin/bash", "-c", "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -"]
RUN ["/bin/bash", "-c", "echo 'deb https://dl.yarnpkg.com/debian/ stable main' | sudo tee /etc/apt/sources.list.d/yarn.list"]
RUN ["/bin/bash", "-c", "curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh"]
RUN ["/bin/bash", "-c", "bash nodesource_setup.sh"]
RUN apt update
RUN apt install -y yarn nodejs
USER depus

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc 
RUN /bin/bash -s 'source $HOME/.bashrc && echo $HOME'

RUN ["/bin/bash", "-c", "type $HOME/.rbenv/bin/rbenv"]

RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN /bin/bash -c '$HOME/.rbenv/bin/rbenv install $RUBY_V'
RUN /bin/bash -c '$HOME/.rbenv/bin/rbenv global $RUBY_V'
RUN echo "gem: --no-document" > ~/.gemrcr

RUN /bin/bash -c '$HOME/.rbenv/versions/$RUBY_V/bin/gem install bundler'
RUN /bin/bash -c '$HOME/.rbenv/versions/$RUBY_V/bin/gem env home'
RUN /bin/bash -c '$HOME/.rbenv/versions/$RUBY_V/bin/gem install rails'
RUN /bin/bash -c '$HOME/.rbenv/bin/rbenv rehash'


USER root

RUN apt install -y nginx supervisor
RUN mkdir -p /var/log/supervisor && mkdir -p /etc/supervisor/conf.d
ADD supervisor.conf /etc/supervisor/supervisor.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

RUN git clone https://github.com/Cheshir74/fds.git ~/fds
RUN /bin/bash -c 'cp $HOME/fds/nginx-default /etc/nginx/sites-available/default'
RUN rm -rf $HOME/fds

# Expose the SSH port
EXPOSE 22 80

CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf"]





