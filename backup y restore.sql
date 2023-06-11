use master

alter database esencialGDB
set RECOVERY full

backup database esencialGDB
to disk = 'C:\Backup\Backup-Prueba.bak'
WITH NAME='Backup de prueba', DESCRIPTION='Backup full de prueba'

RESTORE HEADERONLY FROM DISK = 'C:\Backup\Backup-Prueba.bak'

backup database esencialGDB
to disk = 'C:\Backup\Backup-Prueba.bak'
WITH NAME='Backup 2 de prueba', DESCRIPTION='Backup incremental de prueba', DIFFERENTIAL

backup log esencialGDB to disk = 'C:\Backup\Backup-Prueba.bak'
with name='Backup log', description ='Backup log prueba'

DROP database esencialGDB

RESTORE DATABASE esencialGDB from disk = 'C:\Backup\Backup-Prueba.bak'
WITH FILE = 1, NORECOVERY

RESTORE DATABASE esencialGDB from disk = 'C:\Backup\Backup-Prueba.bak'
WITH FILE = 2, NORECOVERY

RESTORE log esencialGDB from disk = 'C:\Backup\Backup-Prueba.bak'
WITH FILE = 3, RECOVERY