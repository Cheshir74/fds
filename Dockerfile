#To make an image from this:  docker build -t [image name] .
#On host, ufw allow [some other port than 22]
#Run container:  docker run --rm [image_name] -p [other port from above]:22
FROM ubuntu:18.04
LABEL maintainer="total@techbuben.ru"
ENV RUBY_V 2.6.5
ENV USER depus
ENV PASS='vb9~jxJ@PQ'
ENV DEBIAN_FRONTEND=noninteractive

#install openssh server
RUN apt update && apt install -y openssh-server
RUN mkdir /var/run/sshd
 
#add a user
RUN useradd -ms /bin/bash 'depus'

#give her sudo privileges
RUN adduser $USER sudo
RUN echo $USER:$PASS | chpasswd

# Expose the SSH port
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

#install git

RUN apt install -y git

#install ruby and other packages

RUN apt install -y curl
RUN apt install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev

USER depus
WORKDIR /home/depus
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc 
RUN /bin/bash -s 'source $HOME/.bashrc && echo $HOME'

RUN ["/bin/bash", "-c", "type $HOME/.rbenv/bin/rbenv"]

RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN /bin/bash -c '$HOME/.rbenv/bin/rbenv install $RUBY_V'
RUN /bin/bash -c '$HOME/.rbenv/bin/rbenv global $RUBY_V'
RUN echo "gem: --no-document" > ~/.gemrc

RUN /bin/bash -c '$HOME/.rbenv/versions/$RUBY_V/bin/gem install bundler'
RUN /bin/bash -c '$HOME/.rbenv/versions/$RUBY_V/bin/gem env home'
RUN /bin/bash -c '$HOME/.rbenv/versions/$RUBY_V/bin/gem install rails'
RUN /bin/bash -c '$HOME/.rbenv/bin/rbenv rehash'
USER root

RUN apt install -y nginx


