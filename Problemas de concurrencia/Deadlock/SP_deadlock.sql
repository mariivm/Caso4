--Preliminar #1 Caso #4
-- MARIANA VIQUEZ MONGE
-- HYTAN JARA MATAMOROS
-- SP CON PROBLEMAS

--============================================
--PROBLEMAS: DEADLOCK

DROP PROCEDURE if exists modificarLote
GO

CREATE PROCEDURE modificarLote
	@lote INT,
	@cantidad INT,
	@costo INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	DECLARE @producto INT;
	BEGIN TRANSACTION;
	IF @lote >= 0 BEGIN
		SELECT @producto=productoId from inventarioProductos where lote = @lote;

		--Se modifican los datos de los lotes dentro del inventario de productos

		UPDATE inventarioProductos SET cantidad = @cantidad WHERE lote = @lote;
		UPDATE inventarioProductos SET costo = @costo WHERE lote = @lote;

		-- Esperar por un tiempo para simular una pausa en la transacci�n
		WAITFOR DELAY '00:00:05';

		--Se modifica el precio de los productos por el recien ingresado
		UPDATE precioXproducto SET precio =  @costo WHERE   @producto= productoId;
	END;

	COMMIT TRANSACTION;
END
GO

exec modificarLote @lote=7,@cantidad=15,@costo=6000;


--========================================================
--Soluci�n: Deadlock
--En este caso se opta por dejar que una de las transacciones sea detenida por el servidor
--utilizando un Try Catch para que el error sea manejado, se le notifica al usuario de la transacci�n
--que fue detenida que lo vuelva a intentar debido a que alcanzo el estado de Deadlock.

DROP PROCEDURE if exists modificarLote
GO
CREATE PROCEDURE modificarLote
	@lote INT,
	@cantidad INT,
	@costo INT
AS
BEGIN
   SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	DECLARE @producto INT;
	BEGIN TRANSACTION;
	BEGIN TRY;
       IF @lote >= 0 BEGIN
		SELECT @producto=productoId from inventarioProductos where lote = @lote;

		--Se modifican los datos de los lotes dentro del inventario de productos

		UPDATE inventarioProductos SET cantidad = @cantidad WHERE lote = @lote;
		UPDATE inventarioProductos SET costo = @costo WHERE lote = @lote;

		-- Esperar por un tiempo para simular una pausa en la transacci�n
		WAITFOR DELAY '00:00:05';

		--Se modifica el precio de los productos por el recien ingresado

		UPDATE precioXproducto SET precio =  @costo WHERE   @producto= productoId;

		END;
		COMMIT TRANSACTION;
		--Avisa al usuario si su transacci�n fue exitosa
		SELECT 'TRANSACCI�N EXITOSA';
	end try
    Begin Catch
         -- Revisa que el error sea un Deadlock
         If(ERROR_NUMBER() = 1205)
         Begin
             Select 'DEADLOCK. TRANSACCI�N FALLO. Intente de nuevo'
         End
         -- Rollback para evitar datos sucios
         Rollback
    End Catch   
End

exec modificarLote @lote=7,@cantidad=5,@costo=4000;

