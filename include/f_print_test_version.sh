#!/bin/bash

# ================================================================================
# DESC:    функция вывода информации о скриптах
# VERSION: 1.0.1
# ================================================================================

##### универсальная функция вывода информации о скриптах
f_print_test_version() {
    ### локальные параметры
    local test_version=$(grep -m 1 "VERSION:" "$CURRENT_FILE" | awk '{print $3}')
    local current_date=$(TZ="Europe/Moscow" && date "+%d.%m.%Y %H:%M:%S")
    
    echo -e "Версия теста: '${CYAN_COLOR}${test_version}${NO_COLOR}'. Дата запуска: '${CYAN_COLOR}${current_date}${NO_COLOR}'."
    echo -e "${BLUE_COLOR}----------${NO_COLOR}"
}
