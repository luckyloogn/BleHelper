# 设置默认值
set(DEFAULT_GIT_COMMIT_HASH "none")
set(DEFAULT_GIT_COMMIT_COUNT 0)
set(DEFAULT_GIT_BRANCH "none")
set(DEFAULT_GIT_TAG "1.0.0")

# 查找 Git
find_package(Git QUIET)

if(GIT_FOUND)
  # 检查是否为 Git 仓库
  execute_process(
    COMMAND git rev-parse --is-inside-work-tree
    RESULT_VARIABLE GIT_REPO_CHECK
    ERROR_QUIET)

  if(GIT_REPO_CHECK EQUAL 0)
    # 获取当前 Git 提交的哈希值
    execute_process(
      COMMAND git rev-parse --short HEAD
      OUTPUT_VARIABLE GIT_CURRENT_HEAD_COMMIT_HASH
      RESULT_VARIABLE GIT_COMMIT_HASH_CHECK
      ERROR_QUIET)

    if(NOT GIT_COMMIT_HASH_CHECK EQUAL 0)
      set(GIT_CURRENT_HEAD_COMMIT_HASH ${DEFAULT_GIT_COMMIT_HASH})
    endif()

    # 获取版本计数（提交次数）
    execute_process(
      COMMAND git rev-list --count HEAD
      OUTPUT_VARIABLE GIT_CURRENT_HEAD_COMMIT_COUNT
      RESULT_VARIABLE GIT_COMMIT_COUNT_CHECK
      ERROR_QUIET)

    if(NOT GIT_COMMIT_COUNT_CHECK EQUAL 0)
      set(GIT_CURRENT_HEAD_COMMIT_COUNT ${DEFAULT_GIT_COMMIT_COUNT})
    endif()

    # 获取当前分支名称
    execute_process(
      COMMAND git rev-parse --abbrev-ref HEAD
      OUTPUT_VARIABLE GIT_CURRENT_BRANCH
      RESULT_VARIABLE GIT_BRANCH_CHECK
      ERROR_QUIET)

    if(NOT GIT_BRANCH_CHECK EQUAL 0)
      set(GIT_CURRENT_BRANCH ${DEFAULT_GIT_BRANCH})
    endif()

    # 获取最新标签
    execute_process(
      COMMAND git describe --tags --abbrev=0
      OUTPUT_VARIABLE GIT_LATEST_TAG
      RESULT_VARIABLE GIT_TAG_CHECK
      ERROR_QUIET)

    if(NOT GIT_TAG_CHECK EQUAL 0)
      set(GIT_LATEST_TAG ${DEFAULT_GIT_TAG})
    endif()
  else()
    message(STATUS "Current workspace is not a git repository.")
    set(GIT_CURRENT_HEAD_COMMIT_HASH ${DEFAULT_GIT_COMMIT_HASH})
    set(GIT_CURRENT_HEAD_COMMIT_COUNT ${DEFAULT_GIT_COMMIT_COUNT})
    set(GIT_CURRENT_BRANCH ${DEFAULT_GIT_BRANCH})
    set(GIT_LATEST_TAG ${DEFAULT_GIT_TAG})
  endif()
else()
  message(STATUS "Git is not available.")
  set(GIT_CURRENT_HEAD_COMMIT_HASH ${DEFAULT_GIT_COMMIT_HASH})
  set(GIT_CURRENT_HEAD_COMMIT_COUNT ${DEFAULT_GIT_COMMIT_COUNT})
  set(GIT_CURRENT_BRANCH ${DEFAULT_GIT_BRANCH})
  set(GIT_LATEST_TAG ${DEFAULT_GIT_TAG})
endif()

# 确保没有换行符
string(STRIP "${GIT_CURRENT_HEAD_COMMIT_HASH}" GIT_CURRENT_HEAD_COMMIT_HASH)
string(STRIP "${GIT_CURRENT_HEAD_COMMIT_COUNT}" GIT_CURRENT_HEAD_COMMIT_COUNT)
string(STRIP "${GIT_CURRENT_BRANCH}" GIT_CURRENT_BRANCH)
string(STRIP "${GIT_LATEST_TAG}" GIT_LATEST_TAG)

# 使用正则表达式提取版本号的各个部分
string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" VERSION_SPLITED
             "${GIT_LATEST_TAG}")

# 设置每个版本号部分
set(MAJOR_VERSION ${CMAKE_MATCH_1})
set(MINOR_VERSION ${CMAKE_MATCH_2})
set(PATCH_VERSION ${CMAKE_MATCH_3})

# 确保没有换行符
string(STRIP "${MAJOR_VERSION}" MAJOR_VERSION)
string(STRIP "${MINOR_VERSION}" MINOR_VERSION)
string(STRIP "${PATCH_VERSION}" PATCH_VERSION)

# 输出结果
message(STATUS "Latest major version: ${MAJOR_VERSION}")
message(STATUS "Latest minor version: ${MINOR_VERSION}")
message(STATUS "Latest patch version: ${PATCH_VERSION}")
message(STATUS "Current head commit count: ${GIT_CURRENT_HEAD_COMMIT_COUNT}")
message(STATUS "Current head commit hash: ${GIT_CURRENT_HEAD_COMMIT_HASH}")
message(STATUS "Current branch: ${GIT_CURRENT_BRANCH}")
message(STATUS "Latest tag: ${GIT_LATEST_TAG}")
