SELECT  znmcs032.t$subf$c SUB_FAMILIA,
        znmcs032.t$fami$c COD_FAMILIA,
        znmcs032.t$seto$c COD_SETOR,
        znmcs032.t$citg$c COD_DEPARTAMENTO,
        znmcs032.t$dsca$c DESCRICAO
FROM    tznmcs032201 znmcs032, ttcmcs023201 tcmcs023
WHERE   tcmcs023.T$CITG=znmcs032.T$CITG$C
AND     tcmcs023.T$tpit$c=1