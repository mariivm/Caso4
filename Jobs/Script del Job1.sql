--Script de Job de Recompilacion de SP
--Esto existe en los steps del Job1_RecompilacionSP

DECLARE @ProcedureName NVARCHAR(128)

DECLARE curProcedures CURSOR FOR
SELECT [name] FROM sys.procedures

OPEN curProcedures
FETCH NEXT FROM curProcedures INTO @ProcedureName

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC sp_recompile @objname = @ProcedureName
    
    FETCH NEXT FROM curProcedures INTO @ProcedureName
END

CLOSE curProcedures
DEALLOCATE curProcedures