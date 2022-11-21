# Infrastructure 

## Стенды
### TKUR1:
* t01nbpbioproc01 [10.113.128.184] - скрипты
* t01nbpbioproc02 [10.113.128.185] - swarm 1
* t01nbpbioproc03 [10.113.128.186] - swarm 1

### TKUR2:
* t01nbpbioproc04 [10.113.128.187] - скрипты
* t01nbpbioproc05 [10.113.128.188] - swarm 2
* t01nbpbioproc06 [10.113.128.189] - swarm 2

### TKUR3:
* t01nbpbioproc07 [10.113.128.190] - скрипты
* t01nbpbioproc08 [10.113.128.191] - swarm 2
* t01nbpbioproc09 [10.113.128.192] - swarm 2



# API-tests
Вызов скрипта без параметров показывает справку

Запуск тестирования:
> ./api_test_verification_photo.sh -v -t extract 127.0.0.1:8080


# Load tests
Вызов скрипта без параметров показывает справку

Опция -t указы вает тип биопроцессора (sound/photo). Без опции, по умолчанию, тестируется photo.

Опция -b запускает тест в screen, для 8 часового теста на стабильность. Вывод jmeter можно посмотреть так: tail -f tmp/jmeter.log

Опция -r задает RAMP-UP период.

Скрипт stop_load.sh останавливает тест.

Пример запуска:
> ./start_load_verification.sh tevian_gpu extract 3 127.0.0.1 8080
