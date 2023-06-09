

SELECT pa.nombre as Pais, i.descripcion as Industria, p.nombre as Tipo_residuo, 
    CONVERT(date, rd.fecha) as Fecha, 
    SUM(op.cantidadInicial) AS Total_producido, SUM(op.costo) as Costo, 
    1.30 * SUM(op.costo) as Venta, 1.30 * SUM(op.costo) - SUM(op.costo) as Ganancia
FROM ordenProduccion op
JOIN productos p ON op.productoId = p.productoId
JOIN recepcionDesechos rd ON op.recepcionId = rd.recepcionId
JOIN costoProcesoXmateriales cp ON rd.empresaId = cp.empresaId
JOIN localesXproductor l ON rd.localId = L.localId
JOIN actores a ON l.actorId = a.actorId
JOIN TipoIndustria i ON a.industriaId = i.IndustriaId
JOIN direcciones d ON l.direccionId = d.direccionId
JOIN paises pa on d.paisId = pa.paisId
GROUP BY i.descripcion, p.nombre, pa.nombre, CONVERT(date, rd.fecha) 
ORDER BY pa.nombre, i.descripcion, p.nombre;