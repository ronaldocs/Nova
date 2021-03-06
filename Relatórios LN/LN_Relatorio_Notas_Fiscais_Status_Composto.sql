SELECT
  DISTINCT
    regexp_replace(tccom130.t$fovn$l, '[^0-9]', '')   CNPJ_FILIAL,
    znfmd001.t$dsca$c                                 PLANTA,
    cisli940.t$docn$l                                 NOTA,
    cisli940.t$seri$l                                 SERIE,
    znsls004.t$pecl$c                                 PEDIDO,
    znsls004.t$uneg$c                                 UN_NEGOCIO,
    
    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cisli940.t$datg$l, 
        'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
          AT time zone 'America/Sao_Paulo') AS DATE)      MENOR_DATA,
    
    TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'))
    - 
    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cisli940.t$datg$l, 
        'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
          AT time zone 'America/Sao_Paulo') AS DATE)      ESPERA
  
FROM  baandb.tcisli940301 cisli940

INNER JOIN baandb.tznsls000301 znsls000
        ON znsls000.t$indt$c = TO_DATE('01-JAN-1970','DD-MON-YYYY')
          
 LEFT JOIN ( SELECT tcemm030.t$eunt,
                    tcemm030.t$dsca,
                    tcemm030.t$euca,
                    tcemm124.t$cwoc
               FROM baandb.ttcemm124301 tcemm124, 
                    baandb.ttcemm030301 tcemm030
              WHERE tcemm030.t$eunt = tcemm124.t$grid
                AND tcemm124.t$loco = 301 ) unid_empr
        ON unid_empr.t$cwoc = cisli940.t$cofc$l
        
 LEFT JOIN baandb.ttccom130301 tccom130
        ON tccom130.t$cadr = cisli940.t$sfra$l
         
 LEFT JOIN baandb.tznfmd001301  znfmd001
        ON TO_CHAR(znfmd001.t$fili$c) = unid_empr.t$euca

 LEFT JOIN baandb.tcisli941301 cisli941
        ON cisli941.t$fire$l = cisli940.t$fire$l
       AND cisli941.t$item$l != znsls000.t$itmd$c
       AND cisli941.t$item$l != znsls000.t$itmf$c
       AND cisli941.t$item$l != znsls000.t$itjl$c
         
 LEFT JOIN baandb.tcisli245301 cisli245
        ON cisli245.t$fire$l = cisli941.t$fire$l
       AND cisli245.t$line$l = cisli941.t$line$l
          
 LEFT JOIN baandb.tznsls004301 znsls004
        ON znsls004.t$orno$c = cisli245.t$slso
       AND znsls004.t$pono$c = cisli245.t$pono
        
WHERE cisli940.t$stat$l = 4
  AND cisli940.t$fdty$l != 14
  AND unid_empr.t$eunt IN (:Filial)
        
ORDER BY MENOR_DATA
