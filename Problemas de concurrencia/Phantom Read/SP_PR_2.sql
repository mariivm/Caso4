--============================================
--procedure tratamientoDesechos
--PROBLEMA: PHANTOM READ


DROP PROCEDURE IF EXISTS tratamientoDesechos
GO
CREATE PROCEDURE tratamientoDesechos
	@localId INT,
	@recepienteId INT,
	@tipoRecepcion INT,
	@empresa INT,
	@producto INT,
	@actor int
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	DECLARE @pesoRecep DECIMAL;
	DECLARE @contador INT;
	DECLARE @loteId INT;
	SELECT @contador = MAX(recepcionId)FROM recepcionDesechos;
     set @contador = @contador+1;
	SELECT @loteId = MAX(lote)FROM ordenProduccion;
     set @loteId = @loteId+1;

	BEGIN TRANSACTION;

	--Obtiene el peso del recipiente
	SELECT @pesoRecep =recipPeso FROM recipientes where recipienteId=@recepienteId;

	--Inserta en la tabla de recepcion de desechos para generar una nueva entrada
	INSERT INTO recepcionDesechos(localId,recipienteId,recepcionId,fecha,tipoRecepcion,productoId,pesoRecibido,empresaId,checksum) VALUES
	(@localId,@recepienteId,@contador,GETDATE(),@tipoRecepcion,@producto,@pesoRecep,@empresa,0x0102030405);

	--En caso de recepción tipo 2 crea un nuevo lote de productos
	IF(@tipoRecepcion = 2) begin
		INSERT INTO ordenProduccion (lote,recepcionId,productoId,cantidadInicial,productoResult,cantidadResult,costo,actorId) VALUES
		(@loteId,@tipoRecepcion,@producto,@pesoRecep,5,@pesoRecep-1,5000,@actor);
	end;

	--Crea una nueva entrada del inventario de productos con un lote
	INSERT INTO inventarioProductos (productoId, lote, cantidad,unidadMedida,costo,checksum) VALUES
	(@producto, @loteId, @pesoRecep-1, '-',5000,0x0102030405);

	COMMIT;
END
go

exec tratamientoDesechos @localid=1, @recepienteId = 1, @tipoRecepcion = 2, @empresa =1, @producto = 1, @actor = 1


--============================================
--Solución PHANTOM READ

--Se cambia el Isolation level a Snapshot, esto evita el bloqueo de las filas y retorna
--una vista coherente y aislada de los datos, incluso si otras 
--transacciones están modificando los mismos datos simultáneamente.
--Esto significa que la transacción no verá las modificaciones realizadas
--por otras transacciones después de que se haya iniciado.

DROP PROCEDURE IF EXISTS tratamientoDesechos
GO
CREATE PROCEDURE tratamientoDesechos
	@localId INT,
	@recepienteId INT,
	@tipoRecepcion INT,
	@empresa INT,
	@producto INT,
	@actor int
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	DECLARE @pesoRecep DECIMAL;
	DECLARE @contador INT;
	DECLARE @loteId INT;
	SELECT @contador = MAX(recepcionId)FROM recepcionDesechos;
     set @contador = @contador+1;
	SELECT @loteId = MAX(lote)FROM ordenProduccion;
     set @loteId = @loteId+1;

	BEGIN TRANSACTION;

	--Obtiene el peso del recipiente
	SELECT @pesoRecep =recipPeso FROM recipientes where recipienteId=@recepienteId;

	--Inserta en la tabla de recepcion de desechos para generar una nueva entrada
	INSERT INTO recepcionDesechos(localId,recipienteId,recepcionId,fecha,tipoRecepcion,productoId,pesoRecibido,empresaId,checksum) VALUES
	(@localId,@recepienteId,@contador,GETDATE(),@tipoRecepcion,@producto,@pesoRecep,@empresa,0x0102030405);

	--En caso de recepción tipo 2 crea un nuevo lote de productos
	IF(@tipoRecepcion = 2) begin
		INSERT INTO ordenProduccion (lote,recepcionId,productoId,cantidadInicial,productoResult,cantidadResult,costo,actorId) VALUES
		(@loteId,@tipoRecepcion,@producto,@pesoRecep,5,@pesoRecep-1,5000,@actor);
	end;

	--Crea una nueva entrada del inventario de productos con un lote
	INSERT INTO inventarioProductos (productoId, lote, cantidad,unidadMedida,costo,checksum) VALUES
	(@producto, @loteId, @pesoRecep-1, '-',5000,0x0102030405);

	COMMIT;
END
go