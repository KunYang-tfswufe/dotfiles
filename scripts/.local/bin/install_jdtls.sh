#!/bin/bash

# 1. 确保目录存在
mkdir -p ~/.local/share/jdtls
mkdir -p ~/.local/bin
mkdir -p ~/.cache/jdtls-workspace

# 2. 检查 JDK 21 (Fedora 路径)
JAVA_21="/usr/lib/jvm/java-21-openjdk/bin/java"
if [ ! -f "$JAVA_21" ]; then
    # 如果找不到硬编码路径，尝试直接用系统 java
    JAVA_21=$(which java)
fi

# 3. 下载/更新 JDTLS
echo "正在获取 JDTLS 最新快照..."
LATEST_URL=$(curl -s https://download.eclipse.org/jdtls/snapshots/latest.txt | head -n 1)
curl -L "https://download.eclipse.org/jdtls/snapshots/$LATEST_URL" -o /tmp/jdtls.tar.gz

echo "正在解压..."
# 先清理旧的，防止 find 找到多个 jar 包导致冲突
rm -rf ~/.local/share/jdtls/*
tar -xf /tmp/jdtls.tar.gz -C ~/.local/share/jdtls

# 关键修复点：在生成脚本前，先在当前 shell 环境下确认 jar 包路径
LAUNCHER_JAR=$(find $HOME/.local/share/jdtls/plugins/ -name "org.eclipse.equinox.launcher_*.jar" | head -n 1)

if [ -z "$LAUNCHER_JAR" ]; then
    echo "❌ 错误：未能找到 launcher jar 包，请检查解压是否成功。"
    exit 1
fi

# 4. 生成启动脚本 (使用绝对路径，减少运行时解析出错)
cat <<EOF > ~/.local/bin/jdtls
#!/bin/bash

# 运行时的配置和数据目录
CONFIG="\$HOME/.local/share/jdtls/config_linux"
DATA="\$HOME/.cache/jdtls-workspace/\$(basename "\$PWD")"

$JAVA_21 \\
    -Declipse.application=org.eclipse.jdt.ls.core.id1 \\
    -Dosgi.bundles.defaultStartLevel=4 \\
    -Declipse.product=org.eclipse.jdt.ls.core.product \\
    -Dlog.level=ALL \\
    -Xmx2G \\
    --add-modules=ALL-SYSTEM \\
    --add-opens java.base/java.util=ALL-UNNAMED \\
    --add-opens java.base/java.lang=ALL-UNNAMED \\
    -jar "$LAUNCHER_JAR" \\
    -configuration "\$CONFIG" \\
    -data "\$DATA"
EOF

chmod +x ~/.local/bin/jdtls
echo "✅ 修复完成！Launcher 指向: $LAUNCHER_JAR"
