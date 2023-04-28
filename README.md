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
