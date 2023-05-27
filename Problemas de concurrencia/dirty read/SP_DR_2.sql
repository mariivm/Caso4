--Preliminar #1 Caso #4
-- MARIANA VIQUEZ MONGE
-- HYTAN JARA MATAMOROS
-- SP CON PROBLEMAS

--=============================================================================
--PROBLEMA: DIRTY READ
--El procedure no sera modificado como parte de la soluci�n, si no que se modifica el segundo procedure
--encargado de la lectura.
--En caso de un rollback el procedure encargado de la lectura obtendria los datos de forma err�nea.
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

    -- Realizar una modificaci�n en los datos
	--Falla en caso de no existir el recipiente
	if not exists (SELECT * FROM recipientes WHERE recipienteId=@recipId) begin
		rollback;
		return;
	end;

	--Falla en caso de que el peso sea mayor a la capacidad del recipiente
	IF @recPeso>= (SELECT recipCapacidad FROM recipientes WHERE recipienteId=@recipId) begin
		rollback;
		return;
	end;

    UPDATE recipientes SET recipPeso = @recPeso WHERE recipienteId=@recipId;
    
    -- Esperar un poco para simular una transacci�n pendiente
    WAITFOR DELAY '00:00:08';

	--Falla en caso de ingresa un estado inv�lido, que no sean 1,2 o 3
	IF @estado>3 or @estado<0 begin
		rollback;
		return;
	end;

	--Se realiza el update en caso de que todo resulte correcto
	UPDATE recipientes SET estado = @estado WHERE recipienteId=@recipId;

    -- Hacer commit de la transacci�n
	COMMIT;
END
go

exec actualizarRecipientes @recipId = 10, @estado=4,@recPeso=213
go

 SELECT * FROM recipientes WHERE recipienteId=10;


