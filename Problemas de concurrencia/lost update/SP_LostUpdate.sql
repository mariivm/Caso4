--Preliminar #1 Caso #4
-- MARIANA VIQUEZ MONGE
-- HYTAN JARA MATAMOROS
-- SP CON PROBLEMAS

--=============================================================================
--PROBLEMA: Lost Update
--El problema se presenta debido a que el segundo procedure termina su transacción a más velocidad
--modificando la cantidad de existencias del producto, pero la primer transacción ya obtuvo el dato 
--de cantidad desactualizado por lo que realiza el update con datos incoherentes.

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
	SELECT * FROM inventarioProductos; --Con fines demostrativos se realiza un select para observar
										--el cambio realizado por el lost update

	--Se extrae el lote
	SELECT @loteId=lote FROM inventarioProductos where productoId=@productId;

	--Falla en caso de que la cantidad ingresada sea mayor a la de existencias
	IF (SELECT cantidad FROM inventarioProductos where lote=@loteId) < @cantidad BEGIN
		ROLLBACK;
		RETURN;
	END;

	--Se calcula la nueva cantidad para el update
	SET @newCantidad =(SELECT cantidad FROM inventarioProductos where lote=@loteId)-@cantidad;

	--se extrae el precio para realizar la venta
	SELECT @precio=precio FROM precioXproducto where productoId=@productId;

	--Se crea una nueva venta del producto electo
	INSERT INTO ventasProductos (ventaId,clienteId,empresaId,productoId,fechaVenta,cantidadVenta,lote) VALUES
	(@contador,@cliente,@empresa,@productId,GETDATE(),@cantidad,@loteId);

	--Delay para simular una transacción
	WAITFOR DELAY '00:00:10';

	--Se hace el update en el inventario de productos, especificamente de la cantidad
	UPDATE inventarioProductos SET cantidad = @newCantidad  WHERE lote=@loteId;

	SELECT * FROM inventarioProductos;

    -- Hacer commit de la transacción
	COMMIT;
END;
GO

--=============================================================================
--SOLUCION:  Lost Update

DROP PROCEDURE IF EXISTS ventaProducto
GO 

CREATE PROCEDURE ventaProducto
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

	WAITFOR DELAY '00:00:10';

	UPDATE inventarioProductos SET cantidad = @newCantidad  WHERE lote=@loteId;

	SELECT * FROM inventarioProductos;

    -- Hacer commit de la transacción
	COMMIT;
END;
GO