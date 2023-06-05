-- Caso 4/Entrega Final


--Punto 1.a 
--Se le niega el acceso de todas las tablas a un usuario
USE elementalGDB;
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO mariana_viquez;
go 

--Creacion de un procedure para probar que puede accesar tablas por medio del sp
alter procedure userAccess as begin
	select * from actores;
end;

--Grant del permiso sobre el sp
GRANT EXECUTE ON userAccess TO mariana_viquez;

--Las pruebas se hacen con el usuario mariana_viquez
exec userAccess
select * from actores 

--Punto 1.b
GRANT SELECT ON contratos TO mariana_viquez2;
--Denegar el acceso a columnas de tabla contratos
DENY SELECT ON contratos (fechaInicial,fechaFinal,status,cicloid,enabled) TO mariana_viquez2;

--Pruebas con mariana_viquez2
select contratoId, empresaId, localId from contratos
select * from contratos

--Punto 1.c
--Denegando permisos totales a la tabla de actores a los usuarios bajo el rol Denegados
GRANT SELECT ON inventarioProductos TO Denegados;
DENY SELECT, INSERT, UPDATE, DELETE ON  actores TO Denegados;


--Pruebas con mariana_viquez3
select * from inventarioProductos;
select * from actores;




