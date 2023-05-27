--Preliminar #1 Caso #4
-- MARIANA VIQUEZ MONGE
-- HYTAN JARA MATAMOROS
-- SP CON PROBLEMAS

--============================================
--procedure ventaProducto
--PROBLEMAS: PHANTOM READ - LOST UPDATE

DROP PROCEDURE IF EXISTS ventaProducto
GO 

CREATE PROCEDURE ventaProducto
	@cliente INT,
	@empresa INT,
	@productId INT,
	@cantidad INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	DECLARE @loteId INT;
	DECLARE @precio DECIMAL;
	DECLARE @contador INT;
	declare @newCantidad INT;
	SELECT @contador = MAX(ventaId)FROM ventasProductos;
     set @contador = @contador+1;
	BEGIN TRANSACTION;

    -- Realizar una modificación en los datos
	SELECT * FROM inventarioProductos;

	SELECT @loteId=lote FROM inventarioProductos where productoId=@productId;

	IF (SELECT cantidad FROM inventarioProductos where lote=@loteId) < @cantidad BEGIN
		ROLLBACK;
		RETURN;
	END;

	SET @newCantidad =(SELECT cantidad FROM inventarioProductos where lote=@loteId)-@cantidad;

	SELECT @precio=precio FROM precioXproducto where productoId=@productId;

	INSERT INTO ventasProductos (ventaId,clienteId,empresaId,productoId,fechaVenta,cantidadVenta,lote) VALUES
	(@contador,@cliente,@empresa,@productId,GETDATE(),@cantidad,@loteId);

	WAITFOR DELAY '00:00:10';

	UPDATE inventarioProductos SET cantidad = @newCantidad  WHERE lote=@loteId;

	SELECT * FROM inventarioProductos;

    -- Hacer commit de la transacción
	COMMIT;
END;
GO
--============================================
--procedure ventaProducto
--SOLUCION PARA PHANTOM READ

ALTER DATABASE [elementalGDB] SET ALLOW_SNAPSHOT_ISOLATION ON;

DROP PROCEDURE IF EXISTS ventaProducto
GO 

CREATE PROCEDURE ventaProducto
	@cliente INT,
	@empresa INT,
	@productId INT,
	@cantidad INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	DECLARE @loteId INT;
	DECLARE @precio DECIMAL;
	DECLARE @contador INT;
	declare @newCantidad INT;
	SELECT @contador = MAX(ventaId)FROM ventasProductos;
     set @contador = @contador+1;
	BEGIN TRANSACTION;

    -- Realizar una modificación en los datos
	SELECT * FROM inventarioProductos;

	SELECT @loteId=lote FROM inventarioProductos where productoId=@productId;

	IF (SELECT cantidad FROM inventarioProductos where lote=@loteId) < @cantidad BEGIN
		ROLLBACK;
		RETURN;
	END;

	SET @newCantidad =(SELECT cantidad FROM inventarioProductos where lote=@loteId)-@cantidad;

	SELECT @precio=precio FROM precioXproducto where productoId=@productId;

	INSERT INTO ventasProductos (ventaId,clienteId,empresaId,productoId,fechaVenta,cantidadVenta,lote) VALUES
	(@contador,@cliente,@empresa,@productId,GETDATE(),@cantidad,@loteId);

	WAITFOR DELAY '00:00:10';

	UPDATE inventarioProductos SET cantidad = @newCantidad  WHERE lote=@loteId;

	SELECT * FROM inventarioProductos;

    -- Hacer commit de la transacción
	COMMIT;
END;
GO