# mydevenv_python
Docker Containerを用いたPythonの開発環境です。
以下はv0.2.0の説明です。v0.1.0の説明はこちらの[記事](https://own-search-and-study.xyz/2020/04/02/docker-python-develop-environment/)をご覧ください。

<img src="https://user-images.githubusercontent.com/25416202/80987114-8a87f700-8e6c-11ea-83a3-4dce4cb79bda.PNG" alt="desktop_image" width="500"/>

このコンテナは以下で構成しています。  
- ベースイメージ：[rosyuku/ubuntu-rdp:0.1.1](https://hub.docker.com/r/rosyuku/ubuntu-rdp)
  - OS:Ubuntu:18.04
  - 日本語入力環境対応（Mozc）
  - sudo権限付きuser作成済み（ID：my-python、PASS：my-Password）
  - デスクトップ環境：Xfce
  - リモートデスクトップサーバー：Xrdp
  - SSHサーバー：openssh-server
- Python環境：Anaconda
  - Anaconda3-2020.02を使用
  - matplotlibが日本語フォントに対応済み（fonts-takao)
  - spyderが日本語入力に対応済み
  - Jupyter Labが8888ポートで自動起動（パスワードは「password」）
  - 8080ポートを割り当てなしで解放済み（flask等で使用することを想定）

ユーザ名等の設定を変更する場合は、[設定ファイル](https://github.com/Rosyuku/mydevenv_python/blob/master/.env)を書き換えてDocker-composeし直していただくのが簡単です。

## Usage
imageをpullしてご利用いただく場合、以下のコマンドで実行できます。  
（以下の例では13389portでリモートデスクトップ接続、10022portでSSH接続、8888portでjupyter接続が可能です。ポートはお好きに変更いただいて構いません。）
```
docker run --rm -it -p 13389:3389 -p 10022:22 -p 8888:8888 -p 8080:8080 --shm-size=256m rosyuku/mydevenv_python:0.2.0
```

### Build手順
まず、GithubよりリポジトリをCloneしてください。
```
git clone https://github.com/Rosyuku/mydevenv_python.git
```
次にubuntu-rdp/.envファイルを開いて以下の設定を変更します。
```
root_password=super                         #rootのパスワード
user_name=my-ubuntu                         #作成するuserのユーザ名
user_password=my-Password                   #作成するuserのパスワード
container_name=ubuntu-desktop               #作成するコンテナの名前
conda_url=https://repo.anaconda.com/...     #AnacondaのパッケージのURL
host_name=Challenger                        #Ubuntuのホスト名
shm_size=256m                               #一時ファイル領域
RDPport=33890                               #リモートデスクトップ接続のport
SSHport=22000                               #SSH接続のport
Jupyterport=8888                            #Jupyter接続のport
WebAPPport=8080                             #WebAPP開発用に開けておくport
```
リモートデスクトップやSSH、及びjupyter等の設定は[config内](https://github.com/Rosyuku/ubuntu-rdp/tree/master/config)の設定ファイルを変更してください。

最後に以下等のコマンドでビルドします。
```
Docker-compose up --build
```