[English below](#english)


# Get-BingDaily.ps1
Скрипт для загрузки ежедневной фотографии с Bing.com

---

Roman Ermakov <r.ermakov@emg.fm>

v1.00 2021-02-09 Первая версия

v1.01 2021-02-26 Улучшен алгоритм работы:
* составляем список уникальных последних изображений с Bing;
* если в папке с сохранёнными изображениями уже есть файлы, составляем список уникальных изображений, ориентируясь на id (*WhisterLifts* в https://www.bing.com/th?id=OHR.WhisterLifts_FR-CA5346533490_1920x1080.jpg)
* сопоставляем списки и скачиваем только те изображения, которых ещё нет.
Одни и те же изображения могут встречаться в разных локалях в разные даты. В то же время в разных локалях (особенно в азиатских) встречаются уникальные изображения, которые не были представлены для других регионов.

---

Скрипт скачивает Bing Daily Images для различных регионов.
Одинаковые изображения из разных регионов не дублируются, сохраняется только одно.

Изображения сохраняются в максимальном разрешении 1920x1200, если изображение не представлено в таком разрешении, сохраняется предыдущее 1920x1080.

Изображения будут сохранены в папке Bing Daily Images в пользовательской папке Pictures (на Windows, macOS и Linux).

---

# Get-SpotlightDaily.ps1
Скрипт для скачивания фотографий с сервисов Windows Spotlight.

---

Скрипт 29 раз проходит по набору изображений Windows Spotlight для различных регионов.
Изображения сохраняются в разрешении 1920x1080 для десктопа и 1080x1920 (вертикальные) для мобильных устройств.

Поскольку для различных регионов встречаются одинаковыые изображения, после скачивания проводится дедупликация.

Изображения будут сохранены в папке Microsoft Spotlight Daily Images в пользовательской папке Pictures (на Windows, macOS и Linux).

---

### english

# Get-BingDaily.ps1
This script downloads Bing.com Daily Photo.

---

Roman Ermakov <r.ermakov@emg.fm>

v1.00 2021-02-09 First release

v1.01 2021-02-26 Algorithm was improved:
* get the list of last unique Bing images;
* if there's a files in download folder - create the list of local unique images lookup by id (*WhisterLifts* in https://www.bing.com/th?id=OHR.WhisterLifts_FR-CA5346533490_1920x1080.jpg)
* compare lists and download only new images.
Same images can exist in different locales in different dates. However there's unique images in some locales (mostly South Asian) which were never exist in other countries.

---

This script downloads Bing Daily Images of different locales.
Only one of the same images from different locales is saving.

Script saves images in maximum resolution 1920x1200, if there's no image in this resolution, script chooses 1920x1080.

Script saves images in "Bing Daily Images" in user's folder Pictures (on Windows, macOS or Linux).

---

# Get-SpotlightDaily.ps1
This script downloads Windows Spotlight daily photos.

---

The script 29 times downloads the images lists from Windows Spotlight of different locales.
Script saves images as 1920x1080 for desktop and 1080x1920 (vertical) for mobile devices.

Script deduplicates saved folder content because of same images can exist in different locales.

Script saves images in "Microsoft Spotlight Daily Images" in user's folder Pictures (on Windows, macOS or Linux).

---

# Buy Me A Coffee! :coffee:

As some of you may already know, I just opened my buymeacoffee site, where any of you can contribute buying the developer a coffee.

At first I was reluctant to open a funding page, but since some people that have contacted me for any open source related issues asking me how could they contribute or if I had any page where they could donate or help me in any way for my hard work, after some time thinking about it I decided that the best site that fitted with me and the content I want to provide you all, was buymeacoffee.

buymeacoffee is a website that contacts developers, designers, artists, etc. with their communities so that people can contribute and help them out so that the content they offer is better since the rewarding system encourages creators to continue doing what they like and helping others.

If you can contribute or you want to, feel free to do it at [__Buy me a coffee! :coffee:__](https://www.buymeacoffee.com/twelve), I will be really thankfull for anything even if it is a coffee or just a kind comment towards my work, because that helps me a lot. Whenever you contribute with a donation, I will read your message and it will be shown in my main site.

### Be careful and donate just if it is within your possibilities, because there is no refund system. And remember that you don't need to donate, it is just a free choice for you. Thank you!
