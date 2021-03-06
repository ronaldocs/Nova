SELECT
  DISTINCT
    znsls412.t$pecl$c                           PEDIDO,
    znsls401.t$entr$c                           ENTREGA,
    znsls401.t$item$c                           ITEM,
    tfacp200.t$ifbp                             CODE_PN,
    tccom100.t$nama                             DESC_PN,
    regexp_replace(tccom130.t$fovn$l, '[^0-9]', '')
                                                CNPJ_FORN,
    Concat(tfacp200.t$ttyp, tfacp200.t$ninv)    TRANSACAO,
    tfacp200.t$ttyp                             CODE_TRANS,
    CMG103.t$mopa$d                             CODE_MODAL_PAGTO,
    MODAL_PGTO_HIST.DESC_MODAL                  DESC_MODAL_PAGTO,
    CASE WHEN tfcmg101.t$basu IS NULL THEN
         tfacp201.t$bank
    ELSE tfcmg101.t$basu END                    BANCO_PARCEIRO,
    CASE WHEN tfcmg011_ac.t$agcd$l IS NULL THEN
         tfcmg011_ag.t$agcd$l                           
    ELSE tfcmg011_ac.t$agcd$l END               NUME_AGENCIA,
    CASE WHEN tfcmg011_ac.t$agdg$l IS NULL THEN                           
         tfcmg011_ag.t$agdg$l
    ELSE tfcmg011_ac.t$agdg$l END               DIGI_AGENCIA,
    CASE WHEN tfcmg011_ac.t$desc IS NULL THEN
         tfcmg011_ag.t$desc 
    ELSE tfcmg011_ac.t$desc END                 DESC_AGENCIA,
    CASE WHEN tccom125_ac.t$bano IS NULL THEN   
         tccom125_ag.t$bano
    ELSE tccom125_ac.t$bano END                 NUME_CONTA,
    CASE WHEN tccom125_ac.t$dacc$d IS NULL THEN                          
         tccom125_ag.t$dacc$d
    ELSE tccom125_ac.t$dacc$d END               DIGI_CONTA,  
	 
    TENT.RN                                     TENTATIVA_PAGTO,
    tfcmg101.t$plan                             DATA_TENTATIVA_PAGTO,
    tfcmg101.t$mopa$d                           TENTATIVA_MOD_PAGTO,
    DESC_MODAL_PGTO_2                           DESC_MOD_PAGTO,
    tfcmg101.t$btno                             TENTATIVA_LOTE_PAGTO,

    tfacp200.t$ninv                             NUME_TITULO,
    tfacp200.t$docn$l                           NUME_NF,
    tfacp200.t$seri$l                           SERI_NF,
    tfacp200.t$docd                             DATA_EMISSAO

FROM       baandb.ttfacp200301  tfacp200  

INNER JOIN baandb.ttfacp201301  tfacp201
        ON tfacp201.t$ttyp = tfacp200.t$ttyp
       AND tfacp201.t$ninv = tfacp200.t$ninv

INNER JOIN baandb.ttccom100301 tccom100
        ON tccom100.t$bpid = tfacp200.t$ifbp
    
INNER JOIN baandb.ttccom130301 tccom130
        ON tccom130.t$cadr = tccom100.t$cadr
    
 LEFT JOIN ( select distinct zncmg011.t$typd$c
               from baandb.tzncmg011301 zncmg011
              where zncmg011.t$typd$c != ' ' ) tipoDEV
        ON tipoDEV.t$typd$c = tfacp200.t$ttyp
 
 LEFT JOIN baandb.tznsls412301 znsls412
        ON znsls412.t$ttyp$c = tipoDEV.t$typd$c
       AND znsls412.t$ninv$c = tfacp200.t$ninv
       AND znsls412.t$type$c = 3

 LEFT JOIN baandb.tznsls401301  znsls401
        ON znsls401.t$ncia$c = znsls412.t$ncia$c
       AND znsls401.t$uneg$c = znsls412.t$uneg$c
       AND znsls401.t$pecl$c = znsls412.t$pecl$c
       AND znsls401.t$sqpd$c = znsls412.t$sqpd$c
        
 LEFT JOIN baandb.ttccom125301  tccom125_ag           --Banco PN da Agenda Pagto
        ON tccom125_ag.t$ptbp = tfacp201.t$ifbp
       AND tccom125_ag.t$cban = tfacp201.t$bank

 LEFT JOIN baandb.ttfcmg011301  tfcmg011_ag
        ON tfcmg011_ag.t$bank = tccom125_ag.t$brch

 LEFT JOIN baandb.ttfcmg101301 tfcmg101
        ON tfcmg101.t$comp = 301 
       AND tfcmg101.t$ifbp = tfacp200.t$ifbp
       AND tfcmg101.t$tadv = 1                        --Fatura de Compra
       AND tfcmg101.t$ttyp = tfacp200.t$ttyp
       AND tfcmg101.t$ninv = tfacp200.t$ninv

 LEFT JOIN baandb.ttccom125301  tccom125_ac           --Banco PN do Acons. Pagto
        ON tccom125_ac.t$ptbp = tfcmg101.t$ifbp
       AND tccom125_ac.t$cban = tfcmg101.t$basu

 LEFT JOIN baandb.ttfcmg011301  tfcmg011_ac
        ON tfcmg011_ac.t$bank = tccom125_ac.t$brch
        
 LEFT JOIN ( select a.t$mopa$d,
                    a.t$btno,
                    a.t$basu,
                    a.t$ptbp,
                    a.t$ttyp,
                    a.t$docn
               from baandb.ttfcmg103301 a ) CMG103
        ON CMG103.t$btno = tfcmg101.t$btno
       AND CMG103.t$basu = tfcmg101.t$basu
       AND CMG103.t$ptbp = tfcmg101.t$ifbp
       AND CMG103.t$ttyp = tfcmg101.t$ptyp
       AND CMG103.t$docn = tfcmg101.t$pdoc
        
 LEFT JOIN ( select l.t$desc DESC_MODAL,
                    d.t$cnst COD_MODAL
               from baandb.tttadv401000 d,
                    baandb.tttadv140000 l
              where d.t$cpac = 'tf'
                and d.t$cdom = 'cmg.mopa.d'
                and l.t$clan = 'p'
                and l.t$cpac = 'tf'
                and l.t$clab = d.t$za_clab
                and rpad(d.t$vers,4) ||
                    rpad(d.t$rele,2) ||
                    rpad(d.t$cust,4) = ( select max(rpad(l1.t$vers,4) ||
                                                    rpad(l1.t$rele,2) ||
                                                    rpad(l1.t$cust,4)) 
                                           from baandb.tttadv401000 l1 
                                          where l1.t$cpac = d.t$cpac 
                                            and l1.t$cdom = d.t$cdom )
                and rpad(l.t$vers,4) ||
                    rpad(l.t$rele,2) ||
                    rpad(l.t$cust,4) = ( select max(rpad(l1.t$vers,4) ||
                                                    rpad(l1.t$rele,2) ||
                                                    rpad(l1.t$cust,4)) 
                                           from baandb.tttadv140000 l1 
                                          where l1.t$clab = l.t$clab 
                                            and l1.t$clan = l.t$clan 
                                            and l1.t$cpac = l.t$cpac ) )  MODAL_PGTO_HIST
        ON MODAL_PGTO_HIST.COD_MODAL = CMG103.t$mopa$d

 LEFT JOIN ( SELECT D.T$TTYP$D,
                    D.T$NINV$D,
                    D.T$PTYP$D,
                    D.T$DOCN$D,
                    ROW_NUMBER() OVER 
                    ( PARTITION BY D.T$TTYP$D,
                                   D.T$NINV$D
                          ORDER BY D.T$PAYD$D )  RN
               FROM BAANDB.TTFLCB230301 D )  TENT
        ON TENT.T$TTYP$D = TFACP200.T$TTYP
       AND TENT.T$NINV$D = TFACP200.T$NINV
       AND TENT.T$PTYP$D = CMG103.T$TTYP
       AND TENT.T$DOCN$D = CMG103.T$DOCN
       
 LEFT JOIN ( select l.t$desc DESC_MODAL_PGTO_2,
                    d.t$cnst COD_MODAL_PGTO_2
               from baandb.tttadv401000 d,
                    baandb.tttadv140000 l
              where d.t$cpac = 'tf'
                and d.t$cdom = 'cmg.mopa.d'
                and l.t$clan = 'p'
                and l.t$cpac = 'tf'
                and l.t$clab = d.t$za_clab
                and rpad(d.t$vers,4) ||
                    rpad(d.t$rele,2) ||
                    rpad(d.t$cust,4) = ( select max(rpad(l1.t$vers,4) ||
                                                    rpad(l1.t$rele,2) ||
                                                    rpad(l1.t$cust,4)) 
                                           from baandb.tttadv401000 l1 
                                          where l1.t$cpac = d.t$cpac 
                                            and l1.t$cdom = d.t$cdom )
                and rpad(l.t$vers,4) ||
                    rpad(l.t$rele,2) ||
                    rpad(l.t$cust,4) = ( select max(rpad(l1.t$vers,4) ||
                                                    rpad(l1.t$rele,2) ||
                                                    rpad(l1.t$cust,4)) 
                                           from baandb.tttadv140000 l1 
                                          where l1.t$clab = l.t$clab 
                                            and l1.t$clan = l.t$clan 
                                            and l1.t$cpac = l.t$cpac ) )  DESC_MODAL_PGTO_2
        ON DESC_MODAL_PGTO_2.COD_MODAL_PGTO_2 = tfacp201.t$mopa$d 
        
WHERE tfacp200.t$docn = 0 
  AND tfacp200.t$ttyp in ('PKB','PKC','PKD','PKE','PKF','PRB','PRW','PKG')
  
