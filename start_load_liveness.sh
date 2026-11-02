#!/bin/bash

# ================================================================================
# DESC:    обертка для запуска нагрузочных тестов API liveness
# VERSION: 1.2.0
# ================================================================================

##### настройки среды и глобальные параметры
source include/common/f_config.sh
source include/common/f_validate_input_params.sh
source include/common/f_print_test_version.sh
source include/load/dataset-generation/f_gen_dataset.sh

# путь до текущего скрипта, вне зависимости от того, откуда он будет вызван
CURRENT_FILE_PATH="${BASH_SOURCE[0]}"

##### функция вывода справки
f_print_usage() {
  echo "Использование: $0 [OPTIONS] VENDOR THREADS ENDPOINT

OPTIONS:
  -b          запуск в фоновом режиме (screen)
  -t  string  тип тест-кейсов (укажите одно из значений):
                * sound
                * photo (по умолчанию)
                * p_video (passive liveness video)
                * a_video (active liveness video)
  -m  string  мнемоника (только для active liveness video):
                * move (move-instructions)
                * text (text-instructions)
  -i  string  move-инструкции (только для move-instructions), например 1,2,3,4,6 или all:
                * 1 (TURN_RIGHT)
                * 2 (TURN_LEFT)
                * 3 (TURN_UP)
                * 4 (TURN_DOWN)
                * 5 (SMILE)
                * 6 (BLINK)
                * 7 (DISTORTION)
                * 8 (RAISE_EYEBROW)
                * all
  -s  string  абсолютный путь к директории, в которой находятся образцы для тестирования (для типа \"a_video\" опция обязательна)
  -a  string  версия API (по умолчанию \"v1\")
  -p  string  префикс (необязательная составная часть пути)
  -r  int     период ramp-up, сек (по умолчанию 0)
  
VENDOR    string  наименование вендора
THREADS   string  количество потоков нагрузки
ENDPOINT  string  <IP/DNS>:<ПОРТ>"
}

##### основная функция → точка входа
main() {
  if [[ -z "$1" ]]; then
    f_print_usage
  else
    while [[ -n "$1" ]]; do
      case "$1" in
        -b) local background_mode=true; shift;;
        -t) TYPE="$2"; shift; shift;;
        -m) MNEMONIC="$2"; shift; shift;;
        -i) INSTRUCTIONS="$2"; shift; shift;;
        -s) SAMPLE_DIR="$2"; shift; shift;;
        -a) API_VERSION="$2"; shift; shift;;
        -p) local prefix="$2"; shift; shift;;
        -r) RAMP_UP_PERIOD="$2"; shift; shift;;
        *) break;;
      esac
    done

    local required_positional_arguments_count=3
    if [[ "$#" != "$required_positional_arguments_count" ]]; then
      f_print_usage
    else
      ### обязательные параметры
      local vendor="$1"
      THREADS="$2"
      ENDPOINT="$3"
      METHOD="$DETECT_API_METHOD"

      ### параметры тестового сценария
      local jmx_file="resources/jmx/liveness.jmx"
      local sum_interval=10
      local loop_count="-1"

      # параметры запуска в режиме "single file"
      SINGLE_SOUND_FILE_MODE_SAMPLE="resources/samples/sound_10s.wav"
      SINGLE_SOUND_FILE_MODE_METADATA="resources/metadata/p_lv_s_meta_10s.json"
      SINGLE_PHOTO_FILE_MODE_SAMPLE="resources/samples/photo_shumskiy.jpg"
      SINGLE_PHOTO_FILE_MODE_METADATA="resources/metadata/p_lv_p_meta.json"
      SINGLE_VIDEO_FILE_MODE_SAMPLE="resources/samples/video.mov"
      SINGLE_VIDEO_FILE_MODE_METADATA="resources/metadata/p_lv_v_meta.json"

      ### валидация входных данных и генерация датасета
      f_validate_input_params
      f_print_test_version
      f_gen_dataset

      ### подготовка остальных параметров для запуска теста
      local current_date
      current_date="$(date "+%Y-%m-%dT%H-%M-%S")"
      local jmeter_log="reports/${vendor}/${DETECT_API_METHOD}-${THREADS}thr-${RAMP_UP_PERIOD}r--${current_date}-jmeter.log"
      local report="reports/${vendor}/${DETECT_API_METHOD}-${THREADS}thr-${RAMP_UP_PERIOD}r--${current_date}-report.csv"
      local perflog="reports/${vendor}/${DETECT_API_METHOD}-${THREADS}thr-${RAMP_UP_PERIOD}r--${current_date}-perflog.csv"
      local failed_requests_log="reports/${vendor}/${DETECT_API_METHOD}-${THREADS}thr-${RAMP_UP_PERIOD}r--${current_date}-failed-requests.xml"
      local server="${ENDPOINT%%:*}"
      local port="${ENDPOINT##*:}"
      local api_location

      if [[ -n "$prefix" ]]; then
        api_location="/${API_VERSION}/${prefix}/${LIVENESS_DETECT_PATH}"
      else
        api_location="/${API_VERSION}/${LIVENESS_DETECT_PATH}"
      fi

      echo "Датасет: $DETECT_CSV_DATASET"

      local jmeter_cmd=(
        jmeter
        -n
        -j "$jmeter_log"
        -t "$jmx_file"
        -l "$report"
        -Jsummariser.interval="$sum_interval"
        -Jthreads="$THREADS"
        -JrampUpPeriod="$RAMP_UP_PERIOD"
        -JloopCount="$loop_count"
        -JcsvDataset="$DETECT_CSV_DATASET"
        -Jdelimeter="$SEP_CHAR"
        -Jserver="$server"
        -Jport="$port"
        -JapiLocation="$api_location"
        -JmetadataPathColumn="$DETECT_CSV_DATASET_METADATA_PATH_COLUMN"
        -JmetadataParameterName="$METADATA_PARAMETER_NAME"
        -JmetadataMimeType="$JSON_MIME_TYPE"
        -JbioSampleColumn="$DETECT_CSV_DATASET_BIO_SAMPLE_COLUMN"
        -JbioSampleParameterName="$BIO_SAMPLE_PARAMETER_NAME"
        -JbioSampleMimeTypeColumn="$DETECT_CSV_DATASET_BIO_SAMPLE_MIME_TYPE_COLUMN"
        -JlivenessResponseCheckPatternColumn="$DETECT_CSV_DATASET_LIVENESS_RESPONSE_CHECK_PATTERN_COLUMN"
        -Jperflog="$perflog"
        -JfailedRequestsLog="$failed_requests_log"
      )

      if [[ "$background_mode" == true ]]; then
        jmeter_cmd='screen -dmS start.jmeter sh -c "'$jmeter_cmd'"'
      fi

      echo -e "\nЗапуск jmeter: ${jmeter_cmd[*]}\n"
      "${jmeter_cmd[@]}"
    fi
  fi
}

##### запуск теста
main "$@"
