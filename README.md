### API tests
Вызов скрипта без параметров показывает справку.

Для liveness скрипт представляет один исполняемый файл для всех типов лайвнесс:
- выбор типа БП осуществляется при запуске скрипта;
- есть возможность выбрать связку из нескольких типов;
- для active liveness video требуется передать в параметры запуска мнемонику;
- для active liveness video, если была выбрана мнемоника move, требуется передать в параметры запуска типы действий.

<br>**Если БП liveness поддерживает одновременно работу по нескольким типам**, например, фото + пассивный по видео, то при запуске автотеста следует указывать именно фото+пассивное видео, чтобы корректно подобрался пул запросов.
  

<br>Пример запуска API-автотеста верификации по фото метода extract:
```bash
./api_test_verification_photo.sh -vv -t extract 127.0.0.1:{SOME_PORT} 10
```

Пример запуска API-автотеста всех методов верификации по фото:
```bash
./api_test_verification_photo.sh -vv 127.0.0.1:{SOME_PORT} 10
```

Запуск API-автотеста passive liveness photo (по умолчанию тип passive photo):
```bash
./api_test_liveness.sh -vv 127.0.0.1:{SOME_PORT} 10
```

Запуск API-автотеста passive liveness video:
```bash
./api_test_liveness.sh -t p_video -vv 127.0.0.1:{SOME_PORT} 10
```

Запуск API-автотеста photo + passive liveness video:
```bash
./api_test_liveness.sh -t photo+p_video -vv 127.0.0.1:{SOME_PORT} 10
```

Запуск API-автотеста active liveness video мнемоники move-instructions:
```bash
./api_test_liveness.sh -t a_video -m move -a 1,2,3,4 -vv 127.0.0.1:{SOME_PORT} 10
```
<br>

### Load tests
Скрипты для нагрузочного тестирования могут выполнять тест в двух режимах:
* "один сэмпл" – не требуется указывать опцию -s;
* "много сэмплов" – требуется указать опцию -s.

Вызов скрипта без параметров показывает справку.

Опция **-d**:
* запускает процесс удаления ранее извлеченных векторов в процессе тестирования;
* опция актуальна, если перед тестированием новой версии БП или другого БП требуется очистить предыдущие данные.

Опция **-b** запускает тест в screen для 8 часового теста на стабильность.
Вывод jmeter можно посмотреть так: tail -f tmp/jmeter.log

Опция **-s**:
* указывает на абсолютный путь к директории с сэмплами для тестирования;
* опция актуальна для тестирования нагрузки в режиме "много сэмплов";
* для БП типа video liveness опция является обязательной.

Нагрузочная база для video liveness должна содержать файлы с метаданными .json и соответствующие им файлы видеосэмплов.
Например:
- 001_SMILE.json
- 001_SMILE_SAMPLE_MOV
- 002_TURN_DOWN.json
- 002_TURN_DOWN_SAMPLE_MOV
- ...

<br>Опция **-r** задает RAMP-UP период.

Опция **-p** задает префикс.

Опция **-t** указывает тип биопроцессора (sound/photo/video). Без опции, по умолчанию, тестируется photo.

<br>Скрипт `stop_load.sh` останавливает тест, который был запущен с опцией **-b**.


<br>Пример запуска теста в режиме "один сэмпл":
```bash
./start_load_verification.sh tevian_gpu extract 3 127.0.0.1 {SOME_PORT}
```

Пример запуска теста в режиме "много сэмплов":
```bash
./start_load_verification.sh -s /opt/photo/ tevian_gpu extract 3 127.0.0.1 {SOME_PORT}
```
