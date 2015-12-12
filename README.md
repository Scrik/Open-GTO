# Open-GTO

[![GitHub version](https://badge.fury.io/gh/Open-GTO%2FOpen-GTO.svg)](http://badge.fury.io/gh/Open-GTO%2FOpen-GTO)
[![Build Status](https://travis-ci.org/Open-GTO/Open-GTO.svg?branch=master)](https://travis-ci.org/Open-GTO/Open-GTO)
[![Join the chat at https://gitter.im/Open-GTO/Open-GTO](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Open-GTO/Open-GTO?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Open-GTO – свободный, некоммерческий проект, направленный на создание по-настоящему весёлого игрового режима в экосистеме SA-MP. Проект является продолжением разработки популярного в своё время игрового режима GTO (Grand Theft Online), версии v0.6.0.

# Сборка и запуск

Загрузка всех исходных кодов:
```
git clone --recursive https://github.com/Open-GTO/Open-GTO.git
```
(или вы можете использовать [GitHub Desktop](https://desktop.github.com/))

Для сборки необходимо запустить **!compile.bat** (если вы используете Windows) или **!compile.sh** (если вы используете GNU/Linux).

Для запуска сервера необходимо скачать последнюю версию сервера с сайта [sa-mp.com](http://sa-mp.com/download.php) и скопировать файл сервера **samp-server.exe** (для Windows) или **samp03svr** (для GNU/Linux) и файл конфигурации **server.cfg** в каталог **Open-GTO/**. Также, необходимо скачать плагины [Streamer](https://github.com/samp-incognito/samp-streamer-plugin/releases) и [sscanf2](http://forum.sa-mp.com/showthread.php?t=570927) и поместить **.dll** (для Windows) и **.so** (для GNU/Linux) файлы в каталог **plugins/**. Не забудьте прописать плагины и название режима в файл конфигурации сервера **server.cfg** ([инструкция по этому файлу](http://wiki.sa-mp.com/wiki/Server.cfg)).
