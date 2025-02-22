
# start from backup
- Перенести директорию backup на новый сервер
- Запустить `start_from_backup.sh`
- Убедиться, что база была восстановлена корректно

# autobackup
- Обменяться ключами с удаленным хостом

  sudo ssh-keygen -t rsa -b 4096 &&
  sudo ssh-copy-id -i /root/.ssh/id_rsa.pub $REMOTE_USER@$HOST

- Перенести директорию autobackup на новый сервер (slave/master)
- Перейти в нее
- Открыть и отредактировать поле ExecStart в файле binlog_backup.service по примеру
- Открыть и отредактировать поле ExecStart в файле backup_logic.service по примеру
- Запустить `setup_autobackup.sh`

# prometheus
- Запустить `setup_prometheus.sh` на машине для мониторинга

Установиться prometheus-server и grafana.
Prometheus будет доступен на порту 9090, grafana - 3000

- Установить exporter на target - машине командой
  `sudo apt install prometheus-node-exporter`

- Прописать в /etc/prometheus/prometheus.yml в секции job_name: node в поле
  targets - адрес исследуемой машины
!!!