#!/bin/bash

echo "📡 自动同步模式已启动：每 5 秒检查一次远程更新..."

while true; do
  #先 fetch 获取远程状态，不合并
  git fetch origin main > /dev/null 2>&1
  
  # 比较本地和远程的 hash，只有不同的时候才执行 pull
  LOCAL=$(git rev-parse HEAD)
  REMOTE=$(git rev-parse origin/main)

  if [ "$LOCAL" != "$REMOTE" ]; then
    echo "⬇️  [$(date +'%H:%M:%S')] 发现更新，正在拉取..."
    
    # 拉取并变基
    if git pull --rebase origin main; then
        echo "✅ 代码已同步到最新。"
        
        # 可选：如果你希望在这里自动触发 Maven 编译或者其他钩子
        # ./mvnw compile 
    else
        echo "❌ 拉取失败，请检查冲突。"
    fi
  fi
  
  sleep 5
done
