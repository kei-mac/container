# ベースイメージとしてUbuntu 22.04を使用
FROM ubuntu:22.04

# 引数指定（docker-composeから受け取る）
ARG USER_NAME
ARG USER_GROUP_NAME
ARG USER_UID
ARG USER_GID
ARG TOMCAT_VERSION
ARG JAVA_VERSION
ARG GRADLE_VERSION

# 環境変数の設定
ENV USER_NAME=${USER_NAME}
ENV USER_GROUP_NAME=${USER_GROUP_NAME}
ENV USER_UID=${USER_UID}
ENV USER_GID=${USER_GID}
ENV TOMCAT_VERSION=${TOMCAT_VERSION}
ENV JAVA_VERSION=${JAVA_VERSION}
ENV GRADLE_VERSION=${GRADLE_VERSION}

# 標準パッケージの取得
ARG PKG="sudo git vim curl zip unzip locales wget"

# bashとして実行する
SHELL ["/bin/bash", "-c"]

# ユーザー作成（code-serverのユーザーを作成する）
RUN apt-get update \
    && apt-get install -y ${PKG} \
    && groupadd --gid ${USER_GID} ${USER_GROUP_NAME} \
    && useradd --uid ${USER_UID} --shell /bin/bash --gid ${USER_GID} -m ${USER_NAME} \
    && echo "%${USER_GROUP_NAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER_GROUP_NAME} \
    && chmod 0440 /etc/sudoers.d/${USER_GROUP_NAME}

# Javaのインストール
WORKDIR /usr/lib/jvm
RUN wget https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.tar.gz \
    && tar -xzf amazon-corretto-17-x64-linux-jdk.tar.gz \
    && rm amazon-corretto-17-x64-linux-jdk.tar.gz

# JAVA_HOMEを設定するスクリプトを作成
RUN echo 'export JAVA_HOME=/usr/lib/jvm/amazon-corretto-17.0.12.7.1-linux-x64' >> /etc/profile.d/jdk.sh \
    && echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile.d/jdk.sh \
    && echo 'source ~/.bashrc' >> /etc/profile.d/jdk.sh \
    && chmod +x /etc/profile.d/jdk.sh

# Node.jsのインストール
WORKDIR /usr/lib/nodejs
RUN curl -fsSL https://nodejs.org/dist/v18.17.0/node-v18.17.0-linux-x64.tar.gz -o node-v18.17.0-linux-x64.tar.gz \
    && tar -xzf node-v18.17.0-linux-x64.tar.gz \
    && rm node-v18.17.0-linux-x64.tar.gz

# Node.js環境変数の設定
RUN echo "export NODE_HOME=/usr/lib/nodejs/node-v18.17.0-linux-x64" > /etc/profile.d/nodejs.sh && \
    echo "export PATH=\$NODE_HOME/bin:\$PATH" >> /etc/profile.d/nodejs.sh && \
    echo 'source ~/.bashrc' >> /etc/profile.d/jdk.sh && \
    chmod +x /etc/profile.d/nodejs.sh

# Tomcatのインストール
WORKDIR /usr/local/tomcat
RUN curl -O https://downloads.apache.org/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && rm apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && chown -R ${USER_NAME}:${USER_GROUP_NAME} apache-tomcat-${TOMCAT_VERSION}

# code-server設定と拡張機能のインストール
USER ${USER_NAME}

# code-serverのインストール
RUN curl -fsSL https://code-server.dev/install.sh | bash

# 拡張機能のインストール
# 拡張機能ファイルをコピー
COPY extensions/*.vsix /tmp/extensions/

# 拡張機能のインストール
RUN for ext in /tmp/extensions/*.vsix; do \
      code-server --install-extension $ext; \
    done

COPY argv.json /home/${USER_NAME}/.local/share/code-server/User/argv.json
COPY settings.json /home/${USER_NAME}/.local/share/code-server/User/settings.json
RUN sudo chmod -R u+x /home/${USER_NAME}/.local/share/code-server/User\
    && sudo chown -R ${USER_NAME}:${USER_GROUP_NAME} /home/${USER_NAME}/.local/share/code-server/User

# デフォルトの作業ディレクトリを /home/${USER_NAME}/project に設定
WORKDIR /home/${USER_NAME}/project

# Tomcatとcode-serverのポートを公開
EXPOSE 8090

# code-serverのデフォルトワークディレクトリを設定して起動
CMD ["code-server", "--bind-addr", "0.0.0.0:8090", "--user-data-dir", "/home/coder/.local/share/code-server", "/home/coder/project"]
