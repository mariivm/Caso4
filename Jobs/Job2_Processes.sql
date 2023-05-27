 
exec fillEventLog;
--delete from EventLog;
SELECT * FROM EventLog;

--Insertar into EventTypes, Source, Levels, objectTypes
insert into eventTypes (EventTypeId, nombre) values 
(1, 'Information'),
(2, 'Warning'),
(3, 'Error'),
(4, 'Success Audit');

insert into source(sourceId, nombre) values 
(1, 'sqlServer');

insert into levels(levelId, descripcion) values 
(1, 'Information'),
(2, 'Warning'),
(3, 'Error'),
(4, 'Critical');

insert into objectTypes(objectTypesId, nombre) values 
(1, 'registro');

-- Linkear el server 
EXEC sp_addlinkedserver
  @server = 'LinkedServer',
  @srvproduct = '',
  @provider = 'SQLNCLI',
  @datasrc = 'mari\MSSQLSERVER01'

-- Procedure para la transferencia de datos 
CREATE PROCEDURE TransferirRegistros
AS
BEGIN
    SET NOCOUNT ON;

    -- Transferir registros a la bitácora gemela en el linked server
    INSERT INTO LinkedServer.esencialVerde.dbo.EventLog
    SELECT *
    FROM elementalGDB.dbo.EventLog;

    -- Eliminar registros pasados de la bitácora del sistema
    DELETE FROM elementalGDB.dbo.EventLog
    WHERE posttime < DATEADD(day, -7, GETDATE());
END;

exec TransferirRegistros;