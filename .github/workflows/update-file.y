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
        echo "Fetching content from URL..."
        curl -o pp.xml https://epg.112114.xyz/pp.xml
        if [ $? -ne 0 ]; then
          echo "Error: Failed to fetch content."
          exit 1
        fi

    - name: Commit and push changes
      run: |
        echo "Configuring git..."
        git config --global user.name 'github-actions'
        git config --global user.email 'github-actions@github.com'

        echo "Checking for changes..."
        if git diff --exit-code --quiet pp.xml; then
          echo "No changes detected, skipping commit."
        else
          echo "Changes detected, committing and pushing..."
          git add pp.xml
          git commit -m "Update pp.xml"
          git push
        fi
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}