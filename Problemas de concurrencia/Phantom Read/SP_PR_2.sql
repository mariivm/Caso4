--============================================
--procedure tratamientoDesechos
--PROBLEMAS: PHANTOM READ

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

	SELECT @pesoRecep =recipPeso FROM recipientes where recipienteId=@recepienteId;


	INSERT INTO recepcionDesechos(localId,recipienteId,recepcionId,fecha,tipoRecepcion,productoId,pesoRecibido,empresaId,checksum) VALUES
	(@localId,@recepienteId,@contador,GETDATE(),@tipoRecepcion,@producto,@pesoRecep,@empresa,0x0102030405);

	IF(@tipoRecepcion = 2) begin
		INSERT INTO ordenProduccion (lote,recepcionId,productoId,cantidadInicial,productoResult,cantidadResult,costo,actorId) VALUES
		(@loteId,@tipoRecepcion,@producto,@pesoRecep,5,@pesoRecep-1,5000,@actor);
	end;

	INSERT INTO inventarioProductos (productoId, lote, cantidad,unidadMedida,costo,checksum) VALUES
	(@producto, @loteId, @pesoRecep-1, '-',5000,0x0102030405);

	COMMIT;
END
go


--============================================
--procedure tratamientoDesechos
--Solución PHANTOM READ

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

	SELECT @pesoRecep =recipPeso FROM recipientes where recipienteId=@recepienteId;


	INSERT INTO recepcionDesechos(localId,recipienteId,recepcionId,fecha,tipoRecepcion,productoId,pesoRecibido,empresaId,checksum) VALUES
	(@localId,@recepienteId,@contador,GETDATE(),@tipoRecepcion,@producto,@pesoRecep,@empresa,0x0102030405);

	IF(@tipoRecepcion = 2) begin
		INSERT INTO ordenProduccion (lote,recepcionId,productoId,cantidadInicial,productoResult,cantidadResult,costo,actorId) VALUES
		(@loteId,@tipoRecepcion,@producto,@pesoRecep,5,@pesoRecep-1,5000,@actor);
	end;

	INSERT INTO inventarioProductos (productoId, lote, cantidad,unidadMedida,costo,checksum) VALUES
	(@producto, @loteId, @pesoRecep-1, '-',5000,0x0102030405);

	COMMIT;
END
go