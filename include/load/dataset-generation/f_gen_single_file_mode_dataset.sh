#!/bin/bash

# ================================================================================
# DESC:    функция генерации датасета в режиме "single file"
# VERSION: 1.0.0
# ================================================================================

f_gen_single_file_mode_dataset() {
  if [[ "$CURRENT_FILE_PATH" =~ $LIVENESS_LOAD_TEST_ATTRIBUTE ]]; then
    local current_sample current_sample_mime_type current_metadata_path current_liveness_response_check_pattern
    case "$TYPE" in
    "$SOUND_TEST_TYPE")
      current_sample="$SINGLE_SOUND_FILE_MODE_SAMPLE"
      current_sample_mime_type="$AUDIO_WAV_MIME_TYPE"
      current_metadata_path="$SINGLE_SOUND_FILE_MODE_METADATA"
      current_liveness_response_check_pattern="${LIVENESS_RESPONSE_CHECK_BASE_PATTERN/$DYNAMIC_PART/$PASSIVE_LIVENESS_SOUND_ACTION_TYPE}"
      ;;
    "$PHOTO_TEST_TYPE")
      current_sample="$SINGLE_PHOTO_FILE_MODE_SAMPLE"
      current_sample_mime_type="$IMAGE_JPEG_MIME_TYPE"
      current_metadata_path="$SINGLE_PHOTO_FILE_MODE_METADATA"
      current_liveness_response_check_pattern="${LIVENESS_RESPONSE_CHECK_BASE_PATTERN/$DYNAMIC_PART/$PASSIVE_LIVENESS_PHOTO_ACTION_TYPE}"
      ;;
    "$PASSIVE_LIVENESS_VIDEO_TEST_TYPE")
      current_sample="$SINGLE_VIDEO_FILE_MODE_SAMPLE"
      current_sample_mime_type="$VIDEO_MOV_MIME_TYPE"
      current_metadata_path="$SINGLE_VIDEO_FILE_MODE_METADATA"
      current_liveness_response_check_pattern="${LIVENESS_RESPONSE_CHECK_BASE_PATTERN/$DYNAMIC_PART/$PASSIVE_LIVENESS_VIDEO_ACTION_TYPE}"
      ;;
    esac
    echo "$DETECT_CSV_DATASET_HEADER" >"$DETECT_CSV_DATASET"
    echo "${current_sample}${SEP_CHAR}${current_sample_mime_type}${SEP_CHAR}${current_metadata_path}${SEP_CHAR}${current_liveness_response_check_pattern}" >>"$DETECT_CSV_DATASET"
    : >"$DETECT_DATASET_STATE_CACHE"
  fi
}
