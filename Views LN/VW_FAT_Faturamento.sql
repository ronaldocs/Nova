﻿-- 05-mai-2014, Fabio Ferreira, Retirados os campos COD_PAIS_FATURA, COD_ESTADO_FATURA, COD_CEP_FATURA, COD_PAIS_ENTREGA, COD_ESTADO_ENTREGA, COD_CEP_ENTREGA,
-- Inclusão dos campos VALOR_TOTAL_MERCADOR, CPF/CNPJ CLIENTE FATURA, TIPO CLENTE
-- 06-mai-2014, Fabio Ferreira, Correcção timezone ULTIMA_ATUALIZACAO, DATA_FATURA, DT_ENTREGA
-- Correção formatação campo PEDIDO_ENTREGA;
-- Correção informação da quantidade de volumes
-- 07-mai-2014, Fabio Ferreira, Incluído campo COD_CIDADE_ENTREGA (Excluido indevidamente)
-- Corrigido campo VALOR_CMV
-- #FAF.007 - 17-mai-2014, Fabio Ferreira, Retirado campo PEDIDO_ENTREGA;
-- #FAF.008 - 17-mai-2014, Fabio Ferreira, Incluida condição para evitar divisão por zero
-- #FAF.063 - 22-mai-2014, Fabio Ferreira, Alterado o código da transportadora para o código do parceiro
-- #FAF.083 - 26-mai-2014, Fabio Ferreira, Campo NUM_ENTREGA convertido para string
-- #FAF.087 - 29-mai-2014, Fabio Ferreira, Correções de informações que estavam pendente do financeiro
-- #FAF.125 - 10-jun-2014, Fabio Ferreira, Correções impostos frete
-- #FAF.138 - 13-jun-2014, Fabio Ferreira, Correção campo CD_VENDEDOR
-- #FAF.151 - 20-jun-2014, Fabio Ferreira, Tratamento para o CNPJ
-- #FAF.169 - 24-jun-2014, Fabio Ferreira, Mostrar linha da NF de remessa e fatura
-- #FAF.172 - 24-jun-2014, Fabio Ferreira, Inclusão do campo referencia fiscal
-- #FAF.173 - 25-jun-2014, Fabio Ferreira, Correção duplicidade
-- #FAF.176 - 25-jun-2014, Fabio Ferreira, Inclusão do campo CD_STATUS_SEFAZ, filtro status e sefaz
-- #FAF.180 - 27-jun-2014, Fabio Ferreira, Inclusão do campo VL_JUROS E VL_JUROS_ADMINISTRADORA
-- #FAF.190 - 01-jul-2014, Fabio Ferreira, Filtro de status SEFAZ alterado para mostrar status 1 (nenhum)
-- #FAF.195 - 02-jul-2014, Fabio Ferreira, Inclusão do campo CD_PRODUTO
-- #FAF.201 - 03-jul-2014, Fabio Ferreira, Correção diplicidade devido a inclusão do campo VL_JUROS E VL_JUROS_ADMINISTRADORA #180
-- #FAF.249 - 30-jul-2014, Fabio Ferreira, Ajuste Natureza daa operação e sequencia
-- #MAT.001 - 31-jul-2014, Marcia A. Torres, Correção do campo DT_ATUALIZACAO
-- #FAF.253 - 13-aug-2014, Fabio Ferreira, Inclusão do camopo ref fiscal e linha de fatura
-- #FAF.299 - 25-aug-2014, Fabio Ferreira, Correção campo VL_TOTAL_ITEM
-- #FAF.301 - 25-aug-2014, Fabio Ferreira, Correção impostos
-- #FAF.303 - 25-aug-2014, Fabio Ferreira, Correção despesas
-- #MAR.307 - 28-ago-2014, Marcia A. R. Torres, Inclusao do TIPO_ORDEM_VENDA.
-- #FAF.303 - 29-aug-2014, Fabio Ferreira, Rateio do valor do juros
-- #FAF.303.2 - 02-set-2014, Fabio Ferreira, Alteração rateio de juros
-- #FAF.303.2 - 04-set-2014, Fabio Ferreira, Valor despesa financeira=jusro
-- #FAF.320 - 05-set-2014, Fabio Ferreira, Tratamento de divisão por zero.
-- #FAF.321 - 08-set-2014, Fabio Ferreira, Alteração relacionamento
-- #FAF.323 - 11-set-2014, Fabio Ferreira, Tratamento de divisão por zero.
-- #MAR.329 - 22-set-2014, Marcia A. R. Torres, Correção Base de Cálculo ICMS.
--****************************************************************************************************************************************************************
SELECT
  CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cisli940.t$rcd_utc, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
  AT time zone 'America/Sao_Paulo') AS DATE) DT_ULT_ATUALIZACAO,
  znsls400.t$ncia$c CD_CIA,
  CASE WHEN (	SELECT tcemm030.t$euca FROM baandb.ttcemm124201 tcemm124, baandb.ttcemm030201 tcemm030	--#FAF.303.1.sn
  WHERE tcemm124.t$cwoc=cisli940.t$cofc$l
  AND tcemm030.t$eunt=tcemm124.t$grid
  AND tcemm124.t$loco=201
  AND rownum=1) = ''
THEN
  (	SELECT substr(tcemm124.t$grid,-2,2) FROM baandb.ttcemm124201 tcemm124
  WHERE tcemm124.t$cwoc=cisli940.t$cofc$l
  AND tcemm124.t$loco=201
  AND rownum=1)
ELSE (	SELECT tcemm030.t$euca FROM baandb.ttcemm124201 tcemm124, baandb.ttcemm030201 tcemm030
        WHERE tcemm124.t$cwoc=cisli940.t$cofc$l
        AND tcemm030.t$eunt=tcemm124.t$grid
        AND tcemm124.t$loco=201
        AND rownum=1)
  END AS CD_FILIAL,	--#FAF.303.en
  cisli940.t$docn$l NR_NF,
  cisli940.t$seri$l NR_SERIE_NF,
  CASE WHEN instr(cisli940.t$ccfo$l,'-')=0 THEN cisli940.t$ccfo$l
                                           ELSE regexp_replace(substr(cisli940.t$ccfo$l,0,instr(cisli940.t$ccfo$l,'-')-1), '[^0-9]', '')
  END	CD_NATUREZA_OPERACAO,	--#FAF.249.n
  CASE WHEN instr(cisli940.t$ccfo$l,'-')=0 THEN cisli940.t$opor$l
       ELSE regexp_replace(substr(cisli940.t$ccfo$l,instr(cisli940.t$ccfo$l,'-')+1,3), '[^0-9]', '')
  END	SQ_NATUREZA_OPERACAO,	--#FAF.249.n
  CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cisli940.t$datg$l, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
  AT time zone 'America/Sao_Paulo') AS DATE) DT_FATURA,
  cisli940.t$itbp$l CD_CLIENTE_FATURA,
  cisli940.t$stbp$l CD_CLIENTE_ENTREGA,
  znsls401.t$sequ$c NR_SEQ_ENTREGA,
  znsls401.t$pecl$c NR_PEDIDO,
  TO_CHAR(znsls401.t$entr$c) NR_ENTREGA, --#FAF.083.n
  znsls401.t$orno$c NR_ORDEM,	-- origem OV
  CASE WHEN cisli940.t$fdty$l=15 then (select distinct a.t$docn$l from baandb.tcisli940201 a, baandb.tcisli941201 b
                                                                where b.t$fire$l=cisli940.t$fire$l
                                                                and a.t$fire$l=b.t$refr$l and rownum=1) else 0
  end NR_NF_FATURA,
  CASE WHEN cisli940.t$fdty$l=15 then (select distinct a.t$seri$l from baandb.tcisli940201 a, baandb.tcisli941201 b
                                                                  where b.t$fire$l=cisli940.t$fire$l
                                                                  and a.t$fire$l=b.t$refr$l and rownum=1) else ' '
  end NR_SERIE_NF_FATURA,
  CASE WHEN cisli940.t$fdty$l=16 then (select distinct a.t$docn$l from baandb.tcisli940201 a, baandb.tcisli941201 b
                                                                  where b.t$fire$l=cisli940.t$fire$l and a.t$fire$l=b.t$refr$l and rownum=1) else 0
  end NR_NF_REMESSA,
  CASE WHEN cisli940.t$fdty$l=16 then (select distinct a.t$seri$l from baandb.tcisli940201 a, baandb.tcisli941201 b 
                                                                  where b.t$fire$l=cisli940.t$fire$l
                                                                  and a.t$fire$l=b.t$refr$l and rownum=1) else ' '
  end NR_SERIE_NF_REMESSA,
  CASE WHEN tdsls094.t$bill$c!=3 THEN consold.NOTA ELSE 0 
  END NR_NF_CONSOLIDADA, --#FAF.087.n
  CASE WHEN tdsls094.t$bill$c!=3 THEN consold.SERIE ELSE ' ' 
  END NR_SERIE_NF_CONSOLIDADA, --#FAF.087.n
  cisli940.t$stat$l CD_SITUACAO_NF,
  (Select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(max(brnfe020.t$date$l), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
   AT time zone 'America/Sao_Paulo') AS DATE)
   FROM baandb.tbrnfe020201 brnfe020
   Where brnfe020.t$refi$l=cisli940.t$fire$l AND brnfe020.t$ncmp$l=201) 
  AS DT_STATUS,
  cisli940.t$fdty$l CD_TIPO_NF,
  ltrim(rtrim(cisli941f.t$item$l)) CD_ITEM,
  cisli941f.t$dqua$l QT_FATURADA,
  nvl(ICMS.t$amnt$l, 0) VL_ICMS,	--#FAF.201.n
  Nvl((SELECT cisli943.t$amnt$l from baandb.tcisli943201 cisli943 WHERE cisli943.t$fire$l=cisli941f.t$fire$l
                                                                  AND cisli943.t$line$l=cisli941f.t$line$l
                                                                  AND cisli943.t$brty$l=2),0) 
  AS VL_ICMS_ST,
  cisli941f.t$gamt$l VL_PRODUTO,
  znsls401.t$vlfr$c VL_FRETE,
  nvl((select sum(f.t$vlfc$c) from baandb.tznfmd630201 f where f.t$fire$c=cisli940.t$fire$l),0) * (cisli941f.t$gamt$l/nvl((select sum(cisli941b.t$gamt$l)
                              from baandb.tcisli941201 cisli941b, baandb.ttcibd001201 tcibd001b
                              where cisli941b.t$fire$l=cisli941f.t$fire$l
                              and cisli941b.t$line$l=cisli941f.t$line$l
                              and tcibd001b.T$ITEM=cisli941b.t$item$l
                              and cisli941b.t$gamt$l!=0 --#FAF.008.n
                              and tcibd001b.t$kitm<3),1)) 
  AS VL_FRETE_CIA,
  TRUNC(case when cisli941.t$item$l not in	
        (select a.t$itjl$c
        from baandb.tznsls000201 a
        where a.t$indt$c=(select min(b.t$indt$c) from baandb.tznsls000201 b)
    UNION ALL
    select a.t$itmd$c
    from baandb.tznsls000201 a
    where a.t$indt$c=(select min(b.t$indt$c) from baandb.tznsls000201 b)
    UNION ALL
    select a.t$itmf$c
    from baandb.tznsls000201 a
    where a.t$indt$c=(select min(b.t$indt$c) from baandb.tznsls000201 b))
    then
    case when (cisli940.t$gamt$l!=0 and cisli941.t$gamt$l!=0) then
    nvl((select sum(c.t$amnt$l) from baandb.tcisli941201 c
    where c.t$fire$l=cisli941.t$fire$l
    and c.t$item$l=(select a.t$itmd$c
                    from baandb.tznsls000201 a
                    where a.t$indt$c=(select min(b.t$indt$c) from baandb.tznsls000201 b))),0)/ (cisli941.t$gamt$l/cisli940.t$gamt$l)
                    else 0 end
                    else 0 end,2) 
  AS VL_DESPESA,
  cisli941f.t$ldam$l VL_DESCONTO,
  cisli941f.t$amnt$l VL_TOTAL_ITEM,	
  trunc(case when cisli941.t$item$l not in (select a.t$itjl$c
                                            from baandb.tznsls000201 a
                                            where a.t$indt$c=(select min(b.t$indt$c) from baandb.tznsls000201 b)
  UNION ALL
    select a.t$itmd$c
    from baandb.tznsls000201 a
    where a.t$indt$c=(select min(b.t$indt$c) from baandb.tznsls000201 b)
  UNION ALL
    select a.t$itmf$c
    from baandb.tznsls000201 a
    where a.t$indt$c=(select min(b.t$indt$c) from baandb.tznsls000201 b))
    then
    case when (cisli940.t$gamt$l!=0 and cisli941.t$gamt$l!=0) then
    nvl((select sum(c.t$amnt$l) from baandb.tcisli941201 c
    where c.t$fire$l=cisli941.t$fire$l
    and c.t$item$l=(select a.t$itjl$c
    from baandb.tznsls000201 a
    where a.t$indt$c=(select min(b.t$indt$c) from baandb.tznsls000201 b))),0)/ (cisli941.t$gamt$l/cisli940.t$gamt$l)
    else 0 end
    else 0 end,2) 
  AS VL_DESPESA_FINANCEIRA,	
  nvl(PIS.t$amnt$l,0) VL_PIS,
  cisli941f.t$iprt$l*(nvl(ICMS.t$rate$l,0)/100) VL_ICMS_PRODUTO,
  cisli941f.t$fght$l*(nvl(ICMS.t$rate$l,0)/100) VL_ICMS_FRETE,
    CASE WHEN cisli941f.t$insr$l+cisli941f.t$gexp$l+cisli941f.t$cchr$l>0 THEN	--#FAF.201.sn
    nvl(ICMS.t$amnt$l, 0)	  -cisli941f.t$iprt$l*(nvl(ICMS.t$rate$l,0)/100) -cisli941f.t$fght$l*(nvl(ICMS.t$rate$l,0)/100)
    ELSE 0 END	
  AS VL_ICMS_OUTROS,	
  nvl(COFINS.t$amnt$l,0) VL_COFINS,	--#FAF.201.n
  cisli941f.t$iprt$l*(nvl(COFINS.t$rate$l,0)/100) VL_COFINS_PRODUTO, --#FAF.201.n
  cisli941f.t$fght$l*(nvl(COFINS.t$rate$l,0)/100) VL_COFINS_FRETE, --#FAF.201.n
    CASE WHEN cisli941f.t$insr$l+cisli941f.t$gexp$l+cisli941f.t$cchr$l>0 THEN	--#FAF.201.sn
    nvl(COFINS.t$amnt$l, 0) -cisli941f.t$iprt$l*(nvl(COFINS.t$rate$l,0)/100) -cisli941f.t$fght$l*(nvl(COFINS.t$rate$l,0)/100)
    ELSE 0 END	VL_COFINS_OUTROS,	
    cisli941f.t$iprt$l*(nvl(PIS.t$rate$l,0)/100) VL_PIS_PRODUTO,	--#FAF.201.n
    cisli941f.t$fght$l*(nvl(PIS.t$rate$l,0)/100) VL_PIS_FRETE,	--#FAF.201.n
    CASE WHEN cisli941f.t$insr$l+cisli941f.t$gexp$l+cisli941f.t$cchr$l>0 THEN	nvl(PIS.t$amnt$l, 0) -cisli941f.t$iprt$l*(nvl(PIS.t$rate$l,0)/100) -cisli941f.t$fght$l*(nvl(PIS.t$rate$l,0)/100)
    ELSE 0 END 
  AS 	VL_PIS_OUTROS, 
  nvl(CSLL.t$amnt$l,0) VL_CSLL,	
  cisli941f.t$iprt$l*(nvl(CSLL.t$rate$l,0)/100) VL_CSLL_PRODUTO,	--#FAF.201.n
  cisli941f.t$fght$l*(nvl(CSLL.t$rate$l,0)/100) VL_CSLL_FRETE,	--#FAF.201.n
    CASE WHEN cisli941f.t$insr$l+cisli941f.t$gexp$l+cisli941f.t$cchr$l>0 THEN 
    nvl(CSLL.t$amnt$l, 0) -cisli941f.t$iprt$l*(nvl(CSLL.t$rate$l,0)/100) -cisli941f.t$fght$l*(nvl(CSLL.t$rate$l,0)/100)
    ELSE 0 END	VL_CSLL_OUTROS, --#FAF.201.en
    cisli941f.t$tldm$l VL_DESCONTO_INCONDICIONAL,
    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(znsls400.t$dtin$c, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') AT time zone 'America/Sao_Paulo') AS DATE) 
  AS DT_PEDIDO,
  znsls400.t$idca$c CD_CANAL,
  endfat.t$ccit CD_CIDADE_FATURA,
  endent.t$ccit CD_CIDADE_ENTREGA,
  nvl((select sum(b.t$mauc$1) from baandb.twhina114201 a, baandb.twhina113201 b
       where b.t$item=A.T$ITEM
       and b.T$CWAR=a.t$cwar
       and b.T$TRDT=A.T$TRDT
       and b.t$seqn=A.T$SEQN
       and b.T$INWP=A.T$INWP
       and a.t$orno=tdsls401.t$orno
       and a.t$pono=tdsls401.t$pono),0) 
  AS VL_CMV,
  znsls401.t$uneg$c CD_UNIDADE_NEGOCIO,
  ' ' CD_MODULO_GERENCIAL, -- *** AGUARDANDO DUVIDAS
    CASE WHEN instr(cisli941f.t$ccfo$l,'-')=0 THEN cisli941f.t$ccfo$l
                                              ELSE regexp_replace(substr(cisli941f.t$ccfo$l,0,instr(cisli941f.t$ccfo$l,'-')-1), '[^0-9]', '')
  END	CD_NATUREZA_OPERACAO_ITEM,	
    CASE WHEN instr(cisli941f.t$ccfo$l,'-')=0 THEN cisli941f.t$opor$l
                                              ELSE regexp_replace(substr(cisli941f.t$ccfo$l,instr(cisli941f.t$ccfo$l,'-')+1,3), '[^0-9]', '')
  END	SQ_NATUREZA_OPERACAO_ITEM,	
    CASE WHEN znsls400.t$cven$c=100 THEN NULL ELSE znsls400.t$cven$c END 
  AS CD_VENDEDOR,
  nvl(ICMS.t$fbtx$l,0) VL_BASE_ICMS,	
  Nvl((SELECT cisli943.t$base$l from baandb.tcisli943201 cisli943
       WHERE cisli943.t$fire$l=cisli941f.t$fire$l
       AND cisli943.t$line$l=cisli941f.t$line$l
       AND cisli943.t$brty$l=3),0) VL_BASE_IPI,
       nvl((select t.t$suno from baandb.ttcmcs080201 t where t.t$cfrw=cisli940.t$cfrw$l and rownum=1),' ') 
  AS CD_TRANSPORTADORA, --#FAF.063.n
    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(znsls401.t$dtep$c, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') AT time zone 'America/Sao_Paulo') AS DATE) 
  AS DT_ENTREGA,
    (Select sum(znfmd630.t$qvol$c) From baandb.tznfmd630201 znfmd630 WHERE znfmd630.t$fire$c=cisli941f.t$fire$l and rownum=1) 
  AS QT_VOLUME,
  cisli940.t$gwgt$l VL_PESO_BRUTO,
  cisli940.t$nwgt$l VL_PESO_LIQUIDO,
  znsls401.t$itpe$c CD_TIPO_ENTREGA,
  tcibd001.t$tptr$c CD_TIPO_TRANSPORTE,
  znsls400.t$idli$c NR_LISTA_CASAMENTO,
    (SELECT tcemm124.t$grid FROM baandb.ttcemm124201 tcemm124
     WHERE tcemm124.t$cwoc=cisli940.t$cofc$l
    AND tcemm124.t$loco=201 AND rownum=1) 
  AS CD_UNIDADE_EMPRESARIAL,
    (select CASE WHEN regexp_replace(e.t$fovn$l, '[^0-9]', '') IS NULL
            THEN '00000000000000'
            WHEN LENGTH(regexp_replace(e.t$fovn$l, '[^0-9]', ''))<11
            THEN '00000000000000'
            ELSE regexp_replace(e.t$fovn$l, '[^0-9]', '') END --#FAF.151.n
            from baandb.ttccom130201 e where e.t$cadr=cisli940.t$stoa$l and rownum=1) 
  AS NR_CNPJ_CPF_ENTREGA,
    (select e.t$ftyp$l from baandb.ttccom130201 e where e.t$cadr=cisli940.t$stoa$l and rownum=1) 
  AS CD_TIPO_CLIENTE_ENTREGA,
    (select CASE WHEN regexp_replace(e.t$fovn$l, '[^0-9]', '') IS NULL
            THEN '00000000000000'
            WHEN LENGTH(regexp_replace(e.t$fovn$l, '[^0-9]', ''))<11
            THEN '00000000000000'
            ELSE regexp_replace(e.t$fovn$l, '[^0-9]', '') END --#FAF.151.n
            from baandb.ttccom130201 e where e.t$cadr=cisli940.t$itoa$l and rownum=1) 
  AS NR_CNPJ_CPF_FATURA,
    (select e.t$ftyp$l from baandb.ttccom130201 e where e.t$cadr=cisli940.t$itoa$l and rownum=1) 
  AS CD_TIPO_CLIENTE_FATURA,
  cisli941f.t$fire$l NR_REFERENCIA_FISCAL, --#FAF.172.n
  cisli940.t$nfes$l CD_STATUS_SEFAZ,	--#FAF.176.n
    trunc(case when cisli941.t$item$l not in (select a.t$itjl$c
                                              from baandb.tznsls000201 a
                                              where a.t$indt$c=(select min(b.t$indt$c) from baandb.tznsls000201 b)
    UNION ALL
    select a.t$itmd$c
    from baandb.tznsls000201 a
    where a.t$indt$c=(select min(b.t$indt$c) from baandb.tznsls000201 b)
    UNION ALL
    select a.t$itmf$c
    from baandb.tznsls000201 a
    where a.t$indt$c=(select min(b.t$indt$c) from baandb.tznsls000201 b))
    then
    case when (cisli940.t$gamt$l!=0 and cisli941.t$gamt$l!=0) then
    nvl((select sum(c.t$amnt$l) from baandb.tcisli941201 c
    where c.t$fire$l=cisli941.t$fire$l
    and c.t$item$l=(select a.t$itjl$c
    from baandb.tznsls000201 a
    where a.t$indt$c=(select min(b.t$indt$c) from baandb.tznsls000201 b))),0)/ (cisli941.t$gamt$l/cisli940.t$gamt$l)
    else 0 end
    else 0 end,2) 
  AS VL_JUROS,
    CASE WHEN cisli940.t$gamt$l!=0 THEN --#FAF.180.n
    case when cisli940.t$gamt$l!=0 then
    TRUNC(znsls402.t$vlja$c*(cisli941.t$gamt$l/cisli940.t$gamt$l) ,2)
    else 0 end
    ELSE znsls402.t$vlja$c END 
  AS VL_JUROS_ADMINISTRADORA,	
    CASE WHEN znsls401.t$igar$c=0 THEN ltrim(rtrim(tdsls401.t$item))
    ELSE TO_CHAR(znsls401.t$igar$c) END 
  AS CD_PRODUTO,	
    CASE WHEN (cisli940.t$fdty$l=15 or cisli940.t$fdty$l=16) then cisli941f.t$refr$l
    ELSE NULL END 
  AS	NR_REFERENCIA_FISCAL_FATURA,
    CASE WHEN (cisli940.t$fdty$l=15 or cisli940.t$fdty$l=16) then cisli941f.t$rfdl$l
    ELSE NULL END 
  AS	NR_ITEM_NF_FATURA,	--#FAF.253.en
  tdsls400.t$sotp CD_TIPO_ORDEM_VENDA --#MAR.307.n
  --INICIO DO FROM
FROM baandb.tcisli940201 cisli940,
     baandb.tcisli941201 cisli941,	
     baandb.tcisli941201 cisli941f --#FAF.169.n
LEFT JOIN baandb.tcisli943201 ICMS	ON ICMS.t$fire$l=cisli941f.t$fire$l	--#FAF.201.sn
     AND	ICMS.t$line$l=cisli941f.t$line$l
     AND ICMS.t$brty$l=1
LEFT JOIN baandb.tcisli943201 COFINS ON COFINS.t$fire$l=cisli941f.t$fire$l	
     AND	COFINS.t$line$l=cisli941f.t$line$l
     AND COFINS.t$brty$l=6
LEFT JOIN baandb.tcisli943201 PIS ON PIS.t$fire$l=cisli941f.t$fire$l	
     AND	PIS.t$line$l=cisli941f.t$line$l
     AND PIS.t$brty$l=5
LEFT JOIN baandb.tcisli943201 CSLL ON CSLL.t$fire$l=cisli941f.t$fire$l	
     AND	CSLL.t$line$l=cisli941f.t$line$l
     AND CSLL.t$brty$l=13,
baandb.tcisli245201 cisli245,
baandb.ttdsls401201 tdsls401,
baandb.tznsls004201 znsls004,	--Origem OV
baandb.tznsls401201 znsls401,
baandb.tznsls400201 znsls400,
(select 
    znsls402q.t$ncia$c,
    znsls402q.t$uneg$c,
    znsls402q.t$pecl$c,
    znsls402q.t$sqpd$c,
    sum(znsls402q.t$vlju$c) t$vlju$c,
    sum(znsls402q.t$vlja$c) t$vlja$c
 from	baandb.tznsls402201 znsls402q
  group by
    znsls402q.t$ncia$c,
    znsls402q.t$uneg$c,
    znsls402q.t$pecl$c,
    znsls402q.t$sqpd$c) znsls402,	--#FAF.201.en
baandb.ttdsls400201 tdsls400 --#FAF.087.sn
LEFT JOIN ( select c245.T$SLSO, c940.T$DOCN$L NOTA, c940.t$seri$l SERIE
            from baandb.tcisli245201 c245
            inner join baandb.tcisli941201 c941 on c941.t$fire$l=c245.T$FIRE$L   
            inner join baandb.tcisli940201 c940
            on c940.t$fire$l=c941.T$REFR$L
            group by c245.T$SLSO, c940.T$DOCN$L, c940.t$seri$l
            ) consold ON consold.T$SLSO=tdsls400.t$orno, --#FAF.087.en
baandb.ttccom130201 endfat,
baandb.ttccom130201 endent,
baandb.ttcibd001201 tcibd001,
baandb.ttdsls094201 tdsls094 --#FAF.087.n
WHERE cisli941f.t$fire$l=cisli940.t$fire$l
  AND cisli245.t$fire$l=cisli941.t$fire$l
  AND cisli245.t$line$l=cisli941.t$line$l
  AND tdsls401.t$orno = cisli245.t$slso
  AND tdsls401.t$pono = cisli245.t$pono
  AND	znsls004.t$orno$c=tdsls401.t$orno	-- Origem OV
  AND	znsls004.t$pono$c=tdsls401.t$pono -- Origem OV
  AND	znsls401.t$ncia$c=znsls004.t$ncia$c	-- Origem OV
  AND znsls401.t$uneg$c=znsls004.t$uneg$c	-- Origem OV
  AND znsls401.t$pecl$c=znsls004.t$pecl$c	-- Origem OV
  AND znsls401.t$sqpd$c=znsls004.t$sqpd$c	-- Origem OV
  AND	znsls401.t$entr$c=znsls004.t$entr$c	-- Origem OV
  AND	znsls401.t$sequ$c=znsls004.t$sequ$c	-- Origem OV
  AND	ltrim(rtrim(tdsls401.t$item))=ltrim(rtrim(znsls401.t$item$c)) -- Origem OV
  AND znsls400.t$ncia$c=znsls401.t$ncia$c
  AND znsls400.t$uneg$c=znsls401.t$uneg$c
  AND znsls400.t$pecl$c=znsls401.t$pecl$c
  AND znsls400.t$sqpd$c=znsls401.t$sqpd$c
  AND znsls402.t$ncia$c=znsls401.t$ncia$c	--#FAF.180.sn
  AND znsls402.t$uneg$c=znsls401.t$uneg$c
  AND znsls402.t$pecl$c=znsls401.t$pecl$c
  AND znsls402.t$sqpd$c=znsls401.t$sqpd$c	--#FAF.180.en
  AND endfat.t$cadr=cisli940.t$itoa$l
  AND endent.t$cadr=cisli940.t$stoa$l
  AND tcibd001.t$item=cisli941.t$item$l
  AND tdsls400.t$orno=tdsls401.t$orno --#FAF.087.n
  AND tdsls094.t$sotp=tdsls400.t$sotp --#FAF.087.n
  and ((cisli941.T$fire$L= cisli941f.T$REFR$L and (cisli940.t$fdty$l=15 or cisli940.t$fdty$l=16))
        or cisli941.T$fire$L= cisli941f.T$fire$L) --#FAF.173.n
  and ((cisli941.T$line$L= cisli941f.T$rfdl$L and (cisli940.t$fdty$l=15 or cisli940.t$fdty$l=16))
        or cisli941.T$line$L= cisli941f.T$line$l) --#FAF.173.n
    and cisli940.t$stat$l IN (5,6) and cisli940.t$nfes$l IN (1,2,5)