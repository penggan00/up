name: Update File

on:
  schedule:
    - cron: '0 2 * * *'  # 每天凌晨2点执行
  workflow_dispatch:  # 允许手动触发

jobs:
  update-file:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v2

    - name: Fetch content
      run: |
        curl -o pp.xml https://epg.112114.xyz/pp.xml

    - name: Commit and push changes
      run: |
        git config --global user.name 'github-actions'
        git config --global user.email 'github-actions@github.com'
        cp pp.xml ./pp.xml  # 将文件拷贝到仓库根目录
        git add ./pp.xml
        git commit -m "Update pp.xml"
        git push
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
