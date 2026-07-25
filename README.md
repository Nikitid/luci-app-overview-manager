# Overview Manager для OpenWrt

[English](README.en.md)

LuCI-приложение для настройки карточек на странице `Status -> Overview`.
Позволяет менять порядок виджетов перетаскиванием, поднимать и опускать их
кнопками и полностью скрывать ненужные карточки.

## Как это работает

Штатный LuCI загружает файлы из
`/www/luci-static/resources/view/status/include` в алфавитном порядке.
Overview Manager добавляет ранний служебный include, сопоставляет карточки с
исходными файлами и применяет сохранённую в UCI раскладку к DOM.

Файлы других пакетов не изменяются, не переименовываются и не удаляются.
После удаления Overview Manager штатное поведение LuCI восстанавливается
автоматически.

## Совместимость

- официальный OpenWrt `24.10.x` с `opkg`;
- официальный OpenWrt `25.12.x` с `apk`;
- стандартная страница `luci-mod-status` Status Overview;
- сторонние виджеты, установленные как LuCI status include.

В OpenWrt 25.12 штатная кнопка Hide хранит состояние отдельно в
`localStorage` конкретного браузера. Она продолжает работать независимо от
общей раскладки Overview Manager.

## Переводы

Интерфейс использует штатный механизм LuCI: `_()` в JavaScript и каталоги
gettext в `po/`. При сборке `po/<язык>/overview-manager.po` компилируется в
`/usr/lib/lua/luci/i18n/overview-manager.<язык>.lmo` и попадает в основной
пакет, а `/etc/uci-defaults/luci-app-overview-manager` регистрирует язык в
`luci.languages`. Язык интерфейса следует настройке LuCI, отдельный пакет
`luci-i18n-*` не требуется.

Пакет переводит только свои строки: для полностью русского LuCI нужен ещё
`luci-i18n-base-ru`. Новый язык добавляется каталогом
`po/<язык>/overview-manager.po`; соответствие каталогов исходникам проверяет
`scripts/test-po2lmo.py`.

## Ограничения

У LuCI status include нет общего описания внутренних полей: каждый виджет
реализует произвольные `load()` и `render()`. Поэтому Overview Manager
настраивает порядок и видимость карточек, но не редактирует их содержимое.

Скрытый виджет не отображается, однако его штатный сбор данных может
продолжать выполняться при опросе страницы.

## Сборка и проверка

```sh
./scripts/ci-check.sh
```

IPK создаётся в `dist/`. APK собирается официальным SDK OpenWrt 25.12:

```sh
OPENWRT_SDK_DIR=/path/to/openwrt-sdk-25.12.x-target \
  ./scripts/build-apk.sh
```

Релизный APK подписывается общим ключом приложений OpenWrt:

```sh
OPENWRT_SDK_DIR=/path/to/openwrt-sdk-25.12.x-target \
OPENWRT_APK_SIGNING_KEY=/secure/path/release-private.pem \
  ./scripts/build-apk-release.sh
```

Приватный ключ не хранится в репозитории. Публичный ключ совместим с уже
установленным ключом IKEv2 Manager. Устройство с этим ключом доверяет пакетам
обоих проектов.

После публикации пакета и обновления общего feed установка OpenWrt 25.12:

```sh
wget -O /tmp/install-overview-manager.sh \
  https://github.com/Nikitid/luci-layout/releases/latest/download/install-openwrt25.sh
sh /tmp/install-overview-manager.sh
```

Устройство без установленного общего ключа получает его через bootstrap с
проверкой SHA-256. Подробности: [общий APK-feed](docs/SHARED_APK_FEED.md).

## Лицензия

[MIT](LICENSE)
