--Preliminar #1 Caso #4
-- MARIANA VIQUEZ MONGE
-- HYTAN JARA MATAMOROS
-- SP CON PROBLEMAS

--=============================================================================
--PROBLEMA: DIRTY READ


Drop procedure if exists lecturaRecipientes
go
CREATE PROCEDURE lecturaRecipientes
	@recipId INT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    BEGIN TRANSACTION;

    -- Realizar una lectura de datos sin confirmar
    SELECT * FROM recipientes WHERE recipienteId=@recipId;

    -- Hacer commit de la transacción
    COMMIT;
END
go

exec lecturaRecipientes @recipId=10
go

--=============================================================================
--SOLUCION: DIRTY READ
--En este caso la solución es sencillamente cambiar el ISOLATION LEVEL a commited
--de esta forma las columnas que se estan modificando en el stored procedure se bloquearan
--evitando de esta forma acceso a los datos en caso de que ocurra un error

Drop procedure if exists lecturaRecipientesSol
go
CREATE PROCEDURE lecturaRecipientesSol
	@recipId INT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED; --Cambiar a Commited
    BEGIN TRANSACTION;

    -- Realizar una lectura de datos sin confirmar
    SELECT * FROM recipientes WHERE recipienteId=@recipId;

    -- Hacer commit de la transacción
    COMMIT;
END
go

exec lecturaRecipientesSol @recipId=10
go

