FROM ubuntu:18.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq install \
      locales \
      python3 \
      python3-pip \
      vim-nox \
      less \
      build-essential \
      libffi-dev \
      nodejs \
      npm && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install pipenv

# Required by "Click"
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"

COPY . /dpaste
WORKDIR /dpaste

RUN npm config set proxy "$http_proxy" && \
    npm config set https-proxy "$http_proxy" && \
    npm install && \
    npm run build

RUN pipenv install --dev
RUN mkdir /data
VOLUME /data

EXPOSE 80
CMD pipenv run ./manage.py migrate && pipenv run ./manage.py runserver 0.0.0.0:80
