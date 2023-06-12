--SELECTS PARA  CSV DE NEO4J 
SELECT re.nombre as Ciudad, CAST(sum(rd.pesoRecibido) as INT) as Volumen, 
ev.empresaId as Recolectora
FROM recepcionDesechos rd 
JOIN empresasEV ev on rd.empresaId = ev.empresaId
JOIN localesXproductor lo on rd.localId = lo.localId
JOIN productos pr on pr.productoId = rd.productoId
JOIN direcciones dr on lo.direccionId = dr.direccionId
JOIN regiones re on dr.regionId = re.regionId
GROUP BY re.nombre, ev.empresaId


