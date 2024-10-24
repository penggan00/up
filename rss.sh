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
pip install requests html2text python-telegram-bot beautifulsoup4 langdetect markdownify mysql-connector-python pytz

# 创建 rss.py 文件（如果不存在）
if [ ! -f "rss.py" ]; then
    echo "创建 rss.py 文件..."
    touch rss.py
fi
# 创建 mail.py 文件（如果不存在）
if [ ! -f "mail.py" ]; then
    echo "创建 mail.py 文件..."
    touch mail.py
fi
# 创建 rss2.py 文件（如果不存在）
if [ ! -f "rss2.py" ]; then
    echo "创建 rss2.py 文件..."
    touch rss2.py
fi

# 创建 rss.sh 脚本
if [ ! -f "~/rss.sh" ]; then
    echo "创建 rss.sh 文件..."
    cat << 'EOF' > ~/rss.sh
#!/bin/bash

# 检查 rss.sh 是否在运行
if pgrep -f "rss.sh" > /dev/null; then
    echo "rss.sh is running. Stopping it..."
    # 停止 rss.sh 进程
    pkill -f "rss.sh"
else
    echo "rss.sh is not running."
fi
# 等待2秒
sleep 1
# 检查 mail.py 是否在运行
if pgrep -f "mail.py" > /dev/null; then
    echo "mail.py is running. Stopping it..."
    # 停止 mail.py 进程
    pkill -f "mail.py"
else
    echo "mail.py is not running."
fi
# 等待2秒
sleep 1
# 检查 rss.py 是否在运行
if pgrep -f "rss.py" > /dev/null; then
    echo "rss.py is running. Stopping it..."
    # 停止 rss.py 进程
    pkill -f "rss.py"
else
    echo "rss.py is not running."
fi
# 等待2秒
sleep 1
# 运行 RSS 脚本
source ~/rss/rss_venv/bin/activate
python3 ~/rss/rss.py
deactivate

sleep 1
# 运行 RSS 脚本
source ~/mail/mail_venv/bin/activate
python3 ~/mail/mail.py
deactivate
EOF
    chmod +x ~/rss.sh
fi

# 为 cron 添加任务
echo "添加 crontab 任务..."
(crontab -l 2>/dev/null; echo "30 * * * * ~/rss.sh") | crontab -

echo "项目设置完成！"
