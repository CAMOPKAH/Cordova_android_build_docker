#!/bin/bash

HTML_FILE="/app/projects/index.html"
APP_NAME="iKomar"
ICON_FILE="icon.png"

# Проверяем существование HTML файла
if [ ! -f "$HTML_FILE" ]; then
    echo "Ошибка: HTML файл не найден: $HTML_FILE"
    exit 1
fi

# Создаем имя пакета на основе имени приложения
PACKAGE_NAME="com.bimaev.$(echo $APP_NAME | tr '[:upper:]' '[:lower:]' | tr -d ' ')"

echo "Создание Cordova проекта..."
cordova create "$APP_NAME" "$PACKAGE_NAME" "$APP_NAME"
mkdir "$APP_NAME"
cd "$APP_NAME"
mkdir www

echo "Копирование HTML файла...$HTML_FILE"
cp "$HTML_FILE" www/index.html

echo "Добавление платформы Android..."
cordova platform add android
cd ..

PROJECT_NAME=$APP_NAME

ICON_FILE="/app/projects/icon.png"
    echo "Обработка иконки..."  
    # Создаем директории для иконок
	mkdir -p "$PROJECT_NAME"/platforms/android/app/src/main/res/mipmap-ldpi-v26
    mkdir -p "$PROJECT_NAME"/platforms/android/app/src/main/res/mipmap-mdpi-v26
    mkdir -p "$PROJECT_NAME"/platforms/android/app/src/main/res/mipmap-hdpi-v26
    mkdir -p "$PROJECT_NAME"/platforms/android/app/src/main/res/mipmap-xhdpi-v26
    mkdir -p "$PROJECT_NAME"/platforms/android/app/src/main/res/mipmap-xxhdpi-v26
    mkdir -p "$PROJECT_NAME"/platforms/android/app/src/main/res/mipmap-xxxhdpi-v26

    # Конвертируем и изменяем размер иконки для разных разрешений
    convert "$ICON_FILE" -resize 36x36 $PROJECT_NAME/platforms/android/app/src/main/res/mipmap-ldpi-v26/ic_launcher_foreground.png
    convert "$ICON_FILE" -resize 48x48 "$PROJECT_NAME"/platforms/android/app/src/main/res/mipmap-mdpi-v26/ic_launcher_foreground.png
    convert "$ICON_FILE" -resize 72x72 "$PROJECT_NAME"/platforms/android/app/src/main/res/mipmap-hdpi-v26/ic_launcher_foreground.png
    convert "$ICON_FILE" -resize 96x96 "$PROJECT_NAME"/platforms/android/app/src/main/res/mipmap-xhdpi-v26/ic_launcher_foreground.png
    convert "$ICON_FILE" -resize 144x144 "$PROJECT_NAME"/platforms/android/app/src/main/res/mipmap-xxhdpi-v26/ic_launcher_foreground.png
    convert "$ICON_FILE" -resize 192x192 "$PROJECT_NAME"/platforms/android/app/src/main/res/mipmap-xxxhdpi-v26/ic_launcher_foreground.png 
	
	
	
    # Конвертируем и изменяем размер иконки для разных разрешений в монохром
    convert "$ICON_FILE"  -monochrome -resize 36x36 $PROJECT_NAME/platforms/android/app/src/main/res/mipmap-ldpi-v26/ic_launcher_monochrome.png
	convert "$ICON_FILE"  -monochrome -resize 48x48 $PROJECT_NAME/platforms/android/app/src/main/res/mipmap-mdpi-v26/ic_launcher_monochrome.png
    convert "$ICON_FILE"  -monochrome -resize 72x72 $PROJECT_NAME/platforms/android/app/src/main/res/mipmap-hdpi-v26/ic_launcher_monochrome.png
    convert "$ICON_FILE"  -monochrome -resize 96x96 $PROJECT_NAME/platforms/android/app/src/main/res/mipmap-xhdpi-v26/ic_launcher_monochrome.png
    convert "$ICON_FILE"  -monochrome -resize 144x144 $PROJECT_NAME/platforms/android/app/src/main/res/mipmap-xxhdpi-v26/ic_launcher_monochrome.png
    convert "$ICON_FILE"  -monochrome -resize 192x192 $PROJECT_NAME/platforms/android/app/src/main/res/mipmap-xxxhdpi-v26/ic_launcher_monochrome.png
echo "Иконка обработана и добавлена в проект."


echo "Сборка приложения Release."
cd $APP_NAME
cordova build android --release
echo "Сборка APKS."

if [ ! -f "/root/.android/debug.keystore" ]; then
    echo "Создание отладочного keystore..."
    mkdir -p /root/.android
    keytool -genkey -v -keystore /root/.android/debug.keystore \
        -storepass android -alias androiddebugkey -keypass android \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -dname "CN=Android Debug,OU=Android,O=Android,L=Mountain View,ST=CA,C=US"
fi

# Конвертируем AAB в APK
AAB_FILE="$PROJECT_NAME/platforms/android/app/build/outputs/bundle/release/app-release.aab"
APKS_FILE="$PROJECT_NAME/platforms/android/app/build/outputs/bundle/release/app-release.apks"
cd ..
rm $APP_NAME/platforms/android/app/build/outputs/bundle/release/universal.apk


# Проверяем существование HTML файла
if [ ! -f "bundletool-all-1.18.1.jar" ]; then
    
wget https://github.com/google/bundletool/releases/download/1.18.1/bundletool-all-1.18.1.jar

fi

java -jar bundletool-all-1.18.1.jar build-apks \
    --bundle="$AAB_FILE" \
    --output="$APKS_FILE" \
    --mode=universal \
    --ks=/root/.android/debug.keystore \
    --ks-pass=pass:android \
    --ks-key-alias=androiddebugkey \
    --key-pass=pass:android

# Извлекаем универсальный APK
unzip -j "$APKS_FILE" universal.apk -d $PROJECT_NAME/platforms/android/app/build/outputs/bundle/release/

# Переименовываем APK
mv $PROJECT_NAME/platforms/android/app/build/outputs/bundle/release/universal.apk "/app/projects/${PROJECT_NAME}-release.apk"

echo "APK успешно создан: /app/projects/${PROJECT_NAME}-release.apk"
echo "Размер файла: $(du -h /app/projects/${PROJECT_NAME}-release.apk | cut -f1)"


