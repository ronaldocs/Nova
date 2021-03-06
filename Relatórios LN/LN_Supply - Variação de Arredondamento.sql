SELECT
  TDPUR401.T$ORNO,
  TDREC941.T$FIRE$L,
  TDPUR401.T$PRIC,
  TDREC941.T$PRIC$L,
  
  TCCOM130.T$FOVN$L              CNPJ_FORNECEDOR,
  TCCOM130.T$NAMA                NOME_FORNECEDOR,
  TCMCS023.T$DSCA                DEPARTAMENTO,
  TRIM(TCIBD001.T$ITEM)          ITEM,
  TCIBD001.T$DSCA                DESCR_ITEM,
  TCIBD001.T$CEAT$L              EAN,
  TDREC941.T$QNTY$L              QT_REC,
  TDPUR401.T$PRIC                PREC_UNIT_OC,
  ABS(NVL(TDREC941.T$PRIC$L,
          BRNEF941.T$PRIC$L))    PREC_UNIT_NF,
  ABS(TDPUR401.T$PRIC) - 
  NVL(ABS(TDREC941.T$PRIC$L), 
      ABS(BRNEF941.T$PRIC$L))    DIF_PREC_OC_NF,
  NVL(TDREC941.T$FIRE$L, 
      BRNEF941.T$FIRE$L)         REF_FISCAL,
  
  CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(TDREC940.T$DATE$L, 
    'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
      AT time zone 'America/Sao_Paulo') AS DATE)
                                 DT_REC,
  TDPUR451.LOGN                  LOGIN,
  tdpur400.t$cotp                TIPO_ORDEM_COMPRA,
  tdpur094.t$dsca                DESC_TIPO_ORDEM,
  tdrec936.t$rndt$l              TOLER_DIF_ARRED,
  
  CASE WHEN   ABS(ABS(TDPUR401.T$PRIC) - 
                  NVL(ABS(TDREC941.T$PRIC$L), ABS(BRNEF941.T$PRIC$L))) <= (tdrec936.t$rndt$l / 100) THEN
        'Automático' 
  ELSE  'Manual' END            TIPO_ARRED
  
FROM       BAANDB.TTDPUR401301 TDPUR401
   
INNER JOIN BAANDB.TTDPUR400301 TDPUR400
        ON TDPUR400.T$ORNO = TDPUR401.T$ORNO
    
INNER JOIN BAANDB.TTCCOM130301 TCCOM130
        ON TCCOM130.T$CADR = TDPUR400.T$OTAD
  
INNER JOIN BAANDB.TTCIBD001301 TCIBD001
        ON TCIBD001.T$ITEM = TDPUR401.T$ITEM
  
 LEFT JOIN BAANDB.TTCMCS023301 TCMCS023
        ON TCMCS023.T$CITG = TCIBD001.T$CITG
  
 LEFT JOIN BAANDB.TTDREC947301 TDREC947
        ON TDREC947.T$NCMP$L = 301 
       AND TDREC947.T$OORG$L = 80
       AND TDREC947.T$ORNO$L = TDPUR401.T$ORNO
       AND TDREC947.T$PONO$L = TDPUR401.T$PONO
       AND TDREC947.T$SEQN$L = TDPUR401.T$SQNB
  
 LEFT JOIN BAANDB.TTDREC941301 TDREC941
        ON TDREC941.T$FIRE$L = TDREC947.T$FIRE$L
       AND TDREC941.T$LINE$L = TDREC947.T$LINE$L
  
 LEFT JOIN BAANDB.TTDREC940301 TDREC940
        ON TDREC940.T$FIRE$L = TDREC941.T$FIRE$L

 LEFT JOIN BAANDB.TZNNFE007301 ZNNFE007
        ON ZNNFE007.T$OORG$C = 80
       AND ZNNFE007.T$ORNO$C = TDPUR401.T$ORNO
       AND ZNNFE007.T$PONO$C = TDPUR401.T$PONO
       AND ZNNFE007.T$SEQN$C = TDPUR401.T$SQNB
  
 LEFT JOIN BAANDB.TBRNFE941301 BRNEF941
        ON BRNEF941.T$FIRE$L = ZNNFE007.T$FIRE$C
       AND BRNEF941.T$LINE$L = ZNNFE007.T$LINE$C
  
 LEFT JOIN ( SELECT A.T$ORNO,
                    A.T$PONO,
                    A.T$SQNB,
                    MAX(A.T$LOGN) KEEP (DENSE_RANK LAST ORDER BY A.T$TRDT,  A.T$SERN) LOGN
               FROM BAANDB.TTDPUR451301 A
           GROUP BY A.T$ORNO,
                    A.T$PONO,
                    A.T$SQNB ) TDPUR451
        ON TDPUR451.T$ORNO = TDPUR401.T$ORNO
       AND TDPUR451.T$PONO = TDPUR401.T$PONO
       AND TDPUR451.T$SQNB = TDPUR401.T$SQNB 
   
 LEFT JOIN baandb.ttdpur094301 tdpur094
        ON tdpur094.t$potp = tdpur400.t$cotp
 
 LEFT JOIN baandb.ttdrec936301 tdrec936
        ON tdrec936.t$sern$l = 0
       
WHERE ABS(ABS(TDPUR401.T$PRIC) - 
      ABS(NVL(TDREC941.T$PRIC$L, 
              NVL(BRNEF941.T$PRIC$L, 
                  TDPUR401.T$PRIC)))) >= 0.5
  
--  AND TCIBD001.T$CITG IN (:Departamento)

ORDER BY NOME_FORNECEDOR, DEPARTAMENTO, ITEM
