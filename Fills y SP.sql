-- procedure insertar en costoxprocesoxmateriales
alter procedure fillcpxm as begin
	declare @c1 int;
	declare @c2 int;
	declare @costo int;
	declare @venta int;

	set @c1 = 1
	while (@c1 <=100) begin
		set @c2 = 1
		while (@c2 <=15) begin
			set @costo = FLOOR(ROUND(RAND()*(401)+100, -2))
			set @venta = @costo * 1.30;

			insert into costoProcesoXmateriales (productoId, cantidadBase, costoXcant, costoVenta, empresaId, fechaInicial, fechaFinal, checksum)
			values
			(@c2, 1, @costo, @venta,@c1, '2023-01-01', '2999-12-12', 0x0102030405)

			set @c2 = @c2 +1
		end;

		set @c1 = @c1+1;
	end 

end;

exec fillcpxm


--insertar en tipoIndustria 
insert into TipoIndustria(IndustriaId, descripcion) values
(1,'Alimentaria'),
(2, 'Comida Rapida'),
(3, 'Distribucion Digital'),
(4, 'Minorista Comercial');

--Agregarle las industrias a nuestros productores de residuo
update actores set industriaId = 1 where actorId = 3
update actores set industriaId = 2 where actorId = 1 
update actores set industriaId = 2 where actorId = 2
update actores set industriaId = 2 where actorId = 4
update actores set industriaId = 3 where actorId = 5
update actores set industriaId = 4 where actorId = 6


--Altero este procedure
ALTER PROCEDURE [dbo].[llenarRecepcionDesechos]
 AS
 BEGIN
  DECLARE @contador int;
  SET @contador = 1;
  DECLARE @localid int;
  DECLARE @recipienteid int;
  DECLARE @recepcionid int;
  DECLARE @fecha datetime;
  declare @tipoRecepcion smallint;
  declare @productoId int;
  declare @pesoRecibido decimal(8,2);
  declare @empresaid int;
  declare @checksum varbinary(150);
  set @fecha = '2023-01-01'

  WHILE (@contador <= 1000)
  BEGIN
	
	    set @localid = FLOOR(RAND()*(100-1+1)+1);
		set @recipienteid = FLOOR(RAND()*(10000-1+1)+1);
		SET @fecha = DATEADD(DAY, 1, @fecha); 
		set @tipoRecepcion = FLOOR(RAND()*(2-1+1)+1);
		set @recepcionId = @contador;
		set @productoId = FLOOR(RAND()*(15-1+1)+1);
		set @pesoRecibido = FLOOR(RAND()*(20-1+1)+1);
		set @empresaid = FLOOR(RAND()*(100-1+1)+1);
		SET @checksum = 0x0102030405;

		INSERT INTO recepcionDesechos(localId, recipienteId, recepcionId, fecha, tipoRecepcion, productoId, pesoRecibido, empresaId, checksum)
		VALUES (@localid, @recipienteid,@recepcionid, @fecha, @tipoRecepcion, @productoId, @pesoRecibido, @empresaid, @checksum);
	
    SET @contador = @contador + 1;
  END
 END

delete from ventasProductos
delete from recepcionDesechos
delete from ordenProduccion
delete from inventarioProductos
exec llenarRecepcionDesechos


ALTER PROCEDURE [dbo].[llenarOrdenProduccionInventario]
 AS
 BEGIN
  DECLARE @contador int;
  SET @contador = 1;
  DECLARE @lote int;
  declare @productoid int;
  declare @cantidadInicial decimal(8,2)
  declare @productoResult int;
  declare @cantidadResult int;
  declare @costo int;
  declare @empresaid int;


  WHILE (@contador <= 1000)
  BEGIN
		--lote
	    set @lote = @contador + 1234;
		--producto
		SELECT @productoid = productoid FROM recepcionDesechos WHERE recepcionId = @contador;
		--cantidadInicial
		SELECT @cantidadInicial = pesoRecibido FROM recepcionDesechos WHERE recepcionId = @contador;

		--Se define productoResult y cantidadResult
		if (Select tipoRecepcion from recepcionDesechos where recepcionId = @contador) = 1
		begin
			set @productoResult = @productoid
			set @cantidadResult = @cantidadInicial * 0.5
		end

		else 
		begin
			set @productoResult = FLOOR(RAND()*(15-1+1)+1);
			set @cantidadResult =  FLOOR(RAND()*(20-1+1)+1);
		end


		--costo
		SELECT @empresaid = empresaid from recepcionDesechos where recepcionId = @contador;
		SELECT @costo =  costoXcant from costoProcesoXmateriales where empresaId = @empresaid and productoId = @productoid;
		set @costo = @costo * @cantidadInicial



		INSERT INTO ordenProduccion(lote,recepcionId,productoId,cantidadInicial,productoResult,cantidadResult, costo,actorId)
		VALUES (@lote, @contador, @productoid, @cantidadInicial, @productoResult, @cantidadResult, @costo, null);

	
    SET @contador = @contador + 1;
  END
 END
 
 exec llenarOrdenProduccionInventario
 select * from ordenProduccion
 select * from recepcionDesechos
 select * from costoProcesoXmateriales