#!/bin/bash

# 设置脚本在遇到错误时停止执行
set -e

# 创建 gpt 目录（如果不存在）
if [ ! -d "gpt" ]; then
    echo "创建 gpt 目录..."
    mkdir ~/gpt
fi

# 进入 gpt 目录
cd ~/gpt

# 初始化 npm 项目
echo "初始化 npm 项目..."
npm init -y

# 安装依赖包
echo "安装 telegraf 和 tencentcloud-sdk-nodejs..."
npm install dotenv axios telegraf log4js

# 安装 dotenv 以管理环境变量
echo "安装 dotenv..."
npm install dotenv

# 创建 gpt.js 文件（如果不存在）
if [ ! -f "gpt.js" ]; then
    echo "创建 gpt.js 文件..."
    cat << 'EOF' > gpt.js
// gpt.js
require('dotenv').config();
const { Telegraf } = require('telegraf');

// 替换为你的 Telegram Bot Token
const bot = new Telegraf(process.env.BOT_TOKEN);

bot.start((ctx) => ctx.reply('欢迎使用翻译机器人！'));
bot.on('text', async (ctx) => {
    const text = ctx.message.text;
    // 此处可以调用腾讯云 SDK 进行翻译逻辑
    ctx.reply(`你输入了: ${text}`);
});

bot.launch();
console.log('Bot 已启动...');
EOF
fi

# 创建 gpt.sh 文件，用于定时任务调用
if [ ! -f "~/gpt.sh" ]; then
    echo "创建 gpt.sh 文件..."
    cat << 'EOF' > ~/gpt.sh
#!/bin/bash

# 检查 gpt.sh 是否在运行
if pgrep -f "gpt.sh" > /dev/null; then
    echo "gpt.sh is running. Stopping it..."
    # 停止 gpt.sh 进程
    pkill -f "gpt.sh"
else
    echo "gpt.sh is not running."
fi
# 等待1秒
sleep 1
# 检查是否有 gpt.js 进程
if pgrep -f "gpt.js" > /dev/null
then
    echo "gpt.js 进程已在运行，脚本退出。"
    exit 0
else
    echo "未检测到 gpt.js 进程，启动 gpt.js..."
    # 替换为你实际的 gpt.js 脚本路径
    node ~/gpt/gpt.js &
    echo "gpt.js 已启动。"
    exit 0
fi
EOF
    chmod +x ~/gpt.sh
fi

# 为 crontab 添加定时任务（每 5 分钟运行一次）
echo "添加 crontab 任务..."
(crontab -l 2>/dev/null; echo "*/5 * * * * bash ~/gpt.sh") | crontab -

echo "项目安装完成！"
