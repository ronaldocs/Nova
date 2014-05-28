-- 06-mai-2014, Fabio Ferreira, Altera��o campo tipo de opera��o
--	FAF.003 - 12-mai-2014, Fabio Ferreira, 	Altrada para corrigir registro duplicados devido ao relacionamento com o tipo de opera��o		
--	FAF.005 - 14-mai-2014, Fabio Ferreira,	Retirado campo Data/hora atualiz		
--	FAF.006 - 15-mai-2014, Fabio Ferreira,	Reirado campo tipo opera��o
--	FAF.007 - 15-mai-2014, Fabio Ferreira,	Inclus�o dos campos DESCR_NATUREZA_OPER	 e DESCR_SEQ_NATUREZA_OPER
--****************************************************************************************************************************************************************

-- SELECT 																										--#FAF.003.o
SELECT 	DISTINCT																								--#FAF.003.n
  tcmcs940.t$ofso$l CD_NATUREZA_OPERACAO,
  tcmcs940.t$dsca$l DS_NATUREZA_OPERACAO,																		--#FAF.007.n
  tcmcs940.t$opor$l SQ_NATUREZA_OPERACAO,
  tcmcs964.t$desc$d DS_SEQUENCIA_NATUREZA_OPERACAO,
--  tcmcs947.t$rfdt$l COD_TIPO_OPER,																			--#FAF.005.o
  ' ' DS_OBJETIVO_NATUREZA_OPERACAO   
--	CAST((FROM_TZ(CAST(TO_CHAR(tcmcs940.t$rcd_utc, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.005.o
--		AT time zone sessiontimezone) AS DATE) DT_HR_ATUALIZACAO           										--#FAF.005.o
FROM  ttcmcs940201 tcmcs940,
      ttcmcs947201 tcmcs947,
      ttcmcs964201 tcmcs964
WHERE 	tcmcs964.T$OPOR$D=tcmcs940.T$OPOR$L
AND		  tcmcs947.t$cfoc$l=tcmcs940.t$ofso$l
AND		  tcmcs947.t$tror$l=1
order by 1