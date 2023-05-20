USE [elementalGDB]
GO
/****** Object:  StoredProcedure [dbo].[spContratosfill]    Script Date: 5/20/2023 3:23:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[spContratosfill] with encryption as begin
	declare @contador int;
	set @contador =1;
	declare @actorid int;
	declare @contratoid int;
	declare @cicloid int;


	while (@contador <= 100) begin 
		select @actorid = actorid from localesXproductor where localId = @contador;
		select @contratoid = contratoid from contratosGenerales where actorId = @actorid;
		select @cicloid = cicloid from cicloRecoleccion where localId = @contador;

		insert into contratos (contratoId, empresaId, fechaInicial, fechaFinal,status, cicloId, localId, enabled ) values
		(@contratoid, @contador, '2023-01-01', '2024-01-01',1, @cicloid, @contador, 1)

		set @contador = @contador +1;
	end 
end 

