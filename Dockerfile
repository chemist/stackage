FROM ubuntu:12.04

ENV HOME /home/stackage
ENV LANG en_US.UTF-8

RUN mkdir /home/stackage -p
RUN locale-gen en_US.UTF-8

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common python-software-properties
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:hvr/ghc -y

ADD debian-bootstrap.sh /tmp/debian-bootstrap.sh
RUN DEBIAN_FRONTEND=noninteractive bash /tmp/debian-bootstrap.sh
RUN rm /tmp/debian-bootstrap.sh

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y cabal-install-1.20 ghc-7.8.4 alex-3.1.3 happy-1.19.4 sudo

ENV PATH /home/stackage/.cabal/bin:/usr/local/sbin:/usr/local/bin:/opt/ghc/7.8.4/bin:/opt/cabal/1.20/bin:/opt/alex/3.1.3/bin:/opt/happy/1.19.4/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN cabal update
RUN cabal install hscolour cabal-install --constraint "Cabal < 1.22" && cp $HOME/.cabal/bin/* /usr/local/bin && rm -rf $HOME/.cabal $HOME/.ghc /tmp/stackage
RUN wget https://s3.amazonaws.com/stackage-travis/stackage-curator/stackage-curator.bz2 && bunzip2 stackage-curator.bz2 && chmod +x stackage-curator && mv stackage-curator /usr/local/bin

RUN cd /home/stackage && cabal update && stackage-curator check
