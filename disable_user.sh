#!/bin/bash

USERNAME=$1

if [ -z "$USERNAME" ]; then
  echo "使い方: $0 ユーザー名"
  exit 1
fi

echo "ユーザーを無効化しています: $USERNAME"

# authorized_keysが存在する場合、名前を変更する
if sudo test -f /home/$USERNAME/.ssh/authorized_keys; then
  sudo mv /home/$USERNAME/.ssh/authorized_keys /home/$USERNAME/.ssh/authorized_keys.disabled
  echo "authorized_keysをリネームしました"
else
  echo "authorized_keysが見つかりませんでした"
fi

# ユーザーアカウントのパスワードをロック
sudo usermod -L $USERNAME && echo "アカウントをロックしました"

# シェルをnologinに変更
sudo usermod -s /usr/sbin/nologin $USERNAME && echo "シェルをnologinに設定しました"

# sudoersの行は手動でコメントアウトしてください
echo "$USERNAMEのsudoersの行は、'sudo visudo'を使って手動でコメントアウトしてください"

echo "完了しました。"
