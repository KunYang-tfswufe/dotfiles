#!/bin/bash

# 1. 确保目录存在
mkdir -p ~/.local/share/jdtls
mkdir -p ~/.local/bin
mkdir -p ~/.cache/jdtls-workspace

# 2. 检查 JDK 21 (Fedora 路径)
JAVA_21="/usr/lib/jvm/java-21-openjdk/bin/java"
if [ ! -f "$JAVA_21" ]; then
    echo "错误: 未找到 JDK 21，请运行: sudo dnf install java-21-openjdk-devel"
    exit 1
fi

# 3. 下载/更新 JDTLS
echo "正在获取 JDTLS 最新快照..."
LATEST_URL=$(curl -s https://download.eclipse.org/jdtls/snapshots/latest.txt | head -n 1)
echo "下载地址: $LATEST_URL"

curl -L "https://download.eclipse.org/jdtls/snapshots/$LATEST_URL" -o /tmp/jdtls.tar.gz
rm -rf ~/.local/share/jdtls/*
tar -xf /tmp/jdtls.tar.gz -C ~/.local/share/jdtls

# 4. 生成启动脚本
cat <<EOF > ~/.local/bin/jdtls
#!/bin/bash

# 自动定位 Jar 包
LAUNCHER=\$(find \$HOME/.local/share/jdtls/plugins/ -name "org.eclipse.equinox.launcher_*.jar" | head -n 1)
CONFIG="\$HOME/.local/share/jdtls/config_linux"

# 为每个项目创建独立的 Workspace，并清理可能的旧锁
WS_HASH=\$(echo "\$PWD" | md5sum | cut -d' ' -f1)
DATA="\$HOME/.cache/jdtls-workspace/\$WS_HASH"
mkdir -p "\$DATA"

# 启动 Java
$JAVA_21 \\
    -Declipse.application=org.eclipse.jdt.ls.core.id1 \\
    -Dosgi.bundles.defaultStartLevel=4 \\
    -Declipse.product=org.eclipse.jdt.ls.core.product \\
    -Dlog.level=ALL \\
    -noverify \\
    -Xmx2G \\
    -XX:+UseG1GC \\
    -XX:+UseStringDeduplication \\
    --add-modules=ALL-SYSTEM \\
    --add-opens java.base/java.util=ALL-UNNAMED \\
    --add-opens java.base/java.lang=ALL-UNNAMED \\
    -jar "\$LAUNCHER" \\
    -configuration "\$CONFIG" \\
    -data "\$DATA"
EOF

chmod +x ~/.local/bin/jdtls
echo "✅ 安装成功！请重启 Helix 并尝试打开 Java 文件。"
