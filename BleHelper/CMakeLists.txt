cmake_minimum_required(VERSION 3.20)

project(
  BleHelper
  VERSION ${MAJOR_VERSION}.${MINOR_VERSION}
  DESCRIPTION "BLE Helper"
  LANGUAGES CXX)

# 配置通用编译
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 导入Qt相关依赖包
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick)

# 获取当前构建时间
string(TIMESTAMP BUILD_DATE_TIME "%Y-%m-%d %H:%M:%S")
# 软件作者
set(AUTHOR "lucky9loogn")
# 源代码仓库地址
set(REPOSITORY_URL "https://github.com/lucky9loogn/BleHelper")
# 用于检查更新的网络地址
set(UPDATE_CHECK_URL
    "https://api.github.com/repos/lucky9loogn/BleHelper/releases/latest")
# 软件最新版本的下载地址
set(UPDATE_URL "https://github.com/lucky9loogn/BleHelper/releases/latest")

# 生成版本信息头文件
set(HEADER_FILE_VERSION_PATH
    ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}/src/common/BuildConfig.h)
configure_file(${CMAKE_SOURCE_DIR}/.cmake/BuildConfig.h.in
               ${HEADER_FILE_VERSION_PATH})

# 遍历所有cpp h hpp文件
set(SRC_DIR ${CMAKE_CURRENT_LIST_DIR}/src)
file(GLOB_RECURSE ALL_SOURCE_AND_HEADER_FILES ${SRC_DIR}/*.cpp ${SRC_DIR}/*.h
     ${SRC_DIR}/*.hpp)
foreach(filepath ${ALL_SOURCE_AND_HEADER_FILES})
  string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" filename ${filepath})
  list(APPEND project_sources ${filename})
endforeach(filepath)
message(STATUS "Source and Header Files: ${project_sources}")

# 如果是Windows平台，则生成rc文件，还有inno setup脚本文件
set(WINDOWS_RESOURCE_PATH "")
if(WIN32)
  set(WINDOWS_RESOURCE_PATH ${CMAKE_CURRENT_BINARY_DIR}/resource.rc)
  configure_file(${CMAKE_SOURCE_DIR}/.cmake/resource.rc.in
                 ${WINDOWS_RESOURCE_PATH})
  configure_file(${CMAKE_SOURCE_DIR}/.cmake/InstallerScript.iss.in
                 ${CMAKE_SOURCE_DIR}/package/InstallerScript.iss)
endif()

# 添加可执行文件
if(WIN32)
  list(APPEND project_sources ${WINDOWS_RESOURCE_PATH})
endif()

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
  qt_add_executable(${PROJECT_NAME} MANUAL_FINALIZATION ${project_sources})
else()
  add_executable(${PROJECT_NAME} ${project_sources})
endif()

# 遍历所有qml文件
set(QML_DIR ${CMAKE_CURRENT_LIST_DIR}/qml)
file(GLOB_RECURSE ALL_QML_FILES ${QML_DIR}/*.qml ${QML_DIR}/qmldir)
foreach(filepath ${ALL_QML_FILES})
  string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" filename ${filepath})
  list(APPEND project_qml_files ${filename})
endforeach(filepath)
message(STATUS "QML Files: ${project_qml_files}")

# 遍历所有资源文件
set(RESOURCES_DIR ${CMAKE_CURRENT_LIST_DIR}/resources)
file(
  GLOB_RECURSE
  ALL_RESOURCES_FILES
  ${RESOURCES_DIR}/*.png
  ${RESOURCES_DIR}/*.jpg
  ${RESOURCES_DIR}/*.svg
  ${RESOURCES_DIR}/*.ico
  ${RESOURCES_DIR}/*.ttf
  ${RESOURCES_DIR}/*.webp)
foreach(filepath ${ALL_RESOURCES_FILES})
  string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" filename ${filepath})
  list(APPEND project_resources ${filename})
endforeach(filepath)
message(STATUS "Resources Files: ${project_resources}")

# 添加资源文件
qt_add_resources(
  ${PROJECT_NAME}
  "${PROJECT_NAME}"
  PREFIX
  "/"
  FILES
  ${project_qml_files}
  ${project_resources})

# 指定包含目录的命令, 不然会报找不到头文件错误
target_include_directories(
  ${PROJECT_NAME}
  PRIVATE ${CMAKE_SOURCE_DIR}/FluentUI ${CMAKE_CURRENT_SOURCE_DIR}/src
          ${CMAKE_CURRENT_SOURCE_DIR}/src/common)

# 目标文件链接库
target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Gui Qt6::Quick
                                              fluentuiplugin)

if(${QT_VERSION} VERSION_LESS 6.1.0)
  set(BUNDLE_ID_OPTION MACOSX_BUNDLE_GUI_IDENTIFIER
                       com.${AUTHOR}.${PROJECT_NAME})
endif()
set_target_properties(
  ${PROJECT_NAME}
  PROPERTIES ${BUNDLE_ID_OPTION} MACOSX_BUNDLE_BUNDLE_VERSION
             ${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}
             MACOSX_BUNDLE_SHORT_VERSION_STRING
             ${MAJOR_VERSION}.${MINOR_VERSION} MACOSX_BUNDLE
             TRUE WIN32_EXECUTABLE
             TRUE)

include(GNUInstallDirs)
install(
  TARGETS ${PROJECT_NAME}
  BUNDLE DESTINATION .
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

if(QT_VERSION_MAJOR EQUAL 6)
  qt_import_qml_plugins(${PROJECT_NAME})
  qt_finalize_executable(${PROJECT_NAME})
endif()

# 添加国际化脚本
find_program(QT_LUPDATE NAMES lupdate)
find_program(QT_LRELEASE NAMES lrelease)

set(TRANSLATIONS_DIR ${CMAKE_CURRENT_LIST_DIR}/resources/translations
)# 定义翻译文件路径变量
set(TRANSLATIONS_CONFIG_FILE ${TRANSLATIONS_DIR}/languages.json) # 定义语言映射JSON文件
file(GLOB ALL_TS_FILES ${TRANSLATIONS_DIR}/*.ts)
set(ALL_QM_FILES "")
foreach(ts_file IN LISTS ALL_TS_FILES)
  string(REPLACE ".ts" ".qm" qm_file ${ts_file})
  list(APPEND ALL_QM_FILES ${qm_file})
endforeach()
message(STATUS "All ts Files: ${ALL_TS_FILES}")

add_custom_target(
  Script-UpdateTranslations
  COMMAND ${QT_LUPDATE} ${CMAKE_CURRENT_LIST_DIR} -ts ${ALL_TS_FILES}
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
  COMMAND ${QT_LRELEASE} ${ALL_TS_FILES}
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/i18n
  COMMAND ${CMAKE_COMMAND} -E copy ${ALL_QM_FILES}
          ${CMAKE_CURRENT_BINARY_DIR}/i18n
  COMMAND ${CMAKE_COMMAND} -E copy ${TRANSLATIONS_CONFIG_FILE}
          ${CMAKE_CURRENT_BINARY_DIR}/i18n
  SOURCES ${ALL_TS_FILES})

add_dependencies(${PROJECT_NAME} Script-UpdateTranslations)

# 添加部署脚本
if(CMAKE_BUILD_TYPE MATCHES "Release")
  if(WIN32)
    find_program(QT_DEPLOY_QT NAMES windeployqt)
    add_custom_target(
      Script-DeployRelease
      COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_SOURCE_DIR}/dist
      COMMAND ${CMAKE_COMMAND} -E copy_directory
              ${CMAKE_CURRENT_BINARY_DIR}/i18n ${CMAKE_SOURCE_DIR}/dist/i18n
      COMMAND
        ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.exe
        ${CMAKE_SOURCE_DIR}/dist
      COMMAND
        ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.exe.manifest
        ${CMAKE_SOURCE_DIR}/dist
      COMMAND
        ${QT_DEPLOY_QT} --qmldir=${CMAKE_CURRENT_LIST_DIR} --plugindir
        ${CMAKE_SOURCE_DIR}/dist/plugins --no-translations --compiler-runtime
        ${CMAKE_SOURCE_DIR}/dist/${PROJECT_NAME}.exe
      COMMENT "Windows Deploying Qt Dependencies After Build........."
      SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  endif()
endif()
