# OpenShift etcd backup CronJob

This CronJob creates an POD which runs `/usr/local/bin/cluster-backup.sh` on a master-node to create the described backup. After finishing, it copies the files to an configured PV and expires old backups according to its configuration.

The OpenShift 4 backup generates 2 different files with the date when it is performed:

- snapshot_TIMESTAMP.db
- static_kuberesources_TIMESTAMP.tar.gz

The `.db` file is a snapshot of the etcd and the archived `.tar.gz` contains the static pods of the control plane (etcd, api server, controller manager and scheduler) with their respective certificates and private keys. Those files are put in an seperate directory on the PV per backup run.

## Installation

Fist, create a namespace:
```
oc new-project etcd-backup
```

Since the container needs to be privileged, add the reqired RBAC rules:
```
oc create -f backup-rbac.yaml
```

Then adjust storage to your needs in `backup-storage.yaml` and deploy it. The example uses NFS but you can use any storage class you want (`hostPath` or `provioning`):
```
oc create -f backup-storage.yaml
```

Configure the backup-script:
```
oc create -f backup-config.yaml
```

Then deploy, and configure the cronjob:
```
oc create -f backup-cronjob.yaml
```

## Creating manual backup / testing

To test the backup, or create an manual backup, you can run a job:
```
backupName=$(date "+etcd-backup-manual-%F-%H-%M-%S")
oc create job --from=cronjob/etcd-backup ${backupName}
```

To see if everything works as it should, you can check the logs:
```
oc logs -l job-name=${backupName}
```
Then check on your Storage, if the files are there as excepted.

## Configuration

Configuration can be changed in configmap `backup-config`:

```
oc edit -n etcd-backup cm/backup-config
```

The following options are used:
- `OCP_BACKUP_SUBDIR`: Sub directory on PVC. If it not exists it will be created.
- `OCP_BACKUP_DIRNAME`: Dirname of singe backup. This is a string which run trough
[`date`](https://man7.org/linux/man-pages/man1/date.1.html)
- `OCP_BACKUP_EXPIRE_TYPE`:
  - `days`: Keep backups newer than `backup.keepdays`.
  - `count`: Keep a number of backups. `backup.keepcount` is used to determine how much.
  - `never`: Dont expire backups, keep all of them.
- `OCP_BACKUP_KEEP_DAYS`: Days to keep the backup. Only used if `backup.expiretype` is set to `days`
- `OCP_BACKUP_KEEP_COUNT`: Number of backups to keep. Only used if `backup.expiretype` is set to `count`
- `OCP_BACKUP_UMASK`: Umask used inside the script to set proper permission on written files.

Changing the schedule be done in the CronJob directly, with `spec.schedule`:
```
oc edit -n etcd-backup cronjob/etcd-backup
```
Default is `0 0 * * *` which means the cronjob runs one time a day at midnight.

# Helm chart

To deploy easily the solution a helm chart is available on upstream Adfinis charts [repository](https://github.com/adfinis-sygroup/helm-charts/tree/master/charts/openshift-etcd-backup).

## References
* https://docs.openshift.com/container-platform/4.7/backup_and_restore/backing-up-etcd.html
