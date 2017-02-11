#!/bin/sh

# 定义环境变量
PROJ_SCRIPTS_PATH=${PROJECT_DIR}/Share/Script
DSYM_SRC_PATH=${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}
DSYM_DES_FOLDER=${PROJ_SCRIPTS_PATH}/dSYM
DSYM_NAME=${EXECUTABLE_NAME}.$(date +%Y%m%d%H%M%S).app.dSYM
LOG_FILE_PATH=${PROJ_SCRIPTS_PATH}/log.txt

logToFile()
{
    str=$1
    echo "[$(date +%Y%m%d%H%M%S)] ${str}" >> ${LOG_FILE_PATH}
}

# 如果 log 文件不存在，先创建
if [ ! -f "${LOG_FILE_PATH}" ]; then
    touch ${LOG_FILE_PATH}
fi
echo "auto_save_dSYM LOG" >| ${LOG_FILE_PATH}

# 如果是 Debug 模式直接返回
if [ "$CONFIGURATION" == "Debug" ]; then
    `logToFile "Skipping debug"`
    exit 0;
fi

# 如果是模拟器直接返回
if [ "$PLATFORM_NAME" == "iphonesimulator" ]; then
    `logToFile "Skipping simulator build"`
    exit 0;
fi

# 查看当前所有环境变量
`logToFile "==== env START ===="`
env >> ${LOG_FILE_PATH}
`logToFile "==== env END ===="`

# 如果 dSYM 目录不存在就要创建该目录
`logToFile "mkdir ${DSYM_DES_FOLDER}"`
if [ ! -d "${DSYM_DES_FOLDER}" ]; then
    mkdir "${DSYM_DES_FOLDER}"
fi

# cp dSYM files
`logToFile "cp ${DSYM_SRC_PATH} to ${DSYM_DES_FOLDER}/${DSYM_NAME}"`
cp -r "${DSYM_SRC_PATH}" "${DSYM_DES_FOLDER}/${DSYM_NAME}"
