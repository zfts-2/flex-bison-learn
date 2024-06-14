cmake_minimum_required(VERSION 3.10)
project(lab03)
set(CMAKE_CXX_STANDARD 14)
# 为了 flex 新增头文件搜索路径
include_directories(${CMAKE_SOURCE_DIR})


include(FindBISON)
include(FindFLEX)


BISON_TARGET(parser parser.y    ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp
	DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/parser.tab.h
	)





# 指定 flex 编译目标
FLEX_TARGET(MyScanner scanner.l ${CMAKE_CURRENT_BINARY_DIR}/lexer.cpp)


add_compile_options(-pedantic)

add_executable(Compilerlab4
	parser.cpp
	lexer.cpp)
target_compile_features(Compilerlab4 PRIVATE cxx_std_14)
