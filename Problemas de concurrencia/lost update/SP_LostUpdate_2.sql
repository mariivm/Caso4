--============================================
--procedure ventaProducto
--PROBLEMAS: LOST UPDATE

DROP PROCEDURE IF EXISTS ventaProducto_2
GO 

CREATE PROCEDURE ventaProducto_2
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
	
	--SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

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

	WAITFOR DELAY '00:00:01';

	UPDATE inventarioProductos SET cantidad = @newCantidad  WHERE lote=@loteId;

	SELECT * FROM inventarioProductos;

    -- Hacer commit de la transacción
	COMMIT;
END;
GO

--============================================
--procedure ventaProducto
--SOLUCION PARA LOST UPDATE

DROP PROCEDURE IF EXISTS ventaProducto_2
GO 

CREATE PROCEDURE ventaProducto_2
	@cliente INT,
	@empresa INT,
	@productId INT,
	@cantidad INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
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

	WAITFOR DELAY '00:00:01';

	UPDATE inventarioProductos SET cantidad = @newCantidad  WHERE lote=@loteId;

	SELECT * FROM inventarioProductos;

    -- Hacer commit de la transacción
	COMMIT;
END;
GO
