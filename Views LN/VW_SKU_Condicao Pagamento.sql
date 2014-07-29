-- #FAF.152, 20-mai-2014, Fabio Ferreira,	Alteração para lfet join com a tabela tdipu010
-- #FAF.191, 01-jul-2014, Fabio Ferreira,	Retirado campo Consignação e adicionado Tipo de ordem						
--**********************************************************************************************************************************************************
SELECT  
        znpur008.t$citg$c CD_DEPARTAMENTO,
        znpur008.t$cpay$c CD_CONDICAO_PAGAMENTO,
        tdipu010.t$sbim COD_COND_PGTO_AUT,
		znpur008.t$potp$c COD_TIPO_OC,																			--#FAF.191.n
--        CASE WHEN tcmcs003.t$tpar$l=1 THEN 1
--        ELSE  2
--        END CONSIGNACAO,																						--#FAF.191.o
        201 CD_CIA,
        tdipu010.t$vlmf$c VL_MINIMO_PEDIDO,
		CAST((FROM_TZ(CAST(TO_CHAR(znpur008.t$rcd_utc, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 
				AT time zone sessiontimezone) AS DATE) DT_ATUALIZACAO,
        tccom100.t$bpid CD_PARCEIRO
FROM    
    baandb.tznpur008201 znpur008
	LEFT JOIN baandb.ttccom130201 tccom130
	ON		znpur008.t$ftyp$c=tccom130.t$ftyp$l
	AND		znpur008.t$fovn$c=tccom130.t$fovn$l
	INNER JOIN baandb.ttccom100201 tccom100
	ON		tccom130.t$cadr=tccom100.t$cadr
	LEFT JOIN baandb.ttdipu010201 tdipu010
	ON   	tccom100.t$bpid=tdipu010.t$otbp
	AND		    znpur008.t$citg$c=tdipu010.t$citg
--	LEFT JOIN ttdipu002201 tdipu002 ON tdipu002.t$citg=tdipu010.t$citg AND tdipu002.t$kitm=1					--#FAF.191.so
--	LEFT JOIN ttcmcs003201 tcmcs003 ON tcmcs003.t$cwar=tdipu002.t$cwar											--#FAF.191.eo

