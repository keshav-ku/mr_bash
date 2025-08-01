#!/bin/bash

USERNAME=$1

if [ -z "$USERNAME" ]; then
  echo "使い方: $0 ユーザー名"
  exit 1
fi

echo "=== ユーザー情報 ==="
getent passwd "$USERNAME" || echo "ユーザー $USERNAME は存在しません"

echo ""
echo "=== authorized_keys の中身 (/home/$USERNAME/.ssh/authorized_keys) ==="
if sudo test -f /home/"$USERNAME"/.ssh/authorized_keys; then
  sudo cat /home/"$USERNAME"/.ssh/authorized_keys
else
  echo "authorized_keys ファイルがありません"
fi

echo ""
echo "=== sudoers の設定 ==="
if sudo grep "$USERNAME" /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
  :
else
  echo "sudoers に設定はありません"
fi


echo ""
echo "=== 実行中のプロセス ==="
sudo ps -u "$USERNAME" || echo "プロセスはありません"

echo ""
echo "=== crontab の内容 ==="
sudo crontab -u "$USERNAME" -l 2>/dev/null || echo "crontab はありません"
