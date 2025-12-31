#!/bin/bash

# 1. 创建目录
mkdir -p ~/.local/share/jdtls
mkdir -p ~/.local/bin
mkdir -p ~/.cache/jdtls-workspace

# 2. 下载最新的 JDTLS
echo "正在获取 JDTLS 最新下载链接..."
LATEST_URL=$(curl -s https://download.eclipse.org/jdtls/snapshots/latest.txt | head -n 1)
FULL_URL="https://download.eclipse.org/jdtls/snapshots/$LATEST_URL"

echo "正在下载 JDTLS..."
curl -L "$FULL_URL" -o /tmp/jdtls.tar.gz

echo "正在解压..."
tar -xf /tmp/jdtls.tar.gz -C ~/.local/share/jdtls

# 3. 创建可执行启动脚本
# 这里使用了 heredoc，确保路径正确
cat <<EOF > ~/.local/bin/jdtls
#!/bin/bash
JAR=\$(find ~/.local/share/jdtls/plugins/ -name "org.eclipse.equinox.launcher_*.jar" | head -n 1)
CONFIG="~/.local/share/jdtls/config_linux"
DATA="\$HOME/.cache/jdtls-workspace/\$(basename "\$PWD")"

java \\
    -Declipse.application=org.eclipse.jdt.ls.core.id1 \\
    -Dosgi.bundles.defaultStartLevel=4 \\
    -Declipse.product=org.eclipse.jdt.ls.core.product \\
    -Dlog.level=ALL \\
    -Xmx1G \\
    --add-modules=ALL-SYSTEM \\
    --add-opens java.base/java.util=ALL-UNNAMED \\
    --add-opens java.base/java.lang=ALL-UNNAMED \\
    -jar "\$JAR" \\
    -configuration "\$CONFIG" \\
    -data "\$DATA"
EOF

chmod +x ~/.local/bin/jdtls

echo "安装完成！请确保 ~/.local/bin 在你的 PATH 环境变量中。"
