SELECT
  DISTINCT
    301                                               Companhia,
    tdpur400.t$otbp                                   COD_PN,
    regexp_replace(tccom130.t$fovn$l, '[^0-9]', '')   CNPJ,
    tccom100.t$nama                                   DESC_PN,
    tdpur400.t$orno                                   ORDEM_COMPRA,
    tdpur401.t$oamt                                   VALOR,
    tdpur400.t$cotp                                   TIPO_OC,
    tdpur094.t$dsca                                   DESC_TIPO_OC,
    TRIM(tdpur401.t$item)                             ITEM,
    tcibd001.t$dsca                                   DESC_ITEM,
    crd.t$logn                                        LOGIN,
    nome_crd.t$name                                   NOME_LOGIN,
   
    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(tdpur400.t$odat, 
      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
        AT time zone sessiontimezone) AS DATE)        DATA_ORDEM,
                           
    NVL(TRIM(ORDEM.STATUS_ORDEM), 'Não definido')     STATUS_ORDEM,
    
    apr.t$logn                                        APROVADOR,
   
    nome_apr.t$NAME                                   NOME_APROV_ORDEM,
   
    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(apr.dapr, 
      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
        AT time zone sessiontimezone) AS DATE)        DATA_APROVACAO,
  
    unid_empr.DEPTO_COMPRAS                           DEPTO_COMPRAS,
    unid_empr.DESC_FILIAL                             FILIAL,
  
    NVL(TRIM(APROVACAO_FIS.STATUS_APROVACAO_FIS), 
        'Não definido')                               STATUS_APROVACAO_FIS,
    tdrec940.t$logn$l                                 LOGIN_USUARIO,
    nome_aprov.t$name                                 NOME_APROV_REC,
    
    CASE WHEN NVL(tdrec940.t$idat$l, to_date('01-01-1980','DD-MM-YYYY')) > to_date('01-01-1980','DD-MM-YYYY') 
           THEN CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(tdrec940.t$idat$l, 
                  'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
                    AT time zone sessiontimezone) AS DATE)
         WHEN tdpur401.t$date$c < =   to_date('01-01-1980','DD-MM-YYYY') 
           THEN NULL
         ELSE CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(tdpur401.t$date$c, 
                'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
                  AT time zone sessiontimezone) AS DATE) 
     END                                              DATA_HORA_EMISSAO,
                             
    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(tdrec940.t$adat$l, 
      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
        AT time zone sessiontimezone) AS DATE)        DATA_HORA_APROVACAO,
 
    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(tdrec940.t$date$l, 
      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
        AT time zone sessiontimezone) AS DATE)        DATA_HORA_FISCAL,
                            
    tdrec940.t$fire$l                                 REF_FISCAL, 
    
    CASE WHEN NVL(CONTABIL.t$cnst, 0) = 0 
           THEN 'Não definido'
         WHEN CONTABIL.STATUS_APROVACAO_CONTABIL = 'Sim' 
           THEN 'Aprovado'
         WHEN CONTABIL.STATUS_APROVACAO_CONTABIL = 'Não' 
           THEN 'Não aprovado'
         ELSE NULL 
     END                                              STATUS_APROVACAO_CONTABIL,
                
    tfgld018.t$dcdt                                   DATA_DOCTO,
    NVL(TRIM(CONCAT(tdrec940.t$ttyp$l, 
                    tdrec940.t$invn$l)), 'N/A')       TRANSACAO_CAP,
    NVL(tdrec940.t$docn$l, tdpur401.t$docn$c)         NUM_NF,
    NVL(tdrec940.t$seri$l, tdpur401.t$seri$c)         SERI_NF,
    tfacp201.t$payd                                   DATA_VENCTO,
    NVL(SITUACAO_PAGTO.DSC_SITUACAO_PAGTO, 
        'Não informado')                              DSC_SITUACAO_PAGTO,
    tfcmg101.t$plan                                   DATA_PLAN_PAGTO,
    tcmcs023.t$dsca                                   CONTA_CONTABIL_DESCRICAO,
    tdpur401.t$wrkc$l                                 CODIGO_CENTRO_TRABALHO,
    tcmcs065.t$dsca                                   CENTRO_TRABALHO_DESCRICAO,
    tcmcs013.t$dsca                                   CONDICAO_PAGTO,
    tfgld018.t$user                                   LOGIN_APROVADOR_CONTABIL,
    apr_cont.NOME                                     APROVADOR_CONTABIL,
    tfgld018.t$date                                   DATA_APROVACAO_CONTABIL,

    CASE WHEN tfgld018.t$time IS NULL THEN NULL
           ELSE TO_CHAR(TRUNC(tfgld018.t$time/3600),'FM9900') || ':' ||
                TO_CHAR(TRUNC(MOD(tfgld018.t$time,3600)/60),'FM00') || ':' ||
                TO_CHAR(MOD(tfgld018.t$time,60),'FM00')
    END                                               HORA_APROVACAO_CONTABIL
    
FROM       baandb.ttdpur400301 tdpur400

INNER JOIN baandb.ttdpur401301 tdpur401
        ON tdpur401.t$orno = tdpur400.t$orno

 LEFT JOIN baandb.ttcibd001301 tcibd001
        ON tcibd001.t$item = tdpur401.t$item
       
 LEFT JOIN baandb.ttdpur094301 tdpur094
        ON tdpur094.t$potp = tdpur400.t$cotp
 
 LEFT JOIN baandb.ttccom100301 tccom100
        ON tccom100.t$bpid = tdpur400.t$otbp
        
 LEFT JOIN baandb.ttccom130301  tccom130
        ON tccom130.t$cadr = tdpur400.t$otad
 
 LEFT JOIN baandb.ttdrec947301  tdrec947
        ON tdrec947.t$ncmp$l = 301 
       AND tdrec947.t$oorg$l = 80
       AND tdrec947.t$orno$l = tdpur401.t$orno
       AND tdrec947.t$pono$l = tdpur401.t$pono
       AND tdrec947.t$seqn$l = tdpur401.t$sqnb
       
 LEFT JOIN baandb.ttdrec940301 tdrec940
        ON tdrec940.t$fire$l = tdrec947.t$fire$l
 
 LEFT JOIN ( select b.t$orno, 
                    min(b.t$trdt) dapr, 
                    b.t$logn
               from baandb.ttdpur450301 b
              where b.t$hdst = 10
                and b.t$trdt = ( SELECT MAX(c.t$trdt) 
                                   FROM baandb.ttdpur450301 c 
                                  WHERE c.t$hdst = 10 
                                    AND c.t$orno = b.t$orno )
           group by b.t$orno, b.t$logn ) apr
        ON apr.t$orno = tdpur400.t$orno

 LEFT JOIN ( select ttaad200.t$user,
                    ttaad200.t$name
               from baandb.tttaad200000 ttaad200 ) nome_apr
        ON nome_apr.t$user = apr.t$logn
 
 LEFT JOIN (select h.t$orno, 
                   min(h.t$trdt) dapr, 
                   h.t$logn 
              from baandb.ttdpur450301 h
             where h.t$hdst = 5
               and h.t$trdt = ( SELECT MAX(i.t$trdt) 
                                  FROM baandb.ttdpur450301 i 
                                 WHERE i.t$hdst = 5 
                                   AND i.t$orno = h.t$orno )
          group by h.t$orno, h.t$logn ) crd
        ON crd.t$orno = tdpur400.t$orno

 LEFT JOIN (select ttaad200.t$user,
                   ttaad200.t$name
              from baandb.tttaad200000 ttaad200 ) nome_crd
        ON nome_crd.t$user = crd.t$logn
        
 LEFT JOIN baandb.ttfgld018301 tfgld018
        ON tfgld018.t$ttyp = tdrec940.t$ttyp$l
       AND tfgld018.t$docn = tdrec940.t$invn$l
       AND tfgld018.t$ttyp !=  ' '
       AND tfgld018.t$docn !=  0
      
 LEFT JOIN baandb.ttfcmg101301 tfcmg101
        ON tfcmg101.t$ttyp = tdrec940.t$ttyp$l
       AND tfcmg101.t$ninv = tdrec940.t$invn$l
       AND tfcmg101.t$ninv !=  0
 
 LEFT JOIN baandb.ttfacp201301 tfacp201
        ON tfacp201.t$ttyp = tdrec940.t$ttyp$l
       AND tfacp201.t$ninv = tdrec940.t$invn$l
 
 LEFT JOIN ( SELECT l.t$desc STATUS_ORDEM,
                    d.t$cnst
               FROM baandb.tttadv401000 d,
                    baandb.tttadv140000 l
              WHERE d.t$cpac = 'td'
                AND d.t$cdom = 'pur.hdst'
                AND l.t$clan = 'p'
                AND l.t$cpac = 'td'
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
                                            and l1.t$cpac = l.t$cpac ) ) ORDEM
        ON ORDEM.t$cnst = tdpur400.t$hdst 
  
 LEFT JOIN ( SELECT l.t$desc STATUS_APROVACAO_FIS,
                    d.t$cnst
               FROM baandb.tttadv401000 d,
                    baandb.tttadv140000 l
             WHERE  d.t$cpac = 'td'
                AND d.t$cdom = 'rec.stat.l'
                AND l.t$clan = 'p'
                AND l.t$cpac = 'td'
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
                                            and l1.t$cpac = l.t$cpac ) ) APROVACAO_FIS
        ON APROVACAO_FIS.t$cnst = tdrec940.t$stat$l

 LEFT JOIN ( SELECT l.t$desc STATUS_APROVACAO_CONTABIL,
                     d.t$cnst
                FROM baandb.tttadv401000 d,
                     baandb.tttadv140000 l
               WHERE d.t$cpac = 'tc'
                 AND d.t$cdom = 'yesno'
                 AND l.t$clan = 'p'
                 AND l.t$cpac = 'tc'
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
                                             and l1.t$cpac = l.t$cpac ) ) CONTABIL
        ON CONTABIL.t$cnst = tdrec940.t$pstd$l   

 LEFT JOIN ( SELECT l.t$desc DSC_SITUACAO_PAGTO,
                      d.t$cnst 
                 FROM baandb.tttadv401000 d,
                      baandb.tttadv140000 l
                WHERE d.t$cpac = 'tf'
                  AND d.t$cdom = 'acp.pyst.l'
                  AND l.t$clan = 'p'
                  AND l.t$cpac = 'tf'
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
                                              and l1.t$cpac = l.t$cpac ) ) SITUACAO_PAGTO
        ON SITUACAO_PAGTO.t$cnst = tfacp201.t$pyst$l  

 LEFT JOIN ( SELECT tcemm030.t$eunt  DEPTO_COMPRAS,
                    tcemm030.t$dsca  DESC_FILIAL,
                    tcemm030.t$euca  FILIAL,
                    tcemm124.t$cwoc
               FROM baandb.ttcemm124301 tcemm124, 
                    baandb.ttcemm030301 tcemm030
              WHERE tcemm030.t$eunt = tcemm124.t$grid
                AND tcemm124.t$loco = 301 ) unid_empr
        ON unid_empr.t$cwoc = tdpur400.t$cofc
 
 LEFT JOIN ( select ttaad200.t$user,
                    ttaad200.t$name
               from baandb.tttaad200000 ttaad200 ) nome_aprov
        ON nome_aprov.t$user = tdrec940.t$logn$l
        
 LEFT JOIN baandb.ttcmcs023301 tcmcs023
        ON tcmcs023.t$citg = tcibd001.t$citg
 
 LEFT JOIN baandb.ttcmcs065301 tcmcs065
        ON tcmcs065.t$cwoc = tdpur401.t$wrkc$l
        
 LEFT JOIN baandb.ttcmcs013301 tcmcs013
        ON tcmcs013.t$cpay = tdpur400.t$cpay

 LEFT JOIN ( select ttaad200.t$user LOGIN,
                    ttaad200.t$name NOME
               from baandb.tttaad200000 ttaad200 ) apr_cont
        ON apr_cont.LOGIN = tfgld018.t$user
                  
WHERE tdpur401.t$oltp IN (2,4)
        
  AND TRUNC(CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(tdpur400.t$odat, 
              'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
                AT time zone sessiontimezone) AS DATE))
      Between :EmissaoDe
          And :EmissaoAte
  AND unid_empr.DEPTO_COMPRAS IN (:FILIAL)
  AND NVL(ORDEM.t$cnst, 0) IN (:STATUS_ORDEM)
  AND NVL(APROVACAO_FIS.t$cnst, 0) IN (:STATUS_APR_FISCAL)
  AND NVL(CONTABIL.t$cnst, 0) IN (:STATUS_APR_CONTABIL)
  AND tdpur400.t$cotp IN (:TIPO_ORDEM)
  AND crd.t$logn IN (:UsuarioSolicitante)
  AND NVL(tfacp201.t$pyst$l, 0) IN (:SituacaoPagto)
  AND ((regexp_replace(tccom130.t$fovn$l, '[^0-9]', '') = Trim(regexp_replace(:CNPJ, '[^0-9]', ''))) OR (Trim(:CNPJ) is null))
  AND ( (Trim(:OrdemCompra) is null) OR (UPPER(Trim(tdpur400.t$orno)) like '%' || UPPER(Trim(:OrdemCompra) || '%')) )
  AND ( (Trim(:ReferenciaFiscal) is null) or (UPPER(Trim(tdrec940.t$fire$l)) like '%' || UPPER(Trim(:ReferenciaFiscal) || '%')) )

ORDER BY DATA_ORDEM, 
         STATUS_ORDEM, 
         ORDEM_COMPRA
