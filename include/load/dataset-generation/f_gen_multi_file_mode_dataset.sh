#!/bin/bash

# ================================================================================
# DESC:    функция генерации датасета в режиме "multi file"
# VERSION: 1.0.0
# ================================================================================

##### функция определения контекста датасета
f_init_dataset_context() {
  if [[ "$METHOD" =~ $DETECT_API_METHOD ]]; then
    dataset_state_cache="$DETECT_DATASET_STATE_CACHE"
    csv_dataset="$DETECT_CSV_DATASET"
  elif [[ "$METHOD" =~ ${EXTRACT_API_METHOD}|${IDENTIFY_API_METHOD} ]]; then
    dataset_state_cache="$EXTRACT_IDENTIFY_DATASET_STATE_CACHE"
    csv_dataset="$EXTRACT_IDENTIFY_CSV_DATASET"
  elif [[ "$METHOD" =~ ${COMPARE_API_METHOD}|${ADD_API_METHOD}|${MATCH_API_METHOD} ]]; then
    dataset_state_cache="$COMPARE_ADD_MATCH_DATASET_STATE_CACHE"
    csv_dataset="$COMPARE_ADD_MATCH_CSV_DATASET"
  elif [[ "$METHOD" =~ $VERIFY_API_METHOD ]]; then
    dataset_state_cache="$VERIFY_DATASET_STATE_CACHE"
    csv_dataset="$VERIFY_CSV_DATASET"
  elif [[ "$METHOD" =~ ${UPDATE_API_METHOD}|${DELETE_API_METHOD} ]]; then
    dataset_state_cache="$UPDATE_DELETE_DATASET_STATE_CACHE"
    csv_dataset="$UPDATE_DELETE_CSV_DATASET"
  fi
}

##### функция вывода результата сканирования датасета
f_print_scan_results() {
  local file_type_pattern="$1"
  local total="$2"
  local sample_count="$3"
  local vector_count="$4"
  local json_count="$5"
  local unknown_count="$6"

  echo -e "Результаты сканирования датасета '$SAMPLE_DIR'):
    – результаты сканирования из кеша: $([[ "$should_gen_csv_dataset" == "false" ]] && echo "'true'" || echo "'false'")
    – всего файлов: '${total}'
    – найдено биометрических образцов с расширением '$file_type_pattern': '${sample_count}'
    – найдено векторов: '${vector_count}'
    – найдено json: '${json_count}'
    – найдено неизвестных файлов: '${RED_COLOR}${unknown_count}${NO_COLOR}'"
}

##### функция определения mime type по расширению фото
f_get_photo_mime_type() {
  local extension="$1"
  local lowercase_ext="${extension,,}"
  case "$lowercase_ext" in
  "${JPG_FILE_TYPE}" | "${JPEG_FILE_TYPE}") echo "$IMAGE_JPEG_MIME_TYPE" ;;
  "$PNG_FILE_TYPE") echo "$IMAGE_PNG_MIME_TYPE" ;;
  esac
}

##### функция определения mime type по расширению видео
f_get_video_mime_type() {
  local extension="$1"
  local lowercase_ext="${extension,,}"
  case "$lowercase_ext" in
  "$MOV_FILE_TYPE") echo "$VIDEO_MOV_MIME_TYPE" ;;
  "$MP4_FILE_TYPE") echo "$VIDEO_MP4_MIME_TYPE" ;;
  "$WEBM_FILE_TYPE") echo "$VIDEO_WEBM_MIME_TYPE" ;;
  esac
}

##### функция сопоставления номера move-инструкции, который передается при запуске теста, с названием согласно МР БП
f_map_instruction_id_to_name() {
  local id="$1"
  case "$id" in
  1) echo "$ACTIVE_LIVENESS_VIDEO_TURN_RIGHT_MOVE_TYPE" ;;
  2) echo "$ACTIVE_LIVENESS_VIDEO_TURN_LEFT_MOVE_TYPE" ;;
  3) echo "$ACTIVE_LIVENESS_VIDEO_TURN_UP_MOVE_TYPE" ;;
  4) echo "$ACTIVE_LIVENESS_VIDEO_TURN_DOWN_MOVE_TYPE" ;;
  5) echo "$ACTIVE_LIVENESS_VIDEO_SMILE_MOVE_TYPE" ;;
  6) echo "$ACTIVE_LIVENESS_VIDEO_BLINK_MOVE_TYPE" ;;
  7) echo "$ACTIVE_LIVENESS_VIDEO_DISTORTION_MOVE_TYPE" ;;
  8) echo "$ACTIVE_LIVENESS_VIDEO_RAISE_EYEBROW_MOVE_TYPE" ;;
  esac
}

##### реализация функции генерации датасета в режиме "multi file"
f_gen_multi_file_mode_dataset() {
  local should_gen_csv_dataset=true
  local dataset_state_cache csv_dataset

  # определяем датасет согласно контексту тестирования
  f_init_dataset_context

  # определяем текущее состояние датасета
  local sample_dir_mod_time current_dataset_state cached_dataset_state
  sample_dir_mod_time=$(date -r "$SAMPLE_DIR" +%s)
  current_dataset_state="${TYPE}${SEP_CHAR}${MNEMONIC}${SEP_CHAR}${INSTRUCTIONS}${SEP_CHAR}${SAMPLE_DIR}${SEP_CHAR}${sample_dir_mod_time}"

  # сравниваем состояния
  if [[ -s "$dataset_state_cache" ]]; then
    # парсим первую строку с предыдущим состоянием датасета
    read -r cached_dataset_state <"$dataset_state_cache"

    if [[ "$current_dataset_state" == "$cached_dataset_state" ]]; then
      should_gen_csv_dataset=false

      # парсим вторую строку с предыдущей статистикой датасета и выводим на консоль
      local cached_dataset_stats cached_total cached_sample_count cached_vector_count cached_json_count cached_unknown_count
      {
        read -r _
        read -r cached_dataset_stats
      } <"$dataset_state_cache"
      read -r cached_file_type_pattern cached_total cached_sample_count cached_vector_count cached_json_count cached_unknown_count <<<"$cached_dataset_stats"
      f_print_scan_results "$cached_file_type_pattern" "$cached_total" "$cached_sample_count" "$cached_vector_count" "$cached_json_count" "$cached_unknown_count"
      echo "Текущая директория с образцами и условия тестового сценария не менялись. Пропускаем генерацию csv-датасета."
      echo "$DIVIDING_LINE"
    fi
  fi

  if [[ "$should_gen_csv_dataset" == true ]]; then
    echo "Генерируем новый csv-датасет."

    # определяем паттерн для сканирования файлов, исходя из типа теста
    local file_type_pattern scan_result
    case "$TYPE" in
    "$SOUND_TEST_TYPE")
      file_type_pattern="$WAV_FILE_TYPE"
      ;;
    "$PHOTO_TEST_TYPE")
      file_type_pattern="${JPG_FILE_TYPE}|${JPEG_FILE_TYPE}|${PNG_FILE_TYPE}"
      ;;
    "$PASSIVE_LIVENESS_VIDEO_TEST_TYPE" | "$ACTIVE_LIVENESS_VIDEO_TEST_TYPE")
      file_type_pattern="${MOV_FILE_TYPE}|${MP4_FILE_TYPE}|${WEBM_FILE_TYPE}"
      ;;
    esac

    # сканируем датасет
    scan_result=$(find "$SAMPLE_DIR" -type f | awk \
      -v file_type_pattern="$file_type_pattern" \
      -v vector_type="$VECTOR_TYPE" \
      -v json_type="$JSON_TYPE" '
            BEGIN {
                total = 0; samples = 0; vectors = 0; jsons = 0
            }
            {
                total++
                low_path = tolower($0)
                if (low_path ~ "\\.(" file_type_pattern ")$") {
                    samples++
                    print $0
                }
                else if (low_path ~ "\\.(" vector_type ")$") vectors++
                else if (low_path ~ "\\.(" json_type ")$") jsons++
            }
            END {
                # требуется пробел, чтобы значения при выводе не слились
                print "ONLY_METRICS " total, samples, vectors, jsons
            }
    ')

    # если в результате сканирования не оказалось ни одного БО, которые соответствуют типу теста
    local sample_list
    sample_list=$(echo "$scan_result" | sed '/ONLY_METRICS/d')
    if [[ -z "$sample_list" ]]; then
      echo "Ошибка: в текущей директории отсутствуют биометрические образцы с расширением '${file_type_pattern}'" >&2
      exit "$EXIT_ERROR_CODE"
    fi

    # сохраняем кол-во по каждому типу файлов
    local file_stats total sample_count vector_count json_count unknown_count
    file_stats="${scan_result##*ONLY_METRICS}"
    read -r total sample_count vector_count json_count <<<"$file_stats"
    unknown_count=$((total - sample_count - vector_count - json_count))

    # наполняем файл датасета в соответствии с выбранным тестовым сценарием
    local sample sample_extension sample_mime_type metadata_path current_liveness_response_check_pattern
    if [[ "$CURRENT_FILE_PATH" =~ $LIVENESS_LOAD_TEST_ATTRIBUTE ]]; then
      if [[ "$TYPE" == "$SOUND_TEST_TYPE" ]]; then
        sample_mime_type="$AUDIO_WAV_MIME_TYPE"
        current_liveness_response_check_pattern="${LIVENESS_RESPONSE_CHECK_BASE_PATTERN/$DYNAMIC_PART/$PASSIVE_LIVENESS_SOUND_ACTION_TYPE}"
        echo "$DETECT_CSV_DATASET_HEADER" >"$csv_dataset"
        while read -r sample; do
          # проверяем, существует ли парная metadata
          metadata_path="${sample%.*}.${JSON_TYPE}"
          if [[ -s "$metadata_path" ]]; then
            echo "${sample}${SEP_CHAR}${sample_mime_type}${SEP_CHAR}${metadata_path}${SEP_CHAR}${current_liveness_response_check_pattern}" >>"$csv_dataset"
          else
            echo -e "${YELLOW_COLOR}Предупреждение${NO_COLOR}: для '${sample}' не найдена metadata → образец будет пропущен." >&2
          fi
        done <<<"$sample_list"

      elif [[ "$TYPE" == "$PHOTO_TEST_TYPE" ]]; then
        # для photo-type согласно МР БП 1.36 для всех образцов metadata одинаковая
        current_liveness_response_check_pattern="${LIVENESS_RESPONSE_CHECK_BASE_PATTERN/$DYNAMIC_PART/$PASSIVE_LIVENESS_PHOTO_ACTION_TYPE}"
        echo "$DETECT_CSV_DATASET_HEADER" >"$csv_dataset"
        while read -r sample; do
          sample_extension="${sample##*.}"
          sample_mime_type=$(f_get_photo_mime_type "$sample_extension")
          echo "${sample}${SEP_CHAR}${sample_mime_type}${SEP_CHAR}${SINGLE_PHOTO_FILE_MODE_METADATA}${SEP_CHAR}${current_liveness_response_check_pattern}" >>"$csv_dataset"
        done <<<"$sample_list"

      elif [[ "$TYPE" == "$PASSIVE_LIVENESS_VIDEO_TEST_TYPE" ]]; then
        # для video-type согласно МР БП 1.36 для всех образцов metadata одинаковая
        current_liveness_response_check_pattern="${LIVENESS_RESPONSE_CHECK_BASE_PATTERN/$DYNAMIC_PART/$PASSIVE_LIVENESS_VIDEO_ACTION_TYPE}"
        echo "$DETECT_CSV_DATASET_HEADER" >"$csv_dataset"
        while read -r sample; do
          sample_extension="${sample##*.}"
          sample_mime_type=$(f_get_video_mime_type "$sample_extension")
          echo "${sample}${SEP_CHAR}${sample_mime_type}${SEP_CHAR}${SINGLE_VIDEO_FILE_MODE_METADATA}${SEP_CHAR}${current_liveness_response_check_pattern}" >>"$csv_dataset"
        done <<<"$sample_list"

      elif [[ "$TYPE" == "$ACTIVE_LIVENESS_VIDEO_TEST_TYPE" ]]; then
        echo "$DETECT_CSV_DATASET_HEADER" >"$csv_dataset"
        if [[ "$MNEMONIC" == "$ACTIVE_LIVENESS_VIDEO_TEXT_MNEMONIC_ATTRIBUTE" ]]; then
          current_liveness_response_check_pattern="${LIVENESS_RESPONSE_CHECK_BASE_PATTERN/$DYNAMIC_PART/$ACTIVE_LIVENESS_VIDEO_TEXT_TYPE}"
          while read -r sample; do
            # проверяем, существует ли парная metadata
            metadata_path="${sample%.*}.${JSON_TYPE}"
            if [[ -s "$metadata_path" ]]; then
              sample_extension="${sample##*.}"
              sample_mime_type=$(f_get_video_mime_type "$sample_extension")
              echo "${sample}${SEP_CHAR}${sample_mime_type}${SEP_CHAR}${metadata_path}${SEP_CHAR}${current_liveness_response_check_pattern}" >>"$csv_dataset"
            else
              echo -e "${YELLOW_COLOR}Предупреждение${NO_COLOR}: для '${sample}' не найдена metadata → образец будет пропущен." >&2
            fi
          done <<<"$sample_list"
        elif [[ "$MNEMONIC" == "$ACTIVE_LIVENESS_VIDEO_MOVE_MNEMONIC_ATTRIBUTE" ]]; then
          # определяем паттерн для отбора в датасет тех образцов, которые соответствуют выбранным move-инструкциям
          local current_move_type_pattern parsed_instructions instruction_id
          local processed_instructions=()
          # если были выбраны все move-инструкции
          if [[ "$INSTRUCTIONS" == "$ACTIVE_LIVENESS_VIDEO_ALL_MOVE_INSTRUCTIONS_ARGUMENT" ]]; then
            current_move_type_pattern="$ACTIVE_LIVENESS_VIDEO_MOVE_TYPE_LIST_PATTERN"
          else
            # разбираем строку по запятым
            IFS=',' read -r -a parsed_instructions <<<"$INSTRUCTIONS"
            for instruction_id in "${parsed_instructions[@]}"; do
              processed_instructions+=("$(f_map_instruction_id_to_name "$instruction_id")")
            done
            current_move_type_pattern=$(
              IFS='|'
              echo "${processed_instructions[*]}"
            )
          fi

          while read -r sample; do
            # проверяем, существует ли парная metadata
            metadata_path="${sample%.*}.${JSON_TYPE}"
            if [[ -s "$metadata_path" ]]; then
              current_instruction=$(grep -E "$current_move_type_pattern" -o "$metadata_path")
              if [[ -z "$current_instruction" ]]; then
                echo -e "${YELLOW_COLOR}Предупреждение${NO_COLOR}: metadata для '${sample}' не содержит выбранные move-инструкции '${current_move_type_pattern}' → образец будет пропущен." >&2
                continue
              fi
              sample_extension="${sample##*.}"
              sample_mime_type=$(f_get_video_mime_type "$sample_extension")
              current_liveness_response_check_pattern="${LIVENESS_RESPONSE_CHECK_BASE_PATTERN/$DYNAMIC_PART/$current_instruction}"
              echo "${sample}${SEP_CHAR}${sample_mime_type}${SEP_CHAR}${metadata_path}${SEP_CHAR}${current_liveness_response_check_pattern}" >>"$csv_dataset"
            else
              echo -e "${YELLOW_COLOR}Предупреждение${NO_COLOR}: для '${sample}' не найдена metadata → образец будет пропущен." >&2
            fi
          done <<<"$sample_list"
        fi
      fi
    fi

    if [[ -z $(sed -n "${CSV_DATASET_TARGET_LINE}p" "$csv_dataset") ]]; then
      echo "Ошибка: не найдено ни одного биометрического образца с соответствующей metadata." >&2
      exit "$EXIT_ERROR_CODE"
    else
      # записываем обновленные данные в кеш и выводим статистику датасета
      echo "$current_dataset_state" >"$dataset_state_cache"
      echo "$file_type_pattern $total $sample_count $vector_count $json_count $unknown_count" >>"$dataset_state_cache"
      f_print_scan_results "$file_type_pattern" "$total" "$sample_count" "$vector_count" "$json_count" "$unknown_count"
      echo "$DIVIDING_LINE"
    fi
  fi
}
