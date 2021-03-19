#!/bin/sh

set -e
set -x

BACKUP_TIMESTAMP=$(date "+%F-%H-%M-%S")
mkdir -p /host/tmp/etcd-backup
mkdir -p /backup/etcd-backup-${BACKUP_TIMESTAMP}
chroot /host /usr/local/bin/cluster-backup.sh /tmp/etcd-backup
cp -rp /host/tmp/etcd-backup/* /backup/etcd-backup-${BACKUP_TIMESTAMP}
rm -f /host/tmp/etcd-backup/*

find "/backup/" -mindepth 1 -maxdepth 1 -name 'etcd-backup-*' -daystart -type d -mtime +${OCP_BACKUP_KEEP_DAYS} -exec rm -rv {} +
