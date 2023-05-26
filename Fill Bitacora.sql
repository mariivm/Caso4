--drop procedure if exists fillEventLog
create procedure fillEventLog 
as begin
	DECLARE @contador int;
	DECLARE @contador2 int;
	 SELECT @contador = MAX(EventLogId)FROM EventLog;
	 set @contador = @contador+1;
	 if @contador is null
	 begin
		set @contador = 1;
	 end
	 set @contador2 = @contador+20;
	WHILE (@contador <= @contador2)
	BEGIN		
		insert into EventLog(EventLogId, posttime, computer, username, checksum, descripcion, value1, value2, referenceId1, referenceId2, levelId, sourceId, evenTypeId, objectTypeId)
		values (@contador,'2023-4-20' , 'Laptop', SUSER_SNAME(), 100, 'registro de bitacora/pruebas', 0, 0, 0, 0, 1, 1, 1,1 );

	SET @contador = @contador + 1;
	end

end; 
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

EXEC sp_linkedservers;