#!/bin/bash

USERS=("user1")

GROUP="devops"

if ! getent group $GROUP >/dev/null; then # ! возвращяет 0 если группа есть, возваращает 1 если группы нету
    groupadd $GROUP
    echo "Группа $GROUP создана"
fi

for USER in "${USERS[@]}"; do
    if id "$USER" &>/dev/null; then # id "$USER" - покажет инфу о группе, &>/dev/null - перенаправиль стандартный и ошибочный вывод в никуда
        echo "Пользователь $USER уже существует"
    else
        useradd -m -s /bin/bash -G $GROUP $USER # -m - чтобы создалась домашняя дирректирия, -s - оболочка
        echo "Пользователь $USER создан и добавлен в группу $GROUP"
    fi

    mkdir -p /home/$USER/.ssh
    chmod 700 /home/$USER/.ssh

    SSH_DIR="/home/$USER/.ssh"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    chown "$USER:$GROUP" "$SSH_DIR"

    su - $USER -c "ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' -q"
    echo "🔑 Ключи SSH сгенерированы для '$USER'"
      
    su - "$USER" -c "cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys"
    su - "$USER" -c "chmod 600 ~/.ssh/authorized_keys"

    echo "✅ SSH доступ настроен для '$USER'"

    mkdir -p /root/keys
    cp "/home/$USER/.ssh/id_ed25519.pub" "/root/keys/${USER}.pub"
    echo "📂 Публичный ключ сохранён в /root/keys/${USER}.pub"
done