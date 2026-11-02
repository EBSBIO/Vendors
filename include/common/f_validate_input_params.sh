#!/bin/bash

# ================================================================================
# DESC:    функция проверки входных параметров запуска скриптов тестирования
# VERSION: 1.1.0
# ================================================================================

##### функция проверки на целые положительные числа
# аргументы:
#   $1 - текущий параметр
#   $2 - текущее значение параметра
f_validate_positive_num() {
  local current_parameter="$1"
  local current_value="$2"

  if [[ -z "$current_value" ]]; then
    echo "Ошибка: отсутствует значение для обязательного параметра '$current_parameter'." >&2
    has_errors=true
  elif [[ ! "$current_value" =~ $positive_integer_pattern ]]; then
    echo -e "Ошибка: передан некорректный аргумент для параметра '$current_parameter' → '${RED_COLOR}$current_value${NO_COLOR}'. Допустимое значение: целое положительное число." >&2
    has_errors=true
  fi
}

##### функция валидации опции -t
# аргументы:
#   $1 - текущее значение ($TYPE)
#   $2 - регулярное выражение со списком разрешенных типов (например: "wav|png")
#   $3 - дефолтное значение
f_validate_test_type() {
  local current_type="$1"
  local allowed_type_list="$2"
  local default_type="$3"

  if [[ -z "$current_type" ]]; then
    TYPE="$default_type"
    echo -e "Тип тест-кейсов: '${CYAN_COLOR}${TYPE}${NO_COLOR}'."
  elif [[ ! "$current_type" =~ ^($allowed_type_list)$ ]]; then
    echo -e "Ошибка: передан некорректный аргумент для опции '-t' → '${RED_COLOR}${current_type}${NO_COLOR}'. Допустимые значения: '${allowed_type_list}'." >&2
    has_errors=true
  fi
}

##### функция валидации опций -m и -i (active liveness video)
f_validate_active_liveness_mnemonic_and_actions() {
  if [[ "$TYPE" == "$ACTIVE_LIVENESS_VIDEO_TEST_TYPE" || "$TYPE" == "${PASSIVE_LIVENESS_VIDEO_TEST_TYPE}+${ACTIVE_LIVENESS_VIDEO_TEST_TYPE}" ]]; then
    if [[ "$MNEMONIC" != "$ACTIVE_LIVENESS_VIDEO_MOVE_MNEMONIC_ATTRIBUTE" && "$MNEMONIC" != "$ACTIVE_LIVENESS_VIDEO_TEXT_MNEMONIC_ATTRIBUTE" ]]; then
      echo -e "Ошибка: для API active liveness отсутствует или введено некорректное значение мнемоники (опция '-m'): '${RED_COLOR}${MNEMONIC}${NO_COLOR}'. Допустимые значения: '${ACTIVE_LIVENESS_VIDEO_MOVE_MNEMONIC_ATTRIBUTE}|${ACTIVE_LIVENESS_VIDEO_TEXT_MNEMONIC_ATTRIBUTE}'." >&2
      has_errors=true
    else
      echo -e "Выбрана следующая мнемоника API active liveness: '${CYAN_COLOR}${MNEMONIC}${NO_COLOR}'."
      if [[ "$MNEMONIC" == "$ACTIVE_LIVENESS_VIDEO_MOVE_MNEMONIC_ATTRIBUTE" ]]; then
        # базовая проверка опции "-i"
        if [[ -z "$INSTRUCTIONS" ]]; then
          echo "Ошибка: для мнемоники '$ACTIVE_LIVENESS_VIDEO_MOVE_MNEMONIC' не выбраны инструкции к действию (опция '-i')." >&2
          has_errors=true
        elif [[ "$INSTRUCTIONS" != "$ACTIVE_LIVENESS_VIDEO_ALL_MOVE_INSTRUCTIONS_ARGUMENT" && ! "$INSTRUCTIONS" =~ $instructions_base_format ]]; then
          echo -e "Ошибка: передан некорректный аргумент для опции '-i': '${RED_COLOR}${INSTRUCTIONS}${NO_COLOR}'. Примеры допустимых значений: 'all | 1,2,3,4,6'." >&2
          has_errors=true
        # расширенная проверка опции "-i"
        else
          if [[ "$INSTRUCTIONS" == "$ACTIVE_LIVENESS_VIDEO_ALL_MOVE_INSTRUCTIONS_ARGUMENT" ]]; then
            echo -e "Выбраны все move-инструкции: '${CYAN_COLOR}${INSTRUCTIONS}${NO_COLOR}'."
          else
            # создаем эталонную строку с аргументами → меняем запятые на переносы строк, сортируем численно (-n) и уникально (-u), удаляем запятую в конце (если есть)
            local etalon_instructions
            etalon_instructions=$(echo "$INSTRUCTIONS" | tr ',' '\n' | sort -nu | tr '\n' ',' | sed 's/,$//')
            if [[ "$INSTRUCTIONS" != "$etalon_instructions" ]]; then
              echo -e "Ошибка: передан некорректный аргумент для опции '-i' (нарушен порядок цифр, или есть повторения): '${RED_COLOR}${INSTRUCTIONS}${NO_COLOR}'." >&2
              has_errors=true
            else
              echo -e "Выбраны следующие move-инструкции: '${CYAN_COLOR}${INSTRUCTIONS}${NO_COLOR}'."
            fi
          fi
        fi
      elif [[ "$MNEMONIC" == "$ACTIVE_LIVENESS_VIDEO_TEXT_MNEMONIC_ATTRIBUTE" ]]; then
        echo -e "Выбрана следующая text-инструкция: '${CYAN_COLOR}${ACTIVE_LIVENESS_VIDEO_TEXT_TYPE}${NO_COLOR}'."
        if [[ -n "$INSTRUCTIONS" ]]; then
          INSTRUCTIONS=
          echo "Для мнемоники '$ACTIVE_LIVENESS_VIDEO_TEXT_MNEMONIC_ATTRIBUTE' выбор инструкций не требуется. Опция '-i' будет проигнорирована."
        fi
      fi
    fi
  else
    [[ -n "$MNEMONIC" ]] && MNEMONIC= && echo "Опция -m будет проигнорирована."
    [[ -n "$INSTRUCTIONS" ]] && INSTRUCTIONS= && echo "Опция -i будет проигнорирована."
  fi
}

##### функция валидации параметра METHOD
# аргументы:
#   $1 - текущий параметр/опция
#   $2 - текущее значение ($METHOD)
#   $3 - регулярное выражение со списком разрешенных методов (например: "extract|verify")
#   $4 - дефолтное значение (необязательный параметр)
f_validate_method() {
  local current_parameter="$1"
  local current_method="$2"
  local allowed_method_list="$3"
  local default_method="$4"

  if [[ -z "$current_method" && -n "$default_method" ]]; then
    METHOD="$default_method"
    echo -e "Метод API: '${CYAN_COLOR}${METHOD}${NO_COLOR}'."
  elif [[ -z "$current_method" && -z "$default_method" ]]; then
    echo "Ошибка: отсутствует значение для обязательного параметра 'METHOD'." >&2
    has_errors=true
  elif [[ ! "$current_method" =~ ^($allowed_method_list)$ ]]; then
    echo -e "Ошибка: передан некорректный аргумент при выборе метода API (опция/параметр '${current_parameter}'): '${RED_COLOR}${current_method}${NO_COLOR}'. Допустимые значения: '$allowed_method_list'." >&2
    has_errors=true
  fi
}

##### универсальная функция валидации входных параметров
f_validate_input_params() {
  ### общие параметры
  local default_num_value=0
  local positive_integer_pattern="^[1-9][0-9]*$"

  ### параметры TCP
  local port_format="^[0-9]+$"
  local min_port=1
  local max_port=65535
  local tcp_timeout=3

  ### названия опций и позиционных аргументов (параметров) тестовых сценариев
  local timeout_parameter_name="TIMEOUT"
  local method_option_name="-m"
  local method_parameter_name="METHOD"
  local threads_parameter_name="THREADS"
  local duration_parameter_name="DURATION"

  ### параметры тест-кейсов liveness
  local instructions_base_format="^[1-8](,[1-8])*$"

  ### параметры API БП
  local default_api_version="v1"
  local api_version_pattern="^v[1-9][0-9]*$"
  local default_method="all"

  ### исходное состояние
  local has_errors=false

  ### проверка состояние временного каталога
  [[ ! -d "$TMP_DIR" ]] && mkdir "$TMP_DIR"

  echo "$DIVIDING_LINE"
  ### валидация входных данных тестов API
  if [[ "$0" =~ $API_TEST_ATTRIBUTE ]]; then
    # проверка параметра "TIMEOUT"
    f_validate_positive_num "$timeout_parameter_name" "$TIMEOUT"
  fi

  ### валидация входных данных тестов API liveness
  if [[ "$0" =~ $LIVENESS_API_TEST_ATTRIBUTE ]]; then
    # проверка опции "-t"
    f_validate_test_type "$TYPE" "${SOUND_TEST_TYPE}|${PHOTO_TEST_TYPE}|${PASSIVE_LIVENESS_VIDEO_TEST_TYPE}|${ACTIVE_LIVENESS_VIDEO_TEST_TYPE}|${PHOTO_TEST_TYPE}\+${PASSIVE_LIVENESS_VIDEO_TEST_TYPE}|${PASSIVE_LIVENESS_VIDEO_TEST_TYPE}\+${ACTIVE_LIVENESS_VIDEO_TEST_TYPE}" "$DEFAULT_TEST_TYPE"

    # проверка опций "-m" и "-i" в контексте active liveness
    f_validate_active_liveness_mnemonic_and_actions
  fi

  ### валидация входных данных API тестов verification и identification
  if [[ "$0" =~ $VERIFICATION_API_TEST_ATTRIBUTE ]]; then
    # проверка опции "-m"
    f_validate_method "$method_option_name" "$METHOD" "${default_method}|${HEALTH_API_METHOD}|${EXTRACT_API_METHOD}|${COMPARE_API_METHOD}|${VERIFY_API_METHOD}" "$default_method"
  elif [[ "$0" =~ $IDENTIFICATION_API_TEST_ATTRIBUTE ]]; then
    # проверка опции "-m"
    f_validate_method "$method_option_name" "$METHOD" "${default_method}|${HEALTH_API_METHOD}|${EXTRACT_API_METHOD}|${ADD_API_METHOD}|${UPDATE_API_METHOD}|${DELETE_API_METHOD}|${MATCH_API_METHOD}|${IDENTIFY_API_METHOD}" "$default_method"
  fi

  ### валидация входных данных нагрузочных тестов
  if [[ "$0" =~ $LOAD_TEST_ATTRIBUTE ]]; then
    # проверка опции "-t"
    if [[ "$0" =~ $LIVENESS_LOAD_TEST_ATTRIBUTE ]]; then
      f_validate_test_type "$TYPE" "${SOUND_TEST_TYPE}|${PHOTO_TEST_TYPE}|${PASSIVE_LIVENESS_VIDEO_TEST_TYPE}|${ACTIVE_LIVENESS_VIDEO_TEST_TYPE}" "$DEFAULT_TEST_TYPE"

      # проверка опций "-m" и "-i" в контексте active liveness
      f_validate_active_liveness_mnemonic_and_actions
    else
      f_validate_test_type "$TYPE" "${SOUND_TEST_TYPE}|${PHOTO_TEST_TYPE}" "$DEFAULT_TEST_TYPE"
    fi

    # проверка опции "-s"
    if [[ -n "$SAMPLE_DIR" && ! -d "$SAMPLE_DIR" ]]; then
      echo -e "Ошибка: объект '${RED_COLOR}${SAMPLE_DIR}${NO_COLOR}' не существует или не является директорией (опция '-s')." >&2
      has_errors=true
    elif [[ -z "$SAMPLE_DIR" && "$TYPE" == "$ACTIVE_LIVENESS_VIDEO_TEST_TYPE" ]]; then
      # для типа "a_video" опция "-s" обязательна
      echo "Ошибка: для сценария '$0' с типом '${TYPE}' опция '-s' является обязательной." >&2
      has_errors=true
    fi

    # проверка опции "-r"
    RAMP_UP_PERIOD=${RAMP_UP_PERIOD:-$default_num_value}
    if [[ "$RAMP_UP_PERIOD" == "$default_num_value" ]]; then
      echo "Период ramp-up: '$RAMP_UP_PERIOD'. Потоки нагрузки будут запущены одновременно."
    elif [[ ! "$RAMP_UP_PERIOD" =~ $positive_integer_pattern ]]; then
      echo -e "Ошибка: передан некорректный аргумент для опции '-r': '${RED_COLOR}${RAMP_UP_PERIOD}${NO_COLOR}'. Допустимое значение: целое положительное число." >&2
      has_errors=true
    fi

    # проверка параметра "THREADS"
    f_validate_positive_num "$threads_parameter_name" "$THREADS"
  fi

  ### валидация входных данных нагрузочных тестов verification
  if [[ "$0" =~ $VERIFICATION_LOAD_TEST_ATTRIBUTE ]]; then
    # проверка параметра "METHOD"
    f_validate_method "$method_parameter_name" "$METHOD" "${EXTRACT_API_METHOD}|${COMPARE_API_METHOD}|${VERIFY_API_METHOD}"
  fi

  ### валидация входных данных нагрузочных тестов identification
  if [[ "$0" =~ $IDENTIFICATION_LOAD_TEST_ATTRIBUTE ]]; then
    # проверка параметра "METHOD"
    f_validate_method "$method_parameter_name" "$METHOD" "${EXTRACT_API_METHOD}|${ADD_API_METHOD}|${UPDATE_API_METHOD}|${DELETE_API_METHOD}|${MATCH_API_METHOD}|${IDENTIFY_API_METHOD}"

    # проверка параметра "DURATION"
    f_validate_positive_num "$duration_parameter_name" "$DURATION"
  fi

  ### общая валидация
  # проверка опции "-a"
  if [[ -z "$API_VERSION" ]]; then
    API_VERSION="$default_api_version"
    echo -e "Версия API: '${CYAN_COLOR}${API_VERSION}${NO_COLOR}'."
  elif [[ ! "$API_VERSION" =~ $api_version_pattern ]]; then
    echo -e "Ошибка: передан некорректный аргумент для опции '-a': '${RED_COLOR}${API_VERSION}${NO_COLOR}'. Формат: префикс «v» и целое положительное число." >&2
    has_errors=true
  fi

  # проверка параметра "ENDPOINT"
  if [[ -z "$ENDPOINT" ]]; then
    echo "Ошибка: отсутствует значение для обязательного параметра 'ENDPOINT'." >&2
    has_errors=true
  else
    local server="${ENDPOINT%%:*}"
    local port="${ENDPOINT##*:}"

    # базовая проверка "ENDPOINT"
    if [[ "$server" == "$port" || ! "$port" =~ $port_format ]]; then
      echo -e "Ошибка: передан некорректный аргумент для параметра 'ENDPOINT': '${RED_COLOR}${ENDPOINT}${NO_COLOR}'. Пример ENDPOINT: '127.0.0.1:8080' или 'test-server:8080'." >&2
      has_errors=true
    # расширенная проверка "ENDPOINT"
    elif ((port < min_port || port > max_port)); then
      echo -e "Ошибка: порт '${RED_COLOR}${port}${NO_COLOR}' выходит за границы допустимого диапазона (1-65535)." >&2
      has_errors=true
    elif ! timeout "$tcp_timeout" bash -c "cat < /dev/null > /dev/tcp/$server/$port" >/dev/null 2>&1; then
      echo "Ошибка: сервер '$server' на порту '$port' недоступен." >&2
      has_errors=true
    fi
  fi
  echo "$DIVIDING_LINE"

  if [[ "$has_errors" == true ]]; then
    exit "$EXIT_ERROR_CODE"
  fi
}
