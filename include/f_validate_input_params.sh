#!/bin/bash

# ================================================================================
# DESC:    функция проверки входных параметров запуска скриптов тестирования
# VERSION: 1.0.0
# ================================================================================

##### общие параметры
GREEN_COLOR="\033[32m"
RED_COLOR="\033[0;31m"
NO_COLOR="\033[0m"
CACHE_FILE="tmp/autotest-cache"
EXIT_ERROR_CODE=1

##### параметры TCP
PORT_FORMAT="^[0-9]+$"
MIN_PORT=1
MAX_PORT=65535
TCP_TIMEOUT=3

##### атрибуты тестовых сценариев
API_TEST_ATTRIBUTE="api"
LIVENESS_API_TEST_ATTRIBUTE="api_test_liveness"
VERIFICATION_API_TEST_ATTRIBUTE="api_test_verification"
IDENTIFICATION_API_TEST_ATTRIBUTE="api_test_identification"
LOAD_TEST_ATTRIBUTE="load"
LIVENESS_LOAD_TEST_ATTRIBUTE="load_liveness"
VERIFICATION_LOAD_TEST_ATTRIBUTE="load_verification"
IDENTIFICATION_LOAD_TEST_ATTRIBUTE="load_identification"

##### названия опций и параметров тестовых сценариев
TIMEOUT_PARAMETER_NAME="TIMEOUT"
METHOD_OPTION_NAME="-m"
METHOD_PARAMETER_NAME="METHOD"
THREADS_PARAMETER_NAME="THREADS"
DURATION_PARAMETER_NAME="DURATION"

##### типы тест-кейсов в зависимости от БО
DEFAULT_TEST_TYPE="photo"
SOUND_TEST_TYPE="sound"
PHOTO_TEST_TYPE="photo"
VIDEO_TEST_TYPE="video"

##### параметры тест-кейсов liveness
PASSIVE_VIDEO_TEST_TYPE="p_video"
ACTIVE_VIDEO_TEST_TYPE="a_video"
MOVE_MNEMONIC="move-instructions"
MOVE_MNEMONIC_ATTRIBUTE="move"
TEXT_MNEMONIC_ATTRIBUTE="text"
ALL_MOVE_INSTRUCTIONS="all"
INSTRUCTIONS_BASE_FORMAT="^[1-8](,[1-8])*$"
TEXT_INSTRUCTION="numbers-digits"

##### типы тестовых БО, БШ, json
WAV_FILE_TYPE="wav"
JPG_FILE_TYPE="jpg"
JPEG_FILE_TYPE="jpeg"
PNG_FILE_TYPE="png"
WEBM_FILE_TYPE="webm"
MP4_FILE_TYPE="mp4"
MOV_FILE_TYPE="mov"
VECTOR_TYPE="octet-stream"
JSON_TYPE="json"

##### числовые константы
DEFAULT_NUM_VALUE=0
POSITIVE_INTEGER_PATTERN="^[1-9][0-9]*$"

##### параметры API БП
DEFAULT_API_VERSION="v1"
API_VERSION_PATTERN="^v[1-9][0-9]*$"
DEFAULT_METHOD="all"
HEALTH_METHOD="health"
EXTRACT_METHOD="extract"
COMPARE_METHOD="compare"
VERIFY_METHOD="verify"
ADD_METHOD="add"
UPDATE_METHOD="update"
DELETE_METHOD="delete"
MATCH_METHOD="match"
IDENTIFY_METHOD="identify"

##### функция проверки на целые положительные числа
# аргументы:
#   $1 - текущий параметр
#   $2 - текущее значение параметра
f_validate_positive_num() {
    local current_parameter="$1"
    local current_value="$2"

    if [[ -z "$current_value" ]]; then
        echo "Ошибка: отсутствует значение для обязательного параметра '$current_parameter'." >&2
        HAS_ERRORS=true
    elif [[ ! "$current_value" =~ $POSITIVE_INTEGER_PATTERN ]]; then
        echo -e "Ошибка: передан некорректный аргумент для параметра '$current_parameter' → '${RED_COLOR}$current_value${NO_COLOR}'. Допустимое значение: целое положительное число." >&2
        HAS_ERRORS=true
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
        echo -e "Тип тест-кейсов: '${GREEN_COLOR}${TYPE}${NO_COLOR}'."
    elif [[ ! "$current_type" =~ ^($allowed_type_list)$ ]]; then
        echo -e "Ошибка: передан некорректный аргумент для опции '-t' → '${RED_COLOR}${current_type}${NO_COLOR}'. Допустимые значения: '${allowed_type_list}'." >&2
        
        # обнуляем TYPE, чтобы не сканировать SAMPLE_DIR
        TYPE=""
        HAS_ERRORS=true
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
        echo -e "Метод API: '${GREEN_COLOR}${METHOD}${NO_COLOR}'."
    elif [[ -z "$current_method" && -z "$default_method" ]]; then
        echo "Ошибка: отсутствует значение для обязательного параметра 'METHOD'." >&2
        HAS_ERRORS=true
    elif [[ ! "$current_method" =~ ^($allowed_method_list)$ ]]; then
        echo -e "Ошибка: передан некорректный аргумент при выборе метода API (опция/параметр '${current_parameter}'): '${RED_COLOR}${current_method}${NO_COLOR}'. Допустимые значения: '$allowed_method_list'." >&2
        HAS_ERRORS=true
    fi
}

##### универсальная функция валидации входных параметров
f_validate_input_params() {
    # исходное состояние
    HAS_ERRORS=false

    echo "-----"

    ### валидация входных данных тестов API
    if [[ "$0" =~ $API_TEST_ATTRIBUTE ]]; then
        # проверка параметра "TIMEOUT"
        f_validate_positive_num "$TIMEOUT_PARAMETER_NAME" "$TIMEOUT"
    fi

    ### валидация входных данных тестов API liveness
    if [[ "$0" =~ $LIVENESS_API_TEST_ATTRIBUTE ]]; then
        # проверка опции "-t"
        f_validate_test_type "$TYPE" "${SOUND_TEST_TYPE}|${PHOTO_TEST_TYPE}|${PASSIVE_VIDEO_TEST_TYPE}|${ACTIVE_VIDEO_TEST_TYPE}|${PHOTO_TEST_TYPE}\+${PASSIVE_VIDEO_TEST_TYPE}|${PASSIVE_VIDEO_TEST_TYPE}\+${ACTIVE_VIDEO_TEST_TYPE}" "$DEFAULT_TEST_TYPE"

        # проверка опций "-m" и "-i" в контексте active liveness
        if [[ "$TYPE" == "$ACTIVE_VIDEO_TEST_TYPE" || "$TYPE" == "${PASSIVE_VIDEO_TEST_TYPE}+${ACTIVE_VIDEO_TEST_TYPE}" ]]; then
            if [[ "$MNEMONIC" != "$MOVE_MNEMONIC_ATTRIBUTE" && "$MNEMONIC" != "$TEXT_MNEMONIC_ATTRIBUTE" ]]; then
                echo -e "Ошибка: для API active liveness отсутствует или введено некорректное значение мнемоники (опция '-m'): '${RED_COLOR}${MNEMONIC}${NO_COLOR}'. Допустимые значения: '${MOVE_MNEMONIC_ATTRIBUTE}|${TEXT_MNEMONIC_ATTRIBUTE}'." >&2
                HAS_ERRORS=true
            else
                echo -e "Выбрана следующая мнемоника API active liveness: '${GREEN_COLOR}${MNEMONIC}${NO_COLOR}'."
                if [[ "$MNEMONIC" == "$MOVE_MNEMONIC_ATTRIBUTE" ]]; then
                    # базовая проверка опции "-i"
                    if [[ -z "$INSTRUCTIONS" ]]; then
                        echo "Ошибка: для мнемоники '$MOVE_MNEMONIC' не выбраны инструкции к действию (опция '-i')." >&2
                        HAS_ERRORS=true
                    elif [[ "$INSTRUCTIONS" != "$ALL_MOVE_INSTRUCTIONS" && ! "$INSTRUCTIONS" =~ $INSTRUCTIONS_BASE_FORMAT ]]; then
                        echo -e "Ошибка: передан некорректный аргумент для опции '-i': '${RED_COLOR}${INSTRUCTIONS}${NO_COLOR}'. Примеры допустимых значений: 'all | 1,2,3,4,6'." >&2
                        HAS_ERRORS=true
                    # расширенная проверка опции "-i"
                    else
                        if [[ "$INSTRUCTIONS" == "$ALL_MOVE_INSTRUCTIONS" ]]; then
                            echo -e "Выбраны все move-инструкции: '${GREEN_COLOR}${INSTRUCTIONS}${NO_COLOR}'."
                        else
                            # создаем эталонную строку с аргументами → меняем запятые на переносы строк, сортируем численно (-n) и уникально (-u), удаляем запятую в конце (если есть)
                            ETALON_INSTRUCTIONS=$(echo "$INSTRUCTIONS" | tr ',' '\n' | sort -nu | tr '\n' ',' | sed 's/,$//')
                            if [[ "$INSTRUCTIONS" != "$ETALON_INSTRUCTIONS" ]]; then
                                echo -e "Ошибка: передан некорректный аргумент для опции '-i' (нарушен порядок цифр или есть повторения): '${RED_COLOR}${INSTRUCTIONS}${NO_COLOR}'." >&2
                                HAS_ERRORS=true
                            else
                                echo -e "Выбраны следующие move-инструкции: '${GREEN_COLOR}${INSTRUCTIONS}${NO_COLOR}'."
                            fi
                        fi
                    fi
                elif [[ ("$MNEMONIC" == "$TEXT_MNEMONIC_ATTRIBUTE") ]]; then
                    echo -e "Выбрана следующая text-инструкция: '${GREEN_COLOR}${TEXT_INSTRUCTION}${NO_COLOR}'."
                    if [[ -n "$INSTRUCTIONS" ]]; then
                        echo "Для мнемоники '$TEXT_MNEMONIC_ATTRIBUTE' выбор инструкций не требуется. Опция '-i' будет проигнорирована."
                    fi
                fi
            fi
        else
            [[ -n "$MNEMONIC" ]] && echo "Опция -m будет проигнорирована."
            [[ -n "$INSTRUCTIONS" ]] && echo "Опция -i будет проигнорирована."
        fi
    fi

    ### валидация входных данных API тестов verification и identification
    if [[ "$0" =~ $VERIFICATION_API_TEST_ATTRIBUTE ]]; then
        # проверка параметра "-m"
        f_validate_method "$METHOD_OPTION_NAME" "$METHOD" "${DEFAULT_METHOD}|${HEALTH_METHOD}|${EXTRACT_METHOD}|${COMPARE_METHOD}|${VERIFY_METHOD}" "$DEFAULT_METHOD"
    elif [[ "$0" =~ $IDENTIFICATION_API_TEST_ATTRIBUTE ]]; then
        # проверка опции "-m"
        f_validate_method "$METHOD_OPTION_NAME" "$METHOD" "${DEFAULT_METHOD}|${HEALTH_METHOD}|${EXTRACT_METHOD}|${ADD_METHOD}|${UPDATE_METHOD}|${DELETE_METHOD}|${MATCH_METHOD}|${IDENTIFY_METHOD}" "$DEFAULT_METHOD"
    fi

    ### валидация входных данных нагрузочных тестов
    if [[ "$0" =~ $LOAD_TEST_ATTRIBUTE ]]; then
        # проверка опции "-t"
        if [[ "$0" =~ $LIVENESS_LOAD_TEST_ATTRIBUTE ]]; then
            f_validate_test_type "$TYPE" "${SOUND_TEST_TYPE}|${PHOTO_TEST_TYPE}|${VIDEO_TEST_TYPE}" "$DEFAULT_TEST_TYPE"
            if [[ "$TYPE" == "$VIDEO_TEST_TYPE" && -z "$SAMPLE_DIR" ]]; then
                echo "Ошибка: для сценария '$0' с типом '${VIDEO_TEST_TYPE}' опция '-s' является обязательной." >&2
                HAS_ERRORS=true
            fi
        else
            f_validate_test_type "$TYPE" "${SOUND_TEST_TYPE}|${PHOTO_TEST_TYPE}" "$DEFAULT_TEST_TYPE"
        fi
        
        # проверка опции "-s"
        if [[ -n "$TYPE" ]]; then
            if [[ -n "$SAMPLE_DIR" && -d "$SAMPLE_DIR" ]]; then
                [[ "$TYPE" == "$SOUND_TEST_TYPE" ]] && FILE_TYPE="$WAV_FILE_TYPE"
                [[ "$TYPE" == "$PHOTO_TEST_TYPE" ]] && FILE_TYPE="${JPG_FILE_TYPE}|${JPEG_FILE_TYPE}|${PNG_FILE_TYPE}"
                [[ "$TYPE" == "$VIDEO_TEST_TYPE" ]] && FILE_TYPE="${WEBM_FILE_TYPE}|${MP4_FILE_TYPE}|${MOV_FILE_TYPE}"
            
                # получаем дату последнего изменения в unix timestamp
                SAMPLE_DIR=$(realpath "$SAMPLE_DIR")
                CURRENT_MOD_TIME=$(stat -c %Y "$SAMPLE_DIR")

                USE_CACHE=false

                # проверяем, есть ли валидный кеш
                if [[ -f "$CACHE_FILE" ]]; then
                    read -r CACHED_TYPE CACHED_SAMPLE_DIR CACHED_MOD_TIME ALL_COUNT SAMPLE_COUNT VECTOR_COUNT JSON_LIVENESS_INSTRUCTIONS_COUNT UNKNOWN_COUNT < "$CACHE_FILE"
                    if [[ "$CACHED_TYPE" == "$TYPE" && "$CACHED_SAMPLE_DIR" == "$SAMPLE_DIR" && "$CACHED_MOD_TIME" == "$CURRENT_MOD_TIME" ]]; then
                        USE_CACHE=true
                    fi
                fi

                if [[ "$USE_CACHE" == "false" ]]; then
                    # сканируем датасет
                    DATASET_STATS=$(find "$SAMPLE_DIR" -type f | awk -v file_type="$FILE_TYPE" -v vector_type="$VECTOR_TYPE" -v json_type="$JSON_TYPE" '
                        BEGIN { total=0; sample=0; vector=0; json=0 }
                        {
                            total++
                            if (tolower($0) ~ "\\.(" file_type ")$") sample++
                            else if (tolower($0) ~ "\\.(" vector_type ")$") vector++
                            else if (tolower($0) ~ "\\.(" json_type ")$") json++
                        }
                        END { print total, sample, vector, json }
                    ')

                    # парсим результат
                    read -r ALL_COUNT SAMPLE_COUNT VECTOR_COUNT JSON_LIVENESS_INSTRUCTIONS_COUNT <<< "$DATASET_STATS"

                    # вычисляем кол-во файлов, не подходящих ни под одно условие
                    UNKNOWN_COUNT=$((ALL_COUNT - SAMPLE_COUNT - VECTOR_COUNT - JSON_LIVENESS_INSTRUCTIONS_COUNT))

                    # записываем обновленные данные в кеш
                    echo "$TYPE $SAMPLE_DIR $CURRENT_MOD_TIME $ALL_COUNT $SAMPLE_COUNT $VECTOR_COUNT $JSON_LIVENESS_INSTRUCTIONS_COUNT $UNKNOWN_COUNT" > "$CACHE_FILE"
                fi

                echo -e "Результаты сканирования датасета '$SAMPLE_DIR'):
    – результаты сканирования из кеша: $([[ "$USE_CACHE" == "true" ]] && echo "'true'" || echo "'false'")
    – всего файлов: $ALL_COUNT
    – найдено биометрических образцов с расширением '$FILE_TYPE': $SAMPLE_COUNT
    – найдено векторов: $VECTOR_COUNT
    – найдено json: $JSON_LIVENESS_INSTRUCTIONS_COUNT
    – найдено неизвестных файлов: ${RED_COLOR}${UNKNOWN_COUNT}${NO_COLOR}
                "
            else
                echo -e "Ошибка: объект '${RED_COLOR}${SAMPLE_DIR}${NO_COLOR}' не существует или не является директорией (опция '-s')." >&2
                HAS_ERRORS=true
            fi
        fi

        # проверка опции "-r"
        RAMP=${RAMP:-$DEFAULT_NUM_VALUE}
        if [[ "$RAMP" == "$DEFAULT_NUM_VALUE" ]]; then
            echo "Период ramp-up: '$RAMP'. Потоки нагрузки будут запущены одновременно."
        elif [[ ! "$RAMP" =~ $POSITIVE_INTEGER_PATTERN ]]; then
            echo -e "Ошибка: передан некорректный аргумент для опции '-r': '${RED_COLOR}${RAMP}${NO_COLOR}'. Допустимое значение: целое положительное число." >&2
            HAS_ERRORS=true
        fi

        # проверка параметра "THREADS"
        f_validate_positive_num "$THREADS_PARAMETER_NAME" "$THREADS"
    fi

    ### валидация входных данных нагрузочных тестов verification
    if [[ "$0" =~ $VERIFICATION_LOAD_TEST_ATTRIBUTE ]]; then
        # проверка параметра "METHOD"
        f_validate_method "$METHOD_PARAMETER_NAME" "$METHOD" "${EXTRACT_METHOD}|${COMPARE_METHOD}|${VERIFY_METHOD}"
    fi

    ### валидация входных данных нагрузочных тестов identification
    if [[ "$0" =~ $IDENTIFICATION_LOAD_TEST_ATTRIBUTE ]]; then
        # проверка параметра "METHOD"
        f_validate_method "$METHOD_PARAMETER_NAME" "$METHOD" "${EXTRACT_METHOD}|${ADD_METHOD}|${UPDATE_METHOD}|${DELETE_METHOD}|${MATCH_METHOD}|${IDENTIFY_METHOD}"

        # проверка параметра "DURATION"
        f_validate_positive_num "$DURATION_PARAMETER_NAME" "$DURATION"
    fi

    ### общая валидация
    # проверка опции "-a"
    if [[ -z "$API_VERSION" ]]; then
        API_VERSION="$DEFAULT_API_VERSION"
        echo -e "Версия API: '${GREEN_COLOR}${API_VERSION}${NO_COLOR}'."
    elif [[ ! "$API_VERSION" =~ $API_VERSION_PATTERN ]]; then
        echo -e "Ошибка: передан некорректный аргумент для опции '-a': '${RED_COLOR}${API_VERSION}${NO_COLOR}'. Формат: префикс «v» и целое положительное число." >&2
        HAS_ERRORS=true
    fi

    # проверка параметра "ENDPOINT"
    if [[ -z "$ENDPOINT" ]]; then
        echo "Ошибка: отсутствует значение для обязательного параметра 'ENDPOINT'." >&2
        HAS_ERRORS=true
    else
        TMP_SERVER="${ENDPOINT%%:*}"
        TMP_PORT="${ENDPOINT##*:}"

        # базовая проверка "ENDPOINT"
        if [[ "$TMP_SERVER" == "$TMP_PORT" || ! "$TMP_PORT" =~ $PORT_FORMAT ]]; then
            echo -e "Ошибка: передан некорректный аргумент для параметра 'ENDPOINT': '${RED_COLOR}${ENDPOINT}${NO_COLOR}'. Пример ENDPOINT: '127.0.0.1:8080' или 'test-server:8080'." >&2
            HAS_ERRORS=true
        # расширенная проверка "ENDPOINT"
        elif ((TMP_PORT < MIN_PORT || TMP_PORT > MAX_PORT)); then
            echo -e "Ошибка: порт '${RED_COLOR}${TMP_PORT}${NO_COLOR}' выходит за границы допустимого диапазона (1-65535)." >&2
            HAS_ERRORS=true
        elif ! timeout "$TCP_TIMEOUT" bash -c "cat < /dev/null > /dev/tcp/$TMP_SERVER/$TMP_PORT" >/dev/null 2>&1; then
            echo "Ошибка: сервер '$TMP_SERVER' на порту '$TMP_PORT' недоступен." >&2
            HAS_ERRORS=true
        fi
    fi

    echo "-----"

    if [[ "$HAS_ERRORS" == true ]]; then
        exit $EXIT_ERROR_CODE
    fi
}
