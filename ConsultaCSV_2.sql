--SELECTS PARA  CSV DE NEO4J #2
SELECT ac.descripcion as Productor,re.nombre as Ciudad, CAST(sum(rd.pesoRecibido) as INT) as Volumen, 
ev.empresaId as Recolectora
FROM recepcionDesechos rd 
JOIN empresasEV ev on rd.empresaId = ev.empresaId
JOIN localesXproductor lo on rd.localId = lo.localId
JOIN actores ac on lo.actorId = ac.actorId
JOIN productos pr on pr.productoId = rd.productoId
JOIN direcciones dr on lo.direccionId = dr.direccionId
JOIN regiones re on dr.regionId = re.regionId
GROUP BY ac.descripcion,re.nombre, ev.empresaId