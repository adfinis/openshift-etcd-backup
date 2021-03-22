#!/bin/sh

set -xeuo pipefail

# validate expire type
case "${OCP_BACKUP_EXPIRE_TYPE}" in
    days|count) ;;
    *) echo "backup.expiretype needs to be one of: days,count"; exit 1 ;;
esac

# validate  expire numbers
if [ "${OCP_BACKUP_EXPIRE_TYPE}" = "days" ]; then
  case ${OCP_BACKUP_KEEP_DAYS} in
    ''|*[!0-9]*) echo "backup.expiredays needs to be a valid number"; exit 1 ;;
    *) ;;
  esac
else
  case "${OCP_BACKUP_KEEP_COUNT}" in
    ''|*[!0-9]*) echo "backup.expirecount needs to be a valid number"; exit 1 ;;
    *) ;;
  esac
fi

# make dirname and cleanup paths
BACKUP_FOLDER=$( date "${OCP_BACKUP_DIRNAME}") || { echo "Invalid backup.dirname" && exit 1; }
BACKUP_PATH=$( realpath -m "${OCP_BACKUP_SUBDIR}/${BACKUP_FOLDER}" )
BACKUP_PATH_POD=$( realpath -m "/backup/${BACKUP_PATH}" )
BACKUP_ROOTPATH=$( realpath -m "/backup/${OCP_BACKUP_SUBDIR}" )

# make nescesary directorys
mkdir -p "/host/tmp/etcd-backup"
mkdir -p "${BACKUP_PATH_POD}"

# create backup to temporary location
chroot /host /usr/local/bin/cluster-backup.sh /tmp/etcd-backup

# move files to pvc and delete temporary files
cp -rp /host/tmp/etcd-backup/* ${BACKUP_PATH_POD}
rm -f /host/tmp/etcd-backup/*

# expire backup
if [ "${OCP_BACKUP_EXPIRE_TYPE}" = "days" ]; then
  find ${BACKUP_ROOTPATH} -mindepth 1 -maxdepth 1 -daystart -type d -mtime +${OCP_BACKUP_KEEP_DAYS} -exec rm -rv {} +
else
  ls -1tp ${BACKUP_ROOTPATH} | awk "NR>${OCP_BACKUP_KEEP_COUNT}" | xargs -I{} rm -rv ${BACKUP_ROOTPATH}/{}
fi
