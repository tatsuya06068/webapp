ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION

ARG NODE_MAJOR
ARG YARN_VERSION

# ログインシェルとしてbashを使用する
SHELL ["/bin/bash", "-c"]

# nodejs取得
RUN curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash -

# yarn取得
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# リポジトリを更新し依存モジュールをインストール
RUN apt-get update -qq &&\
  apt-get install -y\
  build-essential\
  nodejs\
  yarn=$YARN_VERSION-1

# ルート直下にwebappという名前で作業ディレクトリを作成（コンテナ内のアプリケーションディレクトリ）
RUN mkdir /webapp
WORKDIR /webapp

# ホストのGemfileとGemfile.lockをコンテナにコピー
ADD Gemfile /webapp/Gemfile
ADD Gemfile.lock /webapp/Gemfile.lock

# bundle installの実行
RUN bundle install

RUN gem install rails

# ホストのアプリケーションディレクトリ内をすべてコンテナにコピー
ADD . /webapp

# puma.sockを配置するディレクトリを作成
RUN mkdir -p tmp/sockets

# コンテナ開始時に必ず実行されるシェルスクリプトをコンテナにコピー
ADD entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
