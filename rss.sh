#!/bin/bash

# 设置脚本在遇到错误时停止执行
set -e

# 创建目录 rss（如果不存在）
if [ ! -d "rss" ]; then
    echo "创建 rss 目录..."
    mkdir rss
fi

# 进入 rss 目录
cd rss

# 创建虚拟环境（如果不存在）
if [ ! -d "rss_venv" ]; then
    echo "创建虚拟环境 rss_venv..."
    python3 -m venv rss_venv
fi

# 激活虚拟环境
echo "激活虚拟环境..."
source rss_venv/bin/activate

# 安装必要的库
echo "安装必要的库..."
pip install --upgrade pip
pip install aiohttp aiomysql feedparser python-dotenv python-telegram-bot

# 创建 rss.py 文件（如果不存在）
if [ ! -f "rss.py" ]; then
    echo "创建 rss.py 文件..."
    touch rss.py
fi

echo "项目设置完成！"
