#!/bin/bash

# 1. 确保目录结构存在
mkdir -p ~/.local/share/jdtls
mkdir -p ~/.local/bin
mkdir -p ~/.cache/jdtls-workspace

# 2. 自动匹配 Fedora 的 JDK 21 路径
JAVA_21="/usr/lib/jvm/java-21-openjdk/bin/java"
if [ ! -f "$JAVA_21" ]; then
    JAVA_21=$(which java)
    echo "警告: 未找到 JDK 21 硬编码路径，回退到系统默认: $JAVA_21"
fi

# 3. 获取并下载 JDTLS 最新快照
echo "Step 1/2: 正在更新 JDTLS..."
LATEST_URL=$(curl -s https://download.eclipse.org/jdtls/snapshots/latest.txt | head -n 1)
DOWNLOAD_URL="https://download.eclipse.org/jdtls/snapshots/$LATEST_URL"

# 下载 JDTLS
curl -L "$DOWNLOAD_URL" -o /tmp/jdtls.tar.gz
rm -rf ~/.local/share/jdtls/*
tar -xf /tmp/jdtls.tar.gz -C ~/.local/share/jdtls

# --- [新增] 下载 Lombok ---
echo "Step 2/2: 正在下载 Lombok..."
LOMBOK_URL="https://projectlombok.org/downloads/lombok.jar"
curl -L "$LOMBOK_URL" -o ~/.local/share/jdtls/lombok.jar
# ------------------------

# 4. 预先定位 Launcher Jar 包
LAUNCHER_JAR=$(find $HOME/.local/share/jdtls/plugins/ -name "org.eclipse.equinox.launcher_*.jar" | head -n 1)

if [ -z "$LAUNCHER_JAR" ]; then
    echo "❌ 错误：未能找到 jdtls jar 文件，请检查网络或解压权限。"
    exit 1
fi

# 5. 生成最终的启动脚本
# 注意：在 exec 下面增加了 -javaagent 参数
cat <<EOF > ~/.local/bin/jdtls
#!/bin/bash

# 设置配置目录和工作区缓存
CONFIG="\$HOME/.local/share/jdtls/config_linux"
WS_HASH=\$(echo "\$PWD" | md5sum | cut -d' ' -f1)
DATA="\$HOME/.cache/jdtls-workspace/\$WS_HASH"
LOMBOK="\$HOME/.local/share/jdtls/lombok.jar"

mkdir -p "\$DATA"

exec $JAVA_21 \\
    -Declipse.application=org.eclipse.jdt.ls.core.id1 \\
    -Dosgi.bundles.defaultStartLevel=4 \\
    -Declipse.product=org.eclipse.jdt.ls.core.product \\
    -Dlog.level=ALL \\
    -Xmx2G \\
    -XX:+UseG1GC \\
    -XX:+UseStringDeduplication \\
    -javaagent:"\$LOMBOK" \\
    --add-modules=ALL-SYSTEM \\
    --add-opens java.base/java.util=ALL-UNNAMED \\
    --add-opens java.base/java.lang=ALL-UNNAMED \\
    -jar "$LAUNCHER_JAR" \\
    -configuration "\$CONFIG" \\
    -data "\$DATA" \\
    2>/dev/null
EOF

chmod +x ~/.local/bin/jdtls

echo "------------------------------------------------"
echo "✅ JDTLS 配置成功 (含 Lombok 支持)！"
echo "🔹 Lombok 路径: ~/.local/share/jdtls/lombok.jar"
echo "🔹 启动指令: ~/.local/bin/jdtls"
echo "------------------------------------------------"
