--Preliminar #1 Caso #4
-- MARIANA VIQUEZ MONGE
-- HYTAN JARA MATAMOROS
-- SP CON PROBLEMAS


Drop procedure if exists actualizarRecipientes
go
CREATE PROCEDURE actualizarRecipientes
	@recipId INT,
	@estado INT,
	@recPeso INT
AS
BEGIN
    BEGIN TRANSACTION;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    -- Realizar una modificación en los datos
	
	if not exists (SELECT * FROM recipientes WHERE recipienteId=@recipId) begin
		rollback;
		return;
	end;

	IF @recPeso>= (SELECT recipCapacidad FROM recipientes WHERE recipienteId=@recipId) begin
		rollback;
		return;
	end;

    UPDATE recipientes SET recipPeso = @recPeso WHERE recipienteId=@recipId;
    
    -- Esperar un poco para simular una transacción pendiente
    WAITFOR DELAY '00:00:08';

	IF @estado>3 or @estado<0 begin
		rollback;
		return;
	end;

	UPDATE recipientes SET estado = @estado WHERE recipienteId=@recipId;

    -- Hacer commit de la transacción
	COMMIT;
END
go

exec actualizarRecipientes @recipId = 10, @estado=4,@recPeso=10
go

 SELECT * FROM recipientes WHERE recipienteId=10;


