-- 05-MAI-2014, Fabio Ferreira, Retirado campo DATA_CADASTRO
--***************************************************************************************************************************************************************
SELECT
	znint002.t$uneg$c CD_UNIDADE_NEGOCIO,
	znint002.t$ncia$c IN_SITE_CIA,
	znint002.t$desc$c NM_UNIDADE_NEGOCIO,
	CASE WHEN InStr(znint002.t$desc$c, 'B2B', 1, 1)>0 THEN 'B2B'
      WHEN InStr(znint002.t$desc$c, 'B2C', 1, 1)>0 THEN 'B2C'
	ELSE ' '
	END NM_TIPO_VENDA,
--	SYSDATE DATA_CADASTRO,        -- *** PEDENTE DE ATIVA��O NA TABELA
	CAST((FROM_TZ(CAST(TO_CHAR(znint002.t$rcd_utc, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 
			AT time zone sessiontimezone) AS DATE) DT_ATUALIZACAO
FROM tznint002201 znint002
