#!/usr/bin/env fish

# --- 配置区 ---

# 1. 设置输出文件的名称
set output_file "project_snapshot.txt"

# 2. 默认忽略的目录列表 (文件夹名称)
#    这些目录下的所有内容都将被跳过。
set ignored_dirs \
    .git \
    .vscode \
    .idea \
    node_modules \
    target \
    build \
    dist \
    __pycache__

# 3. 默认忽略的文件列表 (完整文件名或通配符)
set ignored_files \
    *.log \
    *.swp \
    *.bak \
    "$output_file" # 确保不把输出文件自己也包含进去

# --- 脚本主体 ---

echo "🚀 开始生成项目快照..."

# 准备 find 命令的忽略参数
set find_ignore_params
for dir in $ignored_dirs
    # -prune 会阻止 find 进入该目录，效率很高
    set -a find_ignore_params -name "$dir" -prune -o
end
for file in $ignored_files
    set -a find_ignore_params -name "$file" -prune -o
end

# 清空或创建输出文件，并准备开始写入
# ">" 会覆盖旧文件
echo "# 这是一个由脚本在 (date) 生成的项目快照" > $output_file
echo "----------------------------------------------------" >> $output_file
echo "" >> $output_file

# 使用 find 命令查找所有符合条件的文件
# (string join ' ' $find_ignore_params) 会把忽略参数列表转换成 find 能识别的格式
# -type f: 只选择文件
# -print: 打印文件路径
set file_list (eval "find . $find_ignore_params -type f -print")

# 检查是否找到了文件
if test (count $file_list) -eq 0
    echo "⚠️ 在当前目录中没有找到任何符合条件的文件。"
    exit 0
end

echo "🔍 找到了 (count $file_list) 个文件。正在处理..."

# 循环处理每个找到的文件
for file in $file_list
    # 过滤掉二进制文件
    set mime_type (file -b --mime-type "$file")
    if string match -q "text/*" "$mime_type"
        # 是文本文件，处理它

        # 1. 在输出文件中写入文件路径标题头
        echo "--- START OF FILE: $file ---" >> $output_file
        echo "" >> $output_file # 加个空行

        # 2. 将文件内容追加到输出文件中
        cat "$file" >> $output_file

        # 3. 在文件内容后写入结束标记和分隔符
        echo "" >> $output_file # 加个空行
        echo "--- END OF FILE: $file ---" >> $output_file
        echo -e "\n\n" >> $output_file # 用两个换行符分隔不同的文件

        echo "  - 已处理: $file"
    else
        # 是二进制文件，跳过
        echo "  - (二进制文件，已忽略): $file"
    end
end

echo "✅ 完成！所有文本文件内容已合并到 '$output_file' 文件中。"
