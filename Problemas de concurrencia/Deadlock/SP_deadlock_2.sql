--Preliminar #1 Caso #4
-- MARIANA VIQUEZ MONGE
-- HYTAN JARA MATAMOROS
-- SP CON PROBLEMAS

--============================================
--PROBLEMAS: DEADLOCK
--El error de deadlock se da debido a que ambas transacciones estan accediendo a las misma tablas pero en
--un orden diferente lo cual lleva a una de las transaccion a bloquear las tablas, antes de que la otra
--pueda acceder y viceversa por lo cual ninguna puede avanzar.

DROP PROCEDURE if exists modificarLote_2
GO

CREATE PROCEDURE modificarLote_2
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

		--Se modifica el precio de los productos por el recien ingresado
		UPDATE precioXproducto SET precio =  @costo WHERE   @producto= productoId;

		-- Esperar por un tiempo para simular una pausa en la transacción
		WAITFOR DELAY '00:00:05';
		--Se modifican los datos de los lotes dentro del inventario de productos
		UPDATE inventarioProductos SET cantidad = @cantidad WHERE lote = @lote;
		UPDATE inventarioProductos SET costo = @costo WHERE lote = @lote;
		
	END;

	COMMIT TRANSACTION;
END
GO

exec modificarLote_2 @lote=7,@cantidad=5,@costo=4000;

--========================================================
--Solución: Deadlock

DROP PROCEDURE if exists modificarLote_2
GO
CREATE PROCEDURE modificarLote_2
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

		--Se modifica el precio de los productos por el recien ingresado

		UPDATE precioXproducto SET precio =  @costo WHERE   @producto= productoId;

		-- Esperar por un tiempo para simular una pausa en la transacción
		WAITFOR DELAY '00:00:05';

		--Se modifican los datos de los lotes dentro del inventario de productos
		
		UPDATE inventarioProductos SET cantidad = @cantidad WHERE lote = @lote;
		UPDATE inventarioProductos SET costo = @costo WHERE lote = @lote;
		
		END;
		COMMIT TRANSACTION;
		--Avisa al usuario si su transacción fue exitosa
		SELECT 'TRANSACCIÓN EXITOSA';
	end try
    Begin Catch
         -- Revisa que el error sea un Deadlock
         If(ERROR_NUMBER() = 1205)
         Begin
             Select 'Deadlock. TRANSACCIÓN FALLO. Intente de nuevo'
         End
         -- Rollback para evitar datos sucios
         Rollback
    End Catch   
End

exec modificarLote_2 @lote=7,@cantidad=5,@costo=4000;

