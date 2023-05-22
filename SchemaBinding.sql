--SchemaBinding para la proteccion de la logica de Negocias en tablas necesarias
--Se entiende por logica de negocio de Esencial verde como la recoleccion,recepcion y tratamiento de desechos.
--Se incluye la tabla de ventas como algo temporal,ya que EV puede dejar de vender productos tratados.


create view BusinessLogic
with schemabinding
as
select 
r.localid,r.recipienteid, r.fecha, r.tipoRecepcion, r.productoid,r.pesoRecibido,r.empresaid,o.lote,o.cantidadInicial,
o.productoResult, o.cantidadResult, o.costo, v.fechaVenta, v.cantidadVenta
from dbo.recepcionDesechos r
join dbo.ordenProduccion o on r.productoId = o.productoId
join dbo.ventasProductos v on v.productoId = o.productoId


