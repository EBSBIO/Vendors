#!/bin/bash

# ================================================================================
# DESC:    функция вывода версии тестового сценария
# VERSION: 1.0.2
# ================================================================================

f_print_test_version() {
  local test_version current_date
  test_version=$(grep -m 1 "VERSION:" "$CURRENT_FILE_PATH" | awk '{print $3}')
  current_date=$(TZ="Europe/Moscow" date "+%d.%m.%Y %H:%M:%S")

  echo -e "Версия теста: '${CYAN_COLOR}${test_version}${NO_COLOR}'.
Дата запуска: '${CYAN_COLOR}${current_date}${NO_COLOR}'."
  echo "$DIVIDING_LINE"
}
