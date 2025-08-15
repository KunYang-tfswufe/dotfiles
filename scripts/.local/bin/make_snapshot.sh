#!/usr/bin/env bash

# --- 配置区 ---

# 1. 设置输出文件的名称
output_file="project_snapshot.txt"

# 2. 默认忽略的目录列表 (文件夹名称)
#    这些目录下的所有内容都将被跳过。
ignored_dirs=(
    .git
    .vscode
    .idea
    .obsidian
    .metadata
    node_modules
    target
    build
    dist
    __pycache__
)

# 3. 默认忽略的文件列表 (完整文件名或通配符)
ignored_files=(
    "*.log"
    "*.swp"
    "*.bak"
    "$output_file" # 确保不把输出文件自己也包含进去
)

# --- 脚本主体 ---

echo "🚀 开始生成项目快照..."

# 准备 find 命令的忽略参数
find_ignore_params=()
for dir in "${ignored_dirs[@]}"; do
    # -prune 会阻止 find 进入该目录，效率很高
    find_ignore_params+=(-name "$dir" -prune -o)
done
for file in "${ignored_files[@]}"; do
    find_ignore_params+=(-name "$file" -prune -o)
done

# 清空或创建输出文件，并准备开始写入
# ">" 会覆盖旧文件
echo "# 这是一个由脚本在 $(date) 生成的项目快照" > "$output_file"
echo "----------------------------------------------------" >> "$output_file"
echo "" >> "$output_file"

# 使用 find 命令查找所有符合条件的文件
# -type f: 只选择文件
# -print0: 使用 null 字符分隔文件名，以安全处理包含空格等特殊字符的文件名
file_list=()
while IFS= read -r -d $'\0' file; do
    file_list+=("$file")
done < <(find . "${find_ignore_params[@]}" -type f -print0)


# 检查是否找到了文件
if [ ${#file_list[@]} -eq 0 ]; then
    echo "⚠️ 在当前目录中没有找到任何符合条件的文件。"
    exit 0
fi

echo "🔍 找到了 ${#file_list[@]} 个文件。正在处理..."

# 循环处理每个找到的文件
for file in "${file_list[@]}"; do
    # 过滤掉二进制文件
    mime_type=$(file -b --mime-type "$file")
    if [[ "$mime_type" == "text/"* || "$mime_type" == "application/json" || "$mime_type" == "application/xml" || "$mime_type" == "application/javascript" ]]; then
        # 是文本文件，处理它

        # 1. 在输出文件中写入文件路径标题头
        echo "--- START OF FILE: $file ---" >> "$output_file"
        echo "" >> "$output_file" # 加个空行

        # 2. 将文件内容追加到输出文件中
        cat "$file" >> "$output_file"

        # 3. 在文件内容后写入结束标记和分隔符
        echo "" >> "$output_file" # 加个空行
        echo "--- END OF FILE: $file ---" >> "$output_file"
        echo -e "\n\n" >> "$output_file" # 用两个换行符分隔不同的文件

        echo "  - 已处理: $file"
    else
        # 是二进制文件，跳过
        echo "  - (二进制文件，已忽略): $file"
    fi
done

echo "✅ 完成！所有文本文件内容已合并到 '$output_file' 文件中。"
