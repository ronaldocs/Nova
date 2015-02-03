select q1.* from (
     SELECT DISTINCT
         znfmd630.t$cfrw$c             CODI_TRANS,
         Trim(tcmcs080.t$dsca)         DESC_TRANS,
         znfmd630.t$cfrw$c ||
         ' - '             ||
         Trim(tcmcs080.t$dsca)         COD_DESC_TRANS,
         COUNT(znfmd630.t$cfrw$c)      QTDE_ENTREGAS,
         SUM(znfmd630.t$vlfC$c)        FRETE_APAGAR,
         CASE WHEN cisli940.t$fdty$l=14 THEN
           'NFE'
         ELSE  'NFS' END               TIPO_NF,
         cisli940.t$fdty$l             TIPO_DOCTO_FISCAL, 
         FGET.                         DESC_TIPO_DOCTO_FISCAL,
         znfmd630.t$fili$c             FILIAL
     
     FROM       BAANDB.tznfmd630301  znfmd630
     
     INNER JOIN BAANDB.tcisli940301  cisli940
             ON znfmd630.t$fire$c = cisli940.t$fire$l
     
     INNER JOIN baandb.ttcmcs080301  tcmcs080
             ON tcmcs080.t$cfrw = znfmd630.t$cfrw$c
       
      LEFT JOIN ( SELECT d.t$cnst CNST,
                         l.t$desc DESC_TIPO_DOCTO_FISCAL
                    FROM BAANDB. tttadv401000 d,
                         BAANDB. tttadv140000 l
                   WHERE d.t$cpac = 'ci'
                     AND d.t$cdom = 'sli.tdff.l'
                     AND l.t$clan = 'p'
                     AND l.t$cpac = 'ci'
                     AND l.t$clab = d.t$za_clab
                     AND rpad(d.t$vers,4) ||
                         rpad(d.t$rele,2) ||
                         rpad(d.t$cust,4) = ( select max(rpad(l1.t$vers,4) ||
                                                         rpad(l1.t$rele,2) ||
                                                         rpad(l1.t$cust,4)) 
                                                from baandb.tttadv401000 l1 
                                               where l1.t$cpac = d.t$cpac 
                                                 and l1.t$cdom = d.t$cdom )
                     AND rpad(l.t$vers,4) ||
                         rpad(l.t$rele,2) ||
                         rpad(l.t$cust,4) = ( select max(rpad(l1.t$vers,4) ||
                                                         rpad(l1.t$rele,2) || 
                                                         rpad(l1.t$cust,4)) 
                                                from baandb.tttadv140000 l1 
                                               where l1.t$clab = l.t$clab 
                                                 and l1.t$clan = l.t$clan 
                                                 and l1.t$cpac = l.t$cpac ) ) FGET
              ON cisli940.t$fdty$l = FGET.CNST
     
     WHERE cisli940.t$fdty$l IN (1,14,15)
     
       AND Trunc(CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(znfmd630.t$date$c, 
                   'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
                     AT time zone sessiontimezone) AS DATE)) 
           BETWEEN :DataDe 
               AND :DataAte
     
     GROUP BY znfmd630.t$cfrw$c,
              Trim(tcmcs080.t$dsca),
              znfmd630.t$cfrw$c,
              Trim(tcmcs080.t$dsca),
              CASE WHEN cisli940.t$fdty$l=14 
               THEN 'NFE'
               ELSE 'NFS' END,
              znfmd630.t$fili$c,
              cisli940.t$fdty$l,
              FGET.DESC_TIPO_DOCTO_FISCAL
       
     ORDER BY FILIAL,DESC_TRANS,TIPO_NF,TIPO_DOCTO_FISCAL ) q1
where q1.tipo_nf in (:TipoNF)
