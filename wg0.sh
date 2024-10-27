# 创建并编辑脚本
nano ~/wg.sh

# 赋予执行权限
chmod +x ~/wg.sh

# 添加定时任务，每天 23:56 自动运行 wg.sh
(crontab -l; echo "56 23 * * * ~/wg.sh") | crontab -
