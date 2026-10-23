# StevieBuddy

Ассеты для клиентского визуального бадди Стиви в DOORS: иконка предмета и звуки.
Скрипт `buddy.lua` при первом запуске скачивает их в `workspace/StevieBuddy/` экзекутора.

```
stevie_icon.png
sounds/
  stevie_equip.ogg         — экипировка
  stevie_inspect1.ogg      — осмотр 1
  stevie_inspect2.ogg      — осмотр 2
  stevie_face_left.ogg     — левое лицо
  stevie_face_right.ogg    — правое лицо
  stevie_face_default.ogg  — лицо по умолчанию
```

В `buddy.lua` укажи:

```lua
ASSETS_URL = "https://raw.githubusercontent.com/<ник>/StevieBuddy/main/",
```
