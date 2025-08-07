# Dockerfile для разработки с Java, Node.js, Cordova и Gradle
FROM ubuntu:jammy-20250714

# Установка переменных окружения
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV GRADLE_HOME=/opt/gradle
ENV PATH=$PATH:$GRADLE_HOME/bin
ENV NODE_VERSION=22.13.0
ENV NPM_VERSION=10.9.2
ENV CORDOVA_VERSION=12.0.0
ENV GRADLE_VERSION=8.14.3

# Обновление системы и установка базовых пакетов
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    build-essential \
    python3 \
    python3-pip \
    software-properties-common \
    ca-certificates \
    gnupg \
    build-essential \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Установка Java OpenJDK 17
RUN apt-get update && apt-get install -y openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*


# Проверка версии Java (должна быть 17.0.15 или близкая)
RUN java -version

# Установка Node.js v22.13.0
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# Обновление npm до версии 10.9.2
RUN npm install -g npm@${NPM_VERSION}

# Проверка версий Node.js и npm
RUN node --version && npm --version

# Установка Gradle 8.14.3
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp \
    && unzip -d /opt /tmp/gradle-${GRADLE_VERSION}-bin.zip \
    && ln -s /opt/gradle-${GRADLE_VERSION} /opt/gradle \
    && rm /tmp/gradle-${GRADLE_VERSION}-bin.zip

# Проверка версии Gradle
RUN gradle --version

# Установка Cordova 12.0.0
RUN npm install -g cordova@${CORDOVA_VERSION}

# Проверка версии Cordova
RUN cordova --version

# Установка Android SDK (необходимо для Cordova)
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin

RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -P /tmp \
    && unzip /tmp/commandlinetools-linux-9477386_latest.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/commandlinetools-linux-9477386_latest.zip

# Принятие лицензий Android SDK
RUN yes | sdkmanager --licenses

# Установка необходимых Android SDK компонентов
RUN sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
RUN sdkmanager "platform-tools" "platforms;android-33" "build-tools;34.0.0"
RUN sdkmanager "platform-tools" "platforms;android-33" "build-tools;35.0.0"

# Создание рабочей директории
WORKDIR /workspace

# Создание пользователя для разработки
RUN useradd -m -s /bin/bash developer \
    && chown -R developer:developer /workspace

RUN apt-get install -y imagemagick

# Переключение на пользователя developer
USER developer

# Проверка всех установленных версий
RUN echo "=== Проверка версий ===" \
    && java -version \
    && node --version \
    && npm --version \
    && gradle --version \
    && cordova --version


# Команда по умолчанию при запуске контейнера
CMD ["bash"]
