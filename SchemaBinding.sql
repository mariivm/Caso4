--SchemaBinding para la proteccion de la logica de Negocias en tablas necesarias
--Se entiende por logica de negocio de Esencial verde como la recoleccion,recepcion y tratamiento de desechos.
--Se incluye la tabla de ventas como algo temporal,ya que EV puede dejar de vender productos tratados.


alter view BusinessLogic
with schemabinding
as
select 
r.localid,r.recipienteid, r.fecha, r.tipoRecepcion, r.productoid,r.pesoRecibido,r.empresaid,o.lote,o.cantidadInicial,
o.productoResult, o.cantidadResult, o.costo, v.fechaVenta, v.cantidadVenta, i.cantidad, c.fechaInicial, c.fechaFinal,
c.status, c.cicloid, cp.costoXcant, p.precio, l.userid, l.accionid, l.recolector
from dbo.recepcionDesechos r
join dbo.ordenProduccion o on r.productoId = o.productoId
join dbo.ventasProductos v on v.productoId = o.productoId
join dbo.inventarioProductos i on i.costo = o.costo
join dbo.contratos c on c.localId = r.localId
join dbo.costoProcesoXmateriales cp on cp.empresaId = r.empresaId
join dbo.precioXproducto p on p.productoId = r.productoId
join dbo.LogMovimientos l on l.localid = r.localId


--Pruebas 
--Colocar Tabla y columna
alter table ordenProduccion
drop column lote;

