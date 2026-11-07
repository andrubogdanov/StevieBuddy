# StevieBuddy

Ассеты для клиентского визуального бадди Стиви в DOORS: иконка предмета и звуки.
Скрипт `buddy.lua` при первом запуске скачивает их в `workspace/StevieBuddy/` экзекутора.

```
stevie_tool.rbxm           — предмет Buddy_Stevie: риг, лица и кадры анимаций (AnimSaves)
stevie.rbxm                — модель Стиви (лица в папке Faces)
stevie_icon.png
sounds/
  stevie_equip.ogg         — экипировка
  stevie_inspect1.ogg      — осмотр 1
  stevie_inspect2.ogg      — осмотр 2
  stevie_face_left.ogg     — левое лицо
  stevie_face_right.ogg    — правое лицо
  stevie_face_default.ogg  — лицо по умолчанию
  treat_*.mp3              — звуки для treat_buddy.lua (бадди в плаще, скин LilTreat):
                             pat1-3, coo, yip, squeak1-2, giggle, rustle, grab,
                             struggle, boop, mmf, hmph
textures/
  newyear_wallpaper.png    — новогодние обои для newyear.lua (бесшовная плитка 512x512)
```

`treat_buddy.lua` скачивает свои звуки `sounds/treat_*.mp3` отсюда же
в `workspace/StevieBuddy/sounds/`.

`newyear.lua` скачивает `textures/newyear_wallpaper.png` в `workspace/StevieBuddy/textures/`
и ставит его вместо обоев в комнатах (только у тебя на экране).

В `buddy.lua` укажи:

```lua
ASSETS_URL = "https://raw.githubusercontent.com/<ник>/StevieBuddy/main/",
```
