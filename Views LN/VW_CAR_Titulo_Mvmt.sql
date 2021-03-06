﻿-- 06-mai-2014, Fabio Ferreira, Correção timezone
-- #FAF.001 - 08-mai-2014, Fabio Ferreira, 	Retirar tratamento de data/hora	
-- #FAF.002 - 09-mai-2014, Fabio Ferreira, 	Correção titulo referencia	
-- #FAF.005 - 14-mai-2014, Fabio Ferreira, 	Incluido campo módulo do título de referência (sempre 'CR')	
-- #FAF.007 - 17-mai-2014, Fabio Ferreira, 	Correção tpitulo de referência agrupado	
-- #FAF.079 - 26-mai-2014, Fabio Ferreira, 	Alterado o campo SITUACAO_MOVIMENTO para usar o valor da programação de pagamento
-- #FAF.102 - 04-jun-2014, Fabio Ferreira, 	Correção campo COD_DOCUMENTO e alteração de alias		
-- #FAF.148 - 18-jun-2014, Fabio Ferreira, 	Alteração campo NR_MOVIMENTO
-- #FAF.186 - 30-jun-2014, Fabio Ferreira, 	Correção alias e inclusão do número da programação
-- #FAF.186.1 - 01-jul-2014, Fabio Ferreira, 	Padronização de alias CAR CAP e inclusão das datas da agenda
-- #FAF.186.2 - 02-jul-2014, Fabio Ferreira, 	Correção campo CD_TRANSACAO_DOCUMENTO / Correção de duplicidade	
-- #FAF.213 - 	07-jul-2014, Fabio Ferreira, 	Adição do campo CD_TIPO_MOVIMENTO		
-- #FAF.213.1 - 08-jul-2014, Fabio Ferreira, 	Correção NR_TITULO_REFERENCIA	
-- #FAF.213.2 - 11-jul-2014, Fabio Ferreira, 	Correção campo CD_TIPO_MOVIMENTO	
-- #FAF.259 - 	05-aug-2014, Fabio Ferreira, 	Correção titulo referencia	
-- #FAF.274 - 	08-aug-2014, Fabio Ferreira, 	Correção data de atualização			
--****************************************************************************************************************************************************************

SELECT DISTINCT
	1 CD_CIA,
	CASE WHEN nvl((	select c.t$styp from baandb.tcisli205201 c
					where c.t$styp='BL ATC'
					AND c.T$ITYP=tfacr200.t$ttyp
					AND c.t$idoc=tfacr200.t$ninv
					AND rownum=1),' ')=' ' THEN '2' ELSE '3' END CD_FILIAL,
--	tfacr200.t$docn NR_MOVIMENTO,																			--#FAF.186.o
	tfacr200.t$docn NR_MOVIMENTO,																			--#FAF.186.n
--	tfacr200.t$lino NR_MOVIMENTO,
--	nvl(r.t$lino, tfacr200.t$lino) SQ_MOVIMENTO,															--#FAF.186.1.n	--#FAF.186.2.o
	tfacr200.t$lino SQ_MOVIMENTO,																			--#FAF.186.2.n
	tfacr200.t$schn NR_PARCELA,																			--#FAF.186.n
--	CONCAT(tfacr200.t$ttyp, TO_CHAR(tfacr200.t$ninv)) NR_TITULO,											--#FAF.186.1.o
	CONCAT(tfacr200.t$ttyp, TO_CHAR(tfacr200.t$ninv)) CD_CHAVE_PRIMARIA,									--#FAF.186.1.sn
	'CAR' CD_MODULO,
--	tfacr200.t$doct$l COD_DOCUMENTO,																		--#FAF.102.o
	t.t$doct$l CD_TIPO_NF,																					--#FAF.102.n
	tfacr200.t$ttyp CD_TRANSACAO_TITULO,																	--#FAF.186.1.en
	tfacr200.t$trec CD_TIPO_DOCUMENTO,
	CASE WHEN tfacr200.t$amnt<0 THEN '-' ELSE '+' END IN_ENTRADA_SAIDA,
	tfacr200.t$docd DT_TRANSACAO,
	tfacr200.t$amnt VL_TRANSACAO,																			--#FAF.186.o	--#FAF.186.2.n
--	nvl(r.t$amnt*-1, tfacr200.t$amnt)  VL_TRANSACAO,														--#FAF.186.n	--#FAF.186.2.o
	--	tfcmg409.t$stdd SITUACAO_MOVIMENTO,																	--#FAF.079.o
	(select p.t$rpst$l from baandb.ttfacr201201 p
	 where p.t$ttyp=tfacr200.t$ttyp
	 and p.t$ninv=tfacr200.t$ninv 
	 and p.t$schn=tfacr200.t$schn) CD_PREPARADO_PAGAMENTO,													--#FAF.079.n
	CASE WHEN t.t$balc=t.t$bala															-- Liquidado	--#FAF.079.sn
	THEN (select max(t$docd) from baandb.ttfacr200201 m
	 where m.t$ttyp=tfacr200.t$ttyp
	 and m.t$ninv=tfacr200.t$ninv 
	 and m.t$schn=tfacr200.t$schn)
	WHEN t.t$balc=t.t$amnt																-- Nenhum recebimento
	THEN tfacr200.t$docd
	ELSE (select min(t$docd) from baandb.ttfacr200201 m										-- Primeiro rec parcial 
	 where m.t$ttyp=tfacr200.t$ttyp
	 and m.t$ninv=tfacr200.t$ninv 
	 and m.t$schn=tfacr200.t$schn)
	END DT_SITUACAO_MOVIMENTO, 																			--#FAF.079.en
	tfcmg011.t$baoc$l CD_BANCO,
	tfcmg011.t$agcd$l NR_AGENCIA,
	tfcmg001.t$bano NR_CONTA_CORRENTE,																			--#FAF.001.n
	
	GREATEST(																									--#FAF.274.n
	CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(tfacr200.t$rcd_utc, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
		AT time zone 'America/Sao_Paulo') AS DATE), 
	nvl(CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(tfacr201.t$rcd_utc, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
		AT time zone 'America/Sao_Paulo') AS DATE), TO_DATE('01-JAN-1970', 'DD-MON-YYYY')),																							
	nvl(CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(tfcmg001.t$rcd_utc, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
    AT time zone 'America/Sao_Paulo') AS DATE), TO_DATE('01-JAN-1970', 'DD-MON-YYYY')),
	nvl(CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(tfcmg409.t$rcd_utc, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
    AT time zone 'America/Sao_Paulo') AS DATE), TO_DATE('01-JAN-1970', 'DD-MON-YYYY'))) DT_ULT_ATUALIZACAO,
	
	(Select u.t$eunt From baandb.ttcemm030201 u
	 where u.t$euca!=' '
	AND TO_NUMBER(u.t$euca)=CASE WHEN tfacr200.t$dim2=' ' then 999
	WHEN tfacr200.t$dim2<=to_char(0) then 999 
	else TO_NUMBER(tfacr200.t$dim2) END
	and rownum = 1
	) CD_UNIDADE_EMPRESARIAL,
	nvl((select znacr005.t$ttyp$c || znacr005.t$ninv$c from BAANDB.tznacr005201 znacr005				--#FAF.002.sn
		 where znacr005.t$tty1$c=tfacr200.t$ttyp and znacr005.t$nin1$c=tfacr200.t$ninv
		 and znacr005.t$tty2$c=tfacr200.t$tdoc and znacr005.t$nin2$c=tfacr200.t$docn					--#FAF.259.n
		 and znacr005.T$FLAG$C=1																		--#FAF.007.n
		 and rownum=1), 
		 (select rs.t$ttyp || rs.t$ninv from baandb.ttfacr200201 rs											--#FAF.186.2.sn
		  where rs.t$tdoc=tfacr200.t$tdoc 
		  and rs.t$docn=tfacr200.t$docn																	
		  and rs.t$ttyp || rs.t$ninv!=tfacr200.t$ttyp || tfacr200.t$ninv								--#FAF.213.1.n
--		  and rs.t$ttyp!=tfacr200.t$ttyp																--#FAF.213.1.o
--		  and rs.t$ninv!=tfacr200.t$ninv																--#FAF.213.1.o
		  and rs.t$amnt=tfacr200.t$amnt*-1
		  and rownum=1)																					--#FAF.186.2.en
--		 r.t$ttyp || r.t$ninv																			--#FAF.186.2.o
									) NR_TITULO_REFERENCIA,												--#FAF.002.en
	'CAR' CD_MODULO_TITULO_REFERENCIA,																	--#FAF.005.n
	tfacr200.t$ninv NR_TITULO,
--	tfacr200.t$doct$l COD_DOCUMENTO,																		--#FAF.102.o	--#FAF.186.1.o
--	tfacr200.t$doct$l CD_TRANSACAO_DOCUMENTO,																--#FAF.186.1.o
--	tfacr200.t$tdoc CD_TRANSACAO_TITULO,
	--tfacr200.t$dim1 NUM_CONTA																					--#FAF.001.o
	tfacr200.t$tdoc CD_TRANSACAO_DOCUMENTO,																		--#FAF.186.1.n
	tfacr201.t$recd DT_VENCTO_PRORROGADO,																		--#FAF.186.1.sn
	tfacr201.t$dued$l DT_VENCTO_ORIGINAL_PRORROGADO,
	tfacr201.t$liqd DT_LIQUIDEZ_PREVISTA,																		--#FAF.186.1.en
	CASE WHEN tfacr200.t$tdoc='ENC' THEN 5																		--#FAF.213.n
	WHEN (select a.t$catg from baandb.ttfgld011201 a where a.t$ttyp=tfacr200.t$tdoc)=10 THEN 3							--#FAF.213.sn
	WHEN tfacr200.t$tdoc='RGL' THEN 1
	WHEN tfacr200.t$tdoc='LKC' THEN 2
	WHEN tfacr200.t$tdoc='RLA' THEN 2
	WHEN tfacr200.t$tdoc='RRK' THEN 4
	WHEN tfacr200.t$tdoc='RRL' THEN 4
--	WHEN tfacr200.t$tdoc='ENC' THEN 5																			--#FAF.213.o	
	ELSE 0 END	CD_TIPO_MOVIMENTO																				--#FAF.213.en		 	
	
FROM
	baandb.ttfacr200201 tfacr200
--	LEFT JOIN (	select distinct rs.t$ttyp, rs.t$ninv, rs.t$tdoc, rs.t$docn,
--								rs.t$lino, rs.t$amnt														--#FAF.186.1.n	--#FAF.186.2.so
--				from ttfacr200201 rs) r																		--#FAF.002.sn		
--	ON r.t$tdoc=tfacr200.t$tdoc 
--	and r.t$docn=tfacr200.t$docn
--	and r.t$ttyp!=tfacr200.t$ttyp
--	and r.t$ninv!=tfacr200.t$ninv																			--#FAF.002.en	--#FAF.186.2.eo
	
--	LEFT JOIN (select a.t$ttyp, a.t$ninv, a.t$brel FROM ttfacr201201 a										--#FAF.001.sn	--#FAF.186.1.so
--	where a.t$brel!=' '
--	and a.t$schn=(select min(b.t$schn) from ttfacr201201 b
--              where a.t$ttyp=b.t$ttyp
--              and   a.t$ninv=b.t$ninv
--              and   b.t$brel!=' ')) q1 on q1.t$ttyp=tfacr200.t$ttyp and q1.t$ninv=tfacr200.t$ninv			--#FAF.001.en	--#FAF.186.1.eo
	
	LEFT JOIN baandb.ttfacr201201 tfacr201 	ON 	tfacr201.t$ttyp=tfacr200.t$ttyp
										AND tfacr201.t$ninv=tfacr200.t$ninv
										AND tfacr201.t$schn=tfacr200.t$schn

	LEFT JOIN baandb.ttfcmg001201 tfcmg001
--	ON  tfcmg001.t$bank=q1.t$brel																			--#FAF.186.1.o
	ON  tfcmg001.t$bank=tfacr201.t$brel																		--#FAF.186.1.n
	LEFT JOIN baandb.ttfcmg011201 tfcmg011
	ON  tfcmg011.t$bank=tfcmg001.t$brch
	LEFT JOIN baandb.ttfcmg409201 tfcmg409
	ON  tfcmg409.t$btno=tfacr200.t$btno,
	baandb.ttfacr200201 t																							--#FAF.079.n
	
WHERE
      tfacr200.t$docn!=0
AND   t.t$ttyp=tfacr200.t$ttyp																				--#FAF.079.sn
AND   t.t$ninv=tfacr200.t$ninv
AND   t.t$docn=0																							--#FAF.079.en																					--#FAF.079.en