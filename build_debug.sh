#!/bin/bash

HTML_FILE="/app/projects/index.html"
ICON_FILE="/app/projects/icon.png"

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


echo "Копирование logo.png файла...$ICON_FILE"
cp "$ICON_FILE" www/img/logo.png

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


echo "Сборка приложения Debug."
cd $PROJECT_NAME
cordova build android --debug
cd ..

echo $APP_NAME/platforms/android/app/build/outputs/apk/debug/app-debug.apk
# Переименовываем APK
mv $APP_NAME/platforms/android/app/build/outputs/apk/debug/app-debug.apk /app/projects/$APP_NAME-debug.apk

echo "APK успешно создан: /app/projects/$APP_NAME-debug.apk"
echo "Размер файла: $(du -h /app/projects/$APP_NAME-debug.apk | cut -f1)"

