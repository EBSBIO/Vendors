#!/bin/bash

# ================================================================================
# DESC:    верхнеуровневая функция генерации датасета
# VERSION: 1.0.0
# ================================================================================

##### настройки среды и глобальные параметры
source include/load/dataset-generation/f_gen_single_file_mode_dataset.sh
source include/load/dataset-generation/f_gen_multi_file_mode_dataset.sh

##### реализация функции генерации датасета
f_gen_dataset() {
  if [[ -n "$SAMPLE_DIR" ]]; then
    f_gen_multi_file_mode_dataset
  else
    f_gen_single_file_mode_dataset
  fi
}
