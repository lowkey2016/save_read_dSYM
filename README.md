# save_read_dSYM

在 App Target -> Build Phases -> Run Script 中指定 auto_save_dSYM.sh 的路径，就可以在 App Release 模式时（如 Archive）自动保存生成的 dSYM 文件到脚本中指定的路径。

read_dSYM.sh 可以解析 App 的崩溃信息到具体的文件和代码行数，注意 ipa, dSYM, crash 等必须一一对应。
