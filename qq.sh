#!/bin/bash

# 设置脚本在遇到错误时停止执行
set -e

# 创建 translate 目录（如果不存在）
if [ ! -d "translate" ]; then
    echo "创建 translate 目录..."
    mkdir translate
fi

# 进入 translate 目录
cd translate

# 初始化 npm 项目
echo "初始化 npm 项目..."
npm init -y

# 安装依赖包
echo "安装 telegraf 和 tencentcloud-sdk-nodejs..."
npm install telegraf tencentcloud-sdk-nodejs

# 安装 dotenv 以管理环境变量
echo "安装 dotenv..."
npm install dotenv

# 创建 translate.js 文件（如果不存在）
if [ ! -f "translate.js" ]; then
    echo "创建 translate.js 文件..."
    cat << 'EOF' > translate.js
// translate.js
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

# 创建 translate.sh 文件，用于定时任务调用
if [ ! -f "~/translate.sh" ]; then
    echo "创建 translate.sh 文件..."
    cat << 'EOF' > ~/translate.sh
#!/bin/bash

# 检查 translate.sh 是否在运行
if pgrep -f "translate.sh" > /dev/null; then
    echo "translate.sh is running. Stopping it..."
    # 停止 translate.sh 进程
    pkill -f "translate.sh"
else
    echo "translate.sh is not running."
fi
# 等待1秒
sleep 1
# 检查是否有 translate.js 进程
if pgrep -f "translate.js" > /dev/null
then
    echo "translate.js 进程已在运行，脚本退出。"
    exit 0
else
    echo "未检测到 translate.js 进程，启动 translate.js..."
    # 替换为你实际的 translate.js 脚本路径
    node ~/translate/translate.js &
    echo "translate.js 已启动。"
    exit 0
fi
EOF
    chmod +x ~/translate.sh
fi

# 为 crontab 添加定时任务（每 5 分钟运行一次）
echo "添加 crontab 任务..."
(crontab -l 2>/dev/null; echo "*/5 * * * * bash ~/translate.sh") | crontab -

echo "项目安装完成！"
