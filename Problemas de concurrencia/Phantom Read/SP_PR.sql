--Preliminar #1 Caso #4
-- MARIANA VIQUEZ MONGE
-- HYTAN JARA MATAMOROS
-- SP CON PROBLEMAS

--============================================
--PROBLEMA: PHANTOM READ 
--Este problema se aprecia ya que la transacción accede a la tabla inventarioProductos al inicio
--de sus procesos,regresando los datos que se encontraban en ese momento, mientras tanto
--otra transacción añadio nueva información a esas tablas por lo que al volver a acceder a esa tabla
--la transacción retorna información que no estaba antes cuando iniciada.
--Debido a que la segunda transacción no tiene delay.

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
	SELECT * FROM inventarioProductos; --Se accede a la tabla inventarioProductos

	SELECT @loteId=lote FROM inventarioProductos where productoId=@productId;

	--falla en caso de que la cantidad sea menor a la de existencias
	IF (SELECT cantidad FROM inventarioProductos where lote=@loteId) < @cantidad BEGIN
		ROLLBACK;
		RETURN;
	END;

	--calcula la nueva cantidad
	SET @newCantidad =(SELECT cantidad FROM inventarioProductos where lote=@loteId)-@cantidad;

	SELECT @precio=precio FROM precioXproducto where productoId=@productId;

	--Genera una venta con el producto electo
	INSERT INTO ventasProductos (ventaId,clienteId,empresaId,productoId,fechaVenta,cantidadVenta,lote) VALUES
	(@contador,@cliente,@empresa,@productId,GETDATE(),@cantidad,@loteId);

	--Genera un delay para simular una transaccion
	WAITFOR DELAY '00:00:10';

	--Actualiza los datos en la tabla de inventarios
	UPDATE inventarioProductos SET cantidad = @newCantidad  WHERE lote=@loteId;

	SELECT * FROM inventarioProductos; --Se accede a la tabla inventarioProductos despues de finalizar
										--los procesos

    -- Hacer commit de la transacción
	COMMIT;
END;
GO

exec ventaProducto @cliente = 1, @empresa = 1, @productid = 1, @cantidad =2


--============================================
--procedure ventaProducto
--SOLUCION PARA PHANTOM READ

--Se habilita en la base de datos la opción de isolation snapshot
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

select * from inventarioProductos