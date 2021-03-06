--	#FAF.179 - 30-jun-2014,	Fabio Ferreira,	Inclus�o do campo DT_SITUACAO_LISTA 
--	21/08/2014 - Atualiza��o do timezone
--****************************************************************************************************************************************************************
select distinct
            to_char(znsls401.t$entr$c) NR_ENTREGA,
            znsls400.t$idli$c NR_LISTA_CASAMENTO,
            CASE WHEN tdsls400.t$hdst=40 THEN 'A'
            WHEN nvl(znacr200.t$vale$c,' ')!=' ' THEN 'V'
            ELSE 'L' END      DS_SITUACAO_LISTA,
			
            CASE WHEN tdsls400.t$hdst=40 THEN
              (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(min(a.t$trdt), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
						AT time zone 'America/Sao_Paulo') AS DATE)
               from baandb.ttdsls450201 a
               where A.T$orno = znsls401.T$ORNO$C)
            ELSE 
              (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(min(a.t$trdt), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
						AT time zone 'America/Sao_Paulo') AS DATE) 
              from baandb.ttdsls450201 a
              where A.T$BKYN=2
              and A.T$TRDT>(select  max(b.t$trdt) 
                            from baandb.ttdsls450201 b
                            where b.T$BKYN=1 
                            and b.t$orno=a.t$orno)
              AND a.t$orno=znsls401.T$ORNO$C)
            END      DT_ULT_ATUALIZACAO   
			
from        baandb.tznsls401201 znsls401
inner join  baandb.ttdsls401201 tdsls401
            ON  tdsls401.t$orno=znsls401.t$orno$c
            AND tdsls401.t$pono=znsls401.t$pono$c
INNER JOIN  baandb.ttdsls400201 tdsls400
            ON  tdsls400.t$orno=tdsls401.t$orno
INNER JOIN  baandb.tznsls400201 znsls400
            ON  znsls400.t$ncia$c=znsls401.t$ncia$c
            AND znsls400.t$uneg$c=znsls401.t$uneg$c
            AND znsls400.t$pecl$c=znsls401.t$pecl$c
            AND znsls400.t$sqpd$c=znsls401.t$sqpd$c
left join   baandb.tznacr200201 znacr200
            ON  znacr200.t$ncia$c=znsls401.t$ncia$c
            AND znacr200.t$uneg$c=znsls401.t$uneg$c
            AND znacr200.t$pecl$c=znsls401.t$pecl$c
            AND znacr200.t$sgpd$c=znsls401.t$sqpd$c
            AND znacr200.t$entr$c=znsls401.t$entr$c
WHERE       znsls400.t$idli$c>0