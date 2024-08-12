name: my_tv Release

# action事件触发
on:
  workflow_dispatch:
  push:
    # push tag时触发
    tags:
      - "v*.*.*"

# 可以有多个jobs
jobs:
  android:
    # 运行环境 ubuntu-latest window-latest mac-latest
    runs-on: ubuntu-latest

    # 每个jobs中可以有多个steps
    steps:
      - name: 代码迁出
        uses: actions/checkout@v3

      - name: 构建Java环境
        uses: actions/setup-java@v3
        with:
          distribution: "zulu"
          java-version: "17"

      - name: 检查缓存
        uses: actions/cache@v2
        id: cache-flutter
        with:
          path: /root/flutter-sdk # Flutter SDK 的路径
          key: ${{ runner.os }}-flutter-${{ hashFiles('**/pubspec.lock') }}

      - name: 安装Flutter
        if: steps.cache-flutter.outputs.cache-hit != 'true'
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.19.4
          channel: any

      - name: 下载项目依赖
        run: flutter pub get

      - name: 解码生成 jks
        run: echo $KEYSTORE_BASE64 | base64 -di > android/app/keystore.jks
        env:
          KEYSTORE_BASE64: ${{ secrets.KEYSTORE_BASE64 }}

      - name: flutter build apk
        run: flutter build apk --release --target-platform android-arm64,android-arm
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD}}

      - name: 获取版本号
        id: version
        run: echo "version=${GITHUB_REF#refs/tags/v}" >>$GITHUB_OUTPUT

      - name: 重命名应用
        run: |
          # DATE=${{ steps.date.outputs.date }}
          for file in build/app/outputs/flutter-apk/app-*.apk; do
            if [[ $file =~ app-(.?*)release.apk ]]; then
              new_file_name="build/app/outputs/flutter-apk/my_tv-${BASH_REMATCH[1]}${{ steps.version.outputs.version }}.apk"
              mv "$file" "$new_file_name"
            fi
          done

      - name: 上传
        uses: actions/upload-artifact@v3
        with:
          name: my_tv-Release
          path: |
            build/app/outputs/flutter-apk/my_tv-*.apk

  upload:
    runs-on: ubuntu-latest

    needs:
      - android
    steps:
      - uses: actions/download-artifact@v3
        with:
          name: my_tv-Release
          path: ./my_tv-Release

      - name: Install dependencies
        run: sudo apt-get install tree -y

      - name: Get version
        id: version
        run: echo "version=${GITHUB_REF#refs/tags/v}" >>$GITHUB_OUTPUT

      - name: Upload Release
        uses: ncipollo/release-action@v1
        with:
          name: v${{ steps.version.outputs.version }}
          token: ${{ secrets.GIT_TOKEN }}
          omitBodyDuringUpdate: true
          omitNameDuringUpdate: true
          omitPrereleaseDuringUpdate: true
          allowUpdates: true
          artifacts: my_tv-Release/*