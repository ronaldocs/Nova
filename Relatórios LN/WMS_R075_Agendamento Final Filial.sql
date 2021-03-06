SELECT QWMS.                                     ASN,
       QWMS.                                     ID_FILIAL,
       QWMS.                                     DESCR_FILIAL,
       QWMS.                                     OPERACAO,
       QWMS.                                     DT_NR,
       CASE WHEN TDREC940.T$STAT$L =   1 THEN 'ABERTO'
            WHEN TDREC940.T$STAT$L =   3 THEN 'NÃO APROVADO'
            WHEN TDREC940.T$STAT$L =   4 THEN 'APROVADO'
            WHEN TDREC940.T$STAT$L =   5 THEN 'APROVADO COM PROBLEMA'
            WHEN TDREC940.T$STAT$L =   6 THEN 'ESTORNADO'
            WHEN TDREC940.T$STAT$L = 200 THEN 'AGURARDANDO WMS'
            WHEN TDREC940.T$STAT$L = 201 THEN 'PRONTO PARA ENVIAR WMS'
            ELSE                              'NÃO APLICAVEL' 
        END                                      SITUACAO_NOTA,
       QWMS.                                     NF,
       CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(TDREC940.T$DATE$L, 
         'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
        AT time zone 'America/Sao_Paulo') AS DATE)   DATA_EMISSAO,
       TDREC940.T$FOVN$L                         CNPJ_FORNCEDOR,
       TDREC940.T$OPFC$L                         CFOP,
       TDREC940.T$OPOR$L                         SEQ_CFOP,
       DEPART.ID_DEPART                          ID_DEPARTAMENTO,
       DEPART.DEPART_NAME                        DESCR_DEPARTAMENTO,
       TDREC941.T$ITEM                           ID_ITEM,
       TCIBD001.T$DSCA                           DESCR_ITEM,
       TCIBD936.T$FRAT$L                         NBM,
       TCIBD936.T$IFGC$L                         SEQ_NBM,
       TDREC941.T$PRIC$L                         CUSTO,
       TDREC941.T$QNTY$L                         QTDE,
       TDREC941.T$GAMT$L                         VALOR_MERCARIA,
       TDREC941.ICMS ICMSST_PROPRIO,
       TDREC941.ICMSST_ST_COM_CONV,
       TDREC941.ICMSST_ST_SEM_CONV
FROM   BAANDB.TTDREC940301@PLN01 TDREC940
 
INNER JOIN ( select L.T$FIRE$L,
                    L.T$ITEM$L T$ITEM,
                    SUM(L.T$PRIC$L) T$PRIC$L,
                    SUM(L.T$QNTY$L) T$QNTY$L,
                    SUM(L.T$GAMT$L) T$GAMT$L,
                    SUM(NVL(ICMS.T$AMNT$L,0)) ICMS,
                    SUM(CASE WHEN T$ISCO$C  = 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMSST_ST_COM_CONV,
                    SUM(CASE WHEN T$ISCO$C != 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMSST_ST_SEM_CONV
               from BAANDB.TTDREC941301@PLN01 L
          left join baandb.ttdrec942301@pln01 ICMS 
                 on ICMS.T$FIRE$L = L.T$FIRE$L
                and ICMS.T$LINE$L = L.T$LINE$L
                and ICMS.T$BRTY$L = 1
          left join baandb.ttdrec942301@pln01 ICST 
                 on ICST.T$FIRE$L = L.T$FIRE$L
                and ICST.T$LINE$L = L.T$LINE$L
                and ICST.T$BRTY$L = 2
          left join baandb.ttdrec949301@pln01 ICCP 
                 on  ICCP.T$FIRE$L = ICST.T$FIRE$L           
                and ICCP.T$BRTY$L = ICST.T$BRTY$L
           group by L.T$FIRE$L,
                    L.T$ITEM$L ) TDREC941 
        ON TDREC941.T$FIRE$L = TDREC940.T$FIRE$L

 LEFT JOIN ( SELECT DISTINCT 
                    b.ID_DEPART, 
                    b.DEPART_NAME, 
                    a.sku
               from WMWHSE5.sku a
         inner join ENTERPRISE.DEPARTSECTORSKU b 
                 on to_char(b.ID_DEPART) = to_char(a.SKUGROUP) ) DEPART                                           
        ON DEPART.sku = TRIM(TDREC941.T$ITEM)      
      
INNER JOIN ( select RC.RECEIPTKEY        ASN,  -- NR
                    RC.WHSEID            ID_FILIAL,
                    CL.UDF2              DESCR_FILIAL,
                    TPNT.DESCRIPTION     OPERACAO,
                    RD.SUSR1             NF,  
                    RC.SUPPLIERCODE, 
                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE, 
                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
                        AT time zone 'America/Sao_Paulo') AS DATE)  
                                         DT_NR  
               from WMWHSE5.RECEIPT  RC
         inner join WMWHSE5.RECEIPTDETAIL RD
                 on RD.RECEIPTKEY =  RC.RECEIPTKEY
         inner join ENTERPRISE.CODELKUP  CL
                 on UPPER(CL.UDF1) = RC.WHSEID
          left join ( SELECT clkp.code  COD, 
                             trans.description
                        FROM WMWHSE5.codelkup clkp
                  INNER JOIN WMWHSE5.translationlist trans 
                          ON trans.code = clkp.code
                         AND trans.joinkey1 = clkp.listname
                       WHERE clkp.listname = 'RECEIPTYPE'
                         AND trans.locale = 'pt'
                         AND trans.tblname = 'CODELKUP' 
                         AND Trim(clkp.code) is not null ) tpnt
                 on TO_CHAR(tpnt.COD) = TO_CHAR(rc.TYPE)
              where RD.SUSR1 IS NOT NULL
           group by RC.RECEIPTKEY,  
                    RC.WHSEID,   
                    CL.UDF2,  
                    TPNT.DESCRIPTION, 
                    RD.SUSR1,   
                    RC.SUPPLIERCODE,
                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE, 
                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
                        AT time zone 'America/Sao_Paulo') AS DATE) ) QWMS
        ON QWMS.NF = TDREC940.T$DOCN$L || '/' || TDREC940.T$SERI$L
       AND QWMS.SUPPLIERCODE  = TDREC940.T$BPID$L

INNER JOIN BAANDB.TTCIBD001301@PLN01 TCIBD001
        ON TCIBD001.T$ITEM = TDREC941.T$ITEM

INNER JOIN BAANDB.TTCIBD936301@PLN01 TCIBD936
        ON TCIBD936.T$IFGC$L = TCIBD001.T$IFGC$L

WHERE TDREC940.T$RFDT$L IN (1,2,5,10,28)              
  AND CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE, 
        'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
          AT time zone 'America/Sao_Paulo') AS DATE)
      Between :DataDe
          And :DataAte
  AND CASE WHEN NVL(TDREC940.T$STAT$L, 0) not in (1,3,4,5,6,200,201)
             THEN 0
           ELSE TDREC940.T$STAT$L
       END IN (:Situacao)

	   
	   
=IIF(Parameters!Table.Value <> "AAA",

"SELECT QWMS.ASN,         " &
"       QWMS.ID_FILIAL,   " &
"       QWMS.DESCR_FILIAL," &
"       QWMS.OPERACAO,    " &
"       QWMS.DT_NR,       " &
"       CASE WHEN TDREC940.T$STAT$L =   1 THEN 'ABERTO'                 " &
"            WHEN TDREC940.T$STAT$L =   3 THEN 'NÃO APROVADO'           " &
"            WHEN TDREC940.T$STAT$L =   4 THEN 'APROVADO'               " &
"            WHEN TDREC940.T$STAT$L =   5 THEN 'APROVADO COM PROBLEMA'  " &
"            WHEN TDREC940.T$STAT$L =   6 THEN 'ESTORNADO'              " &
"            WHEN TDREC940.T$STAT$L = 200 THEN 'AGURARDANDO WMS'        " &
"            WHEN TDREC940.T$STAT$L = 201 THEN 'PRONTO PARA ENVIAR WMS' " &
"            ELSE                              'NÃO APLICAVEL'          " &
"        END                                      SITUACAO_NOTA,        " &
"       QWMS.NF,                                                        " &
"       CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(TDREC940.T$DATE$L,           " &
"         'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')  " &
"        AT time zone 'America/Sao_Paulo') AS DATE)   DATA_EMISSAO,         " &
"       TDREC940.T$FOVN$L                         CNPJ_FORNCEDOR,       " &
"       TDREC940.T$OPFC$L                         CFOP,                 " &
"       TDREC940.T$OPOR$L                         SEQ_CFOP,             " &
"       DEPART.ID_DEPART                          ID_DEPARTAMENTO,      " &
"       DEPART.DEPART_NAME                        DESCR_DEPARTAMENTO,   " &
"       TDREC941.T$ITEM                           ID_ITEM,              " &
"       TCIBD001.T$DSCA                           DESCR_ITEM,           " &
"       TCIBD936.T$FRAT$L                         NBM,                  " &
"       TCIBD936.T$IFGC$L                         SEQ_NBM,              " &
"       TDREC941.T$PRIC$L                         CUSTO,                " &
"       TDREC941.T$QNTY$L                         QTDE,                 " &
"       TDREC941.T$GAMT$L                         VALOR_MERCARIA,       " &
"       TDREC941.ICMS ICMS_PROPRIO,          " &
"       TDREC941.ICMS_ST_COM_CONV,           " &
"       TDREC941.ICMS_ST_SEM_CONV            " &
"FROM   BAANDB.TTDREC940301@PLN01 TDREC940     " &
"                                              " &
"INNER JOIN ( select L.T$FIRE$L,               " &
"                    L.T$ITEM$L T$ITEM,        " &
"                    SUM(L.T$PRIC$L) T$PRIC$L, " &
"                    SUM(L.T$QNTY$L) T$QNTY$L, " &
"                    SUM(L.T$GAMT$L) T$GAMT$L, " &
"                    SUM(NVL(ICMS.T$AMNT$L,0)) ICMS," &
"                    SUM(CASE WHEN T$ISCO$C  = 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_COM_CONV,   " &
"                    SUM(CASE WHEN T$ISCO$C != 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_SEM_CONV    " &
"               from BAANDB.TTDREC941301@PLN01 L     " &
"          left join baandb.ttdrec942301@pln01 ICMS  " &
"                 on ICMS.T$FIRE$L = L.T$FIRE$L      " &
"                and ICMS.T$LINE$L = L.T$LINE$L      " &
"                and ICMS.T$BRTY$L = 1               " &
"          left join baandb.ttdrec942301@pln01 ICST  " &
"                 on ICST.T$FIRE$L = L.T$FIRE$L      " &
"                and ICST.T$LINE$L = L.T$LINE$L      " &
"                and ICST.T$BRTY$L = 2               " &
"          left join baandb.ttdrec949301@pln01 ICCP  " &
"                 on  ICCP.T$FIRE$L = ICST.T$FIRE$L  " &
"                and ICCP.T$BRTY$L = ICST.T$BRTY$L   " &
"           group by L.T$FIRE$L,                     " &
"                    L.T$ITEM$L ) TDREC941           " &
"        ON TDREC941.T$FIRE$L = TDREC940.T$FIRE$L    " &
"                                                    " &
" LEFT JOIN ( SELECT DISTINCT                        " &
"                    b.ID_DEPART,                    " &
"                    b.DEPART_NAME,                  " &
"                    a.sku                           " &
"               from " + Parameters!Table.Value + ".sku a " &
"         inner join ENTERPRISE.DEPARTSECTORSKU b         " &
"                 on to_char(b.ID_DEPART) = to_char(a.SKUGROUP) ) DEPART " &      
"        ON DEPART.sku = TRIM(TDREC941.T$ITEM)                           " &
"                                                                        " &
"INNER JOIN ( select RC.RECEIPTKEY        ASN,                           " &
"                    RC.WHSEID            ID_FILIAL,                     " &
"                    CL.UDF2              DESCR_FILIAL,                  " &
"                    TPNT.DESCRIPTION     OPERACAO,                      " &
"                    RD.SUSR1             NF,                            " &
"                    RC.SUPPLIERCODE,                                    " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE,      " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE)  " &
"                                         DT_NR                  " &
"               from " + Parameters!Table.Value + ".RECEIPT  RC  " &
"         inner join " + Parameters!Table.Value + ".RECEIPTDETAIL RD " &
"                 on RD.RECEIPTKEY =  RC.RECEIPTKEY " &
"         inner join ENTERPRISE.CODELKUP  CL        " &
"                 on UPPER(CL.UDF1) = RC.WHSEID     " &
"          left join ( SELECT clkp.code  COD,       " &
"                             trans.description     " &
"                        FROM " + Parameters!Table.Value + ".codelkup clkp " &
"                  INNER JOIN " + Parameters!Table.Value + ".translationlist trans  " &
"                          ON trans.code = clkp.code          " &
"                         AND trans.joinkey1 = clkp.listname  " &
"                       WHERE clkp.listname = 'RECEIPTYPE'    " &
"                         AND trans.locale = 'pt'             " &
"                         AND trans.tblname = 'CODELKUP'      " &
"                         AND Trim(clkp.code) is not null ) tpnt    " &
"                 on TO_CHAR(tpnt.COD) = TO_CHAR(rc.TYPE) " &
"              where RD.SUSR1 IS NOT NULL " &
"           group by RC.RECEIPTKEY,       " &
"                    RC.WHSEID,           " &
"                    CL.UDF2,             " &
"                    TPNT.DESCRIPTION,    " &
"                    RD.SUSR1,            " &
"                    RC.SUPPLIERCODE,     " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE, " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE) ) QWMS " &
"        ON QWMS.NF = TDREC940.T$DOCN$L || '/' || TDREC940.T$SERI$L " &
"       AND QWMS.SUPPLIERCODE  = TDREC940.T$BPID$L " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD001301@PLN01 TCIBD001     " &
"        ON TCIBD001.T$ITEM = TDREC941.T$ITEM      " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD936301@PLN01 TCIBD936     " &
"        ON TCIBD936.T$IFGC$L = TCIBD001.T$IFGC$L  " &
"                                                  " &
"WHERE TDREC940.T$RFDT$L IN (1,2,5,10,28)          " &
"  AND TRUNC(QWMS.DT_NR) " &
" Between '" + Parameters!DataDe.Value + "'  " &
"  And '" + Parameters!DataAte.Value + "' " &
"   AND CASE WHEN NVL(TDREC940.T$STAT$L, 0) not in (1,3,4,5,6,200,201)  " &
"  THEN 0   " &
"   ELSE TDREC940.T$STAT$L " &
"  END IN (" + JOIN(Parameters!Situacao.Value, ", ") + ")   " &
" 		 " &
"ORDER BY 3,5,6   "

,

"SELECT QWMS.ASN,         " &
"       QWMS.ID_FILIAL,   " &
"       QWMS.DESCR_FILIAL," &
"       QWMS.OPERACAO,    " &
"       QWMS.DT_NR,       " &
"       CASE WHEN TDREC940.T$STAT$L =   1 THEN 'ABERTO'                 " &
"            WHEN TDREC940.T$STAT$L =   3 THEN 'NÃO APROVADO'           " &
"            WHEN TDREC940.T$STAT$L =   4 THEN 'APROVADO'               " &
"            WHEN TDREC940.T$STAT$L =   5 THEN 'APROVADO COM PROBLEMA'  " &
"            WHEN TDREC940.T$STAT$L =   6 THEN 'ESTORNADO'              " &
"            WHEN TDREC940.T$STAT$L = 200 THEN 'AGURARDANDO WMS'        " &
"            WHEN TDREC940.T$STAT$L = 201 THEN 'PRONTO PARA ENVIAR WMS' " &
"            ELSE                              'NÃO APLICAVEL'          " &
"        END                                      SITUACAO_NOTA,        " &
"       QWMS.NF,                                                        " &
"       CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(TDREC940.T$DATE$L,           " &
"         'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')  " &
"        AT time zone 'America/Sao_Paulo') AS DATE)   DATA_EMISSAO,         " &
"       TDREC940.T$FOVN$L                         CNPJ_FORNCEDOR,       " &
"       TDREC940.T$OPFC$L                         CFOP,                 " &
"       TDREC940.T$OPOR$L                         SEQ_CFOP,             " &
"       DEPART.ID_DEPART                          ID_DEPARTAMENTO,      " &
"       DEPART.DEPART_NAME                        DESCR_DEPARTAMENTO,   " &
"       TDREC941.T$ITEM                           ID_ITEM,              " &
"       TCIBD001.T$DSCA                           DESCR_ITEM,           " &
"       TCIBD936.T$FRAT$L                         NBM,                  " &
"       TCIBD936.T$IFGC$L                         SEQ_NBM,              " &
"       TDREC941.T$PRIC$L                         CUSTO,                " &
"       TDREC941.T$QNTY$L                         QTDE,                 " &
"       TDREC941.T$GAMT$L                         VALOR_MERCARIA,       " &
"       TDREC941.ICMS ICMS_PROPRIO,          " &
"       TDREC941.ICMS_ST_COM_CONV,           " &
"       TDREC941.ICMS_ST_SEM_CONV            " &
"FROM   BAANDB.TTDREC940301@PLN01 TDREC940     " &
"                                              " &
"INNER JOIN ( select L.T$FIRE$L,               " &
"                    L.T$ITEM$L T$ITEM,        " &
"                    SUM(L.T$PRIC$L) T$PRIC$L, " &
"                    SUM(L.T$QNTY$L) T$QNTY$L, " &
"                    SUM(L.T$GAMT$L) T$GAMT$L, " &
"                    SUM(NVL(ICMS.T$AMNT$L,0)) ICMS," &
"                    SUM(CASE WHEN T$ISCO$C  = 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_COM_CONV,   " &
"                    SUM(CASE WHEN T$ISCO$C != 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_SEM_CONV    " &
"               from BAANDB.TTDREC941301@PLN01 L     " &
"          left join baandb.ttdrec942301@pln01 ICMS  " &
"                 on ICMS.T$FIRE$L = L.T$FIRE$L      " &
"                and ICMS.T$LINE$L = L.T$LINE$L      " &
"                and ICMS.T$BRTY$L = 1               " &
"          left join baandb.ttdrec942301@pln01 ICST  " &
"                 on ICST.T$FIRE$L = L.T$FIRE$L      " &
"                and ICST.T$LINE$L = L.T$LINE$L      " &
"                and ICST.T$BRTY$L = 2               " &
"          left join baandb.ttdrec949301@pln01 ICCP  " &
"                 on  ICCP.T$FIRE$L = ICST.T$FIRE$L  " &
"                and ICCP.T$BRTY$L = ICST.T$BRTY$L   " &
"           group by L.T$FIRE$L,                     " &
"                    L.T$ITEM$L ) TDREC941           " &
"        ON TDREC941.T$FIRE$L = TDREC940.T$FIRE$L    " &
"                                                    " &
" LEFT JOIN ( SELECT DISTINCT                        " &
"                    b.ID_DEPART,                    " &
"                    b.DEPART_NAME,                  " &
"                    a.sku                           " &
"               from WMWHSE1.sku a " &
"         inner join ENTERPRISE.DEPARTSECTORSKU b         " &
"                 on to_char(b.ID_DEPART) = to_char(a.SKUGROUP) ) DEPART " &      
"        ON DEPART.sku = TRIM(TDREC941.T$ITEM)                           " &
"                                                                        " &
"INNER JOIN ( select RC.RECEIPTKEY        ASN,                           " &
"                    RC.WHSEID            ID_FILIAL,                     " &
"                    CL.UDF2              DESCR_FILIAL,                  " &
"                    TPNT.DESCRIPTION     OPERACAO,                      " &
"                    RD.SUSR1             NF,                            " &
"                    RC.SUPPLIERCODE,                                    " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE,      " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE)  " &
"                                         DT_NR                  " &
"               from WMWHSE1.RECEIPT  RC  " &
"         inner join WMWHSE1.RECEIPTDETAIL RD " &
"                 on RD.RECEIPTKEY =  RC.RECEIPTKEY " &
"         inner join ENTERPRISE.CODELKUP  CL        " &
"                 on UPPER(CL.UDF1) = RC.WHSEID     " &
"          left join ( SELECT clkp.code  COD,       " &
"                             trans.description     " &
"                        FROM WMWHSE1.codelkup clkp " &
"                  INNER JOIN WMWHSE1.translationlist trans  " &
"                          ON trans.code = clkp.code          " &
"                         AND trans.joinkey1 = clkp.listname  " &
"                       WHERE clkp.listname = 'RECEIPTYPE'    " &
"                         AND trans.locale = 'pt'             " &
"                         AND trans.tblname = 'CODELKUP'      " &
"                         AND Trim(clkp.code) is not null ) tpnt    " &
"                 on TO_CHAR(tpnt.COD) = TO_CHAR(rc.TYPE) " &
"              where RD.SUSR1 IS NOT NULL " &
"           group by RC.RECEIPTKEY,       " &
"                    RC.WHSEID,           " &
"                    CL.UDF2,             " &
"                    TPNT.DESCRIPTION,    " &
"                    RD.SUSR1,            " &
"                    RC.SUPPLIERCODE,     " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE, " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE) ) QWMS " &
"        ON QWMS.NF = TDREC940.T$DOCN$L || '/' || TDREC940.T$SERI$L " &
"       AND QWMS.SUPPLIERCODE  = TDREC940.T$BPID$L " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD001301@PLN01 TCIBD001     " &
"        ON TCIBD001.T$ITEM = TDREC941.T$ITEM      " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD936301@PLN01 TCIBD936     " &
"        ON TCIBD936.T$IFGC$L = TCIBD001.T$IFGC$L  " &
"                                                  " &
"WHERE TDREC940.T$RFDT$L IN (1,2,5,10,28)          " &
"  AND TRUNC(QWMS.DT_NR) " &
" Between '" + Parameters!DataDe.Value + "'  " &
"  And '" + Parameters!DataAte.Value + "' " &
"   AND CASE WHEN NVL(TDREC940.T$STAT$L, 0) not in (1,3,4,5,6,200,201)  " &
"  THEN 0   " &
"   ELSE TDREC940.T$STAT$L " &
"  END IN (" + JOIN(Parameters!Situacao.Value, ", ") + ")   " &
"Union " &
"SELECT QWMS.ASN,         " &
"       QWMS.ID_FILIAL,   " &
"       QWMS.DESCR_FILIAL," &
"       QWMS.OPERACAO,    " &
"       QWMS.DT_NR,       " &
"       CASE WHEN TDREC940.T$STAT$L =   1 THEN 'ABERTO'                 " &
"            WHEN TDREC940.T$STAT$L =   3 THEN 'NÃO APROVADO'           " &
"            WHEN TDREC940.T$STAT$L =   4 THEN 'APROVADO'               " &
"            WHEN TDREC940.T$STAT$L =   5 THEN 'APROVADO COM PROBLEMA'  " &
"            WHEN TDREC940.T$STAT$L =   6 THEN 'ESTORNADO'              " &
"            WHEN TDREC940.T$STAT$L = 200 THEN 'AGURARDANDO WMS'        " &
"            WHEN TDREC940.T$STAT$L = 201 THEN 'PRONTO PARA ENVIAR WMS' " &
"            ELSE                              'NÃO APLICAVEL'          " &
"        END                                      SITUACAO_NOTA,        " &
"       QWMS.NF,                                                        " &
"       CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(TDREC940.T$DATE$L,           " &
"         'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')  " &
"        AT time zone 'America/Sao_Paulo') AS DATE)   DATA_EMISSAO,         " &
"       TDREC940.T$FOVN$L                         CNPJ_FORNCEDOR,       " &
"       TDREC940.T$OPFC$L                         CFOP,                 " &
"       TDREC940.T$OPOR$L                         SEQ_CFOP,             " &
"       DEPART.ID_DEPART                          ID_DEPARTAMENTO,      " &
"       DEPART.DEPART_NAME                        DESCR_DEPARTAMENTO,   " &
"       TDREC941.T$ITEM                           ID_ITEM,              " &
"       TCIBD001.T$DSCA                           DESCR_ITEM,           " &
"       TCIBD936.T$FRAT$L                         NBM,                  " &
"       TCIBD936.T$IFGC$L                         SEQ_NBM,              " &
"       TDREC941.T$PRIC$L                         CUSTO,                " &
"       TDREC941.T$QNTY$L                         QTDE,                 " &
"       TDREC941.T$GAMT$L                         VALOR_MERCARIA,       " &
"       TDREC941.ICMS ICMS_PROPRIO,          " &
"       TDREC941.ICMS_ST_COM_CONV,           " &
"       TDREC941.ICMS_ST_SEM_CONV            " &
"FROM   BAANDB.TTDREC940301@PLN01 TDREC940     " &
"                                              " &
"INNER JOIN ( select L.T$FIRE$L,               " &
"                    L.T$ITEM$L T$ITEM,        " &
"                    SUM(L.T$PRIC$L) T$PRIC$L, " &
"                    SUM(L.T$QNTY$L) T$QNTY$L, " &
"                    SUM(L.T$GAMT$L) T$GAMT$L, " &
"                    SUM(NVL(ICMS.T$AMNT$L,0)) ICMS," &
"                    SUM(CASE WHEN T$ISCO$C  = 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_COM_CONV,   " &
"                    SUM(CASE WHEN T$ISCO$C != 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_SEM_CONV    " &
"               from BAANDB.TTDREC941301@PLN01 L     " &
"          left join baandb.ttdrec942301@pln01 ICMS  " &
"                 on ICMS.T$FIRE$L = L.T$FIRE$L      " &
"                and ICMS.T$LINE$L = L.T$LINE$L      " &
"                and ICMS.T$BRTY$L = 1               " &
"          left join baandb.ttdrec942301@pln01 ICST  " &
"                 on ICST.T$FIRE$L = L.T$FIRE$L      " &
"                and ICST.T$LINE$L = L.T$LINE$L      " &
"                and ICST.T$BRTY$L = 2               " &
"          left join baandb.ttdrec949301@pln01 ICCP  " &
"                 on  ICCP.T$FIRE$L = ICST.T$FIRE$L  " &
"                and ICCP.T$BRTY$L = ICST.T$BRTY$L   " &
"           group by L.T$FIRE$L,                     " &
"                    L.T$ITEM$L ) TDREC941           " &
"        ON TDREC941.T$FIRE$L = TDREC940.T$FIRE$L    " &
"                                                    " &
" LEFT JOIN ( SELECT DISTINCT                        " &
"                    b.ID_DEPART,                    " &
"                    b.DEPART_NAME,                  " &
"                    a.sku                           " &
"               from WMWHSE2.sku a " &
"         inner join ENTERPRISE.DEPARTSECTORSKU b         " &
"                 on to_char(b.ID_DEPART) = to_char(a.SKUGROUP) ) DEPART " &      
"        ON DEPART.sku = TRIM(TDREC941.T$ITEM)                           " &
"                                                                        " &
"INNER JOIN ( select RC.RECEIPTKEY        ASN,                           " &
"                    RC.WHSEID            ID_FILIAL,                     " &
"                    CL.UDF2              DESCR_FILIAL,                  " &
"                    TPNT.DESCRIPTION     OPERACAO,                      " &
"                    RD.SUSR1             NF,                            " &
"                    RC.SUPPLIERCODE,                                    " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE,      " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE)  " &
"                                         DT_NR                  " &
"               from WMWHSE2.RECEIPT  RC  " &
"         inner join WMWHSE2.RECEIPTDETAIL RD " &
"                 on RD.RECEIPTKEY =  RC.RECEIPTKEY " &
"         inner join ENTERPRISE.CODELKUP  CL        " &
"                 on UPPER(CL.UDF1) = RC.WHSEID     " &
"          left join ( SELECT clkp.code  COD,       " &
"                             trans.description     " &
"                        FROM WMWHSE2.codelkup clkp " &
"                  INNER JOIN WMWHSE2.translationlist trans  " &
"                          ON trans.code = clkp.code          " &
"                         AND trans.joinkey1 = clkp.listname  " &
"                       WHERE clkp.listname = 'RECEIPTYPE'    " &
"                         AND trans.locale = 'pt'             " &
"                         AND trans.tblname = 'CODELKUP'      " &
"                         AND Trim(clkp.code) is not null ) tpnt    " &
"                 on TO_CHAR(tpnt.COD) = TO_CHAR(rc.TYPE) " &
"              where RD.SUSR1 IS NOT NULL " &
"           group by RC.RECEIPTKEY,       " &
"                    RC.WHSEID,           " &
"                    CL.UDF2,             " &
"                    TPNT.DESCRIPTION,    " &
"                    RD.SUSR1,            " &
"                    RC.SUPPLIERCODE,     " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE, " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE) ) QWMS " &
"        ON QWMS.NF = TDREC940.T$DOCN$L || '/' || TDREC940.T$SERI$L " &
"       AND QWMS.SUPPLIERCODE  = TDREC940.T$BPID$L " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD001301@PLN01 TCIBD001     " &
"        ON TCIBD001.T$ITEM = TDREC941.T$ITEM      " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD936301@PLN01 TCIBD936     " &
"        ON TCIBD936.T$IFGC$L = TCIBD001.T$IFGC$L  " &
"                                                  " &
"WHERE TDREC940.T$RFDT$L IN (1,2,5,10,28)          " &
"  AND TRUNC(QWMS.DT_NR) " &
" Between '" + Parameters!DataDe.Value + "'  " &
"  And '" + Parameters!DataAte.Value + "' " &
"   AND CASE WHEN NVL(TDREC940.T$STAT$L, 0) not in (1,3,4,5,6,200,201)  " &
"  THEN 0   " &
"   ELSE TDREC940.T$STAT$L " &
"  END IN (" + JOIN(Parameters!Situacao.Value, ", ") + ")   " &
"Union " &
"SELECT QWMS.ASN,         " &
"       QWMS.ID_FILIAL,   " &
"       QWMS.DESCR_FILIAL," &
"       QWMS.OPERACAO,    " &
"       QWMS.DT_NR,       " &
"       CASE WHEN TDREC940.T$STAT$L =   1 THEN 'ABERTO'                 " &
"            WHEN TDREC940.T$STAT$L =   3 THEN 'NÃO APROVADO'           " &
"            WHEN TDREC940.T$STAT$L =   4 THEN 'APROVADO'               " &
"            WHEN TDREC940.T$STAT$L =   5 THEN 'APROVADO COM PROBLEMA'  " &
"            WHEN TDREC940.T$STAT$L =   6 THEN 'ESTORNADO'              " &
"            WHEN TDREC940.T$STAT$L = 200 THEN 'AGURARDANDO WMS'        " &
"            WHEN TDREC940.T$STAT$L = 201 THEN 'PRONTO PARA ENVIAR WMS' " &
"            ELSE                              'NÃO APLICAVEL'          " &
"        END                                      SITUACAO_NOTA,        " &
"       QWMS.NF,                                                        " &
"       CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(TDREC940.T$DATE$L,           " &
"         'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')  " &
"        AT time zone 'America/Sao_Paulo') AS DATE)   DATA_EMISSAO,         " &
"       TDREC940.T$FOVN$L                         CNPJ_FORNCEDOR,       " &
"       TDREC940.T$OPFC$L                         CFOP,                 " &
"       TDREC940.T$OPOR$L                         SEQ_CFOP,             " &
"       DEPART.ID_DEPART                          ID_DEPARTAMENTO,      " &
"       DEPART.DEPART_NAME                        DESCR_DEPARTAMENTO,   " &
"       TDREC941.T$ITEM                           ID_ITEM,              " &
"       TCIBD001.T$DSCA                           DESCR_ITEM,           " &
"       TCIBD936.T$FRAT$L                         NBM,                  " &
"       TCIBD936.T$IFGC$L                         SEQ_NBM,              " &
"       TDREC941.T$PRIC$L                         CUSTO,                " &
"       TDREC941.T$QNTY$L                         QTDE,                 " &
"       TDREC941.T$GAMT$L                         VALOR_MERCARIA,       " &
"       TDREC941.ICMS ICMS_PROPRIO,          " &
"       TDREC941.ICMS_ST_COM_CONV,           " &
"       TDREC941.ICMS_ST_SEM_CONV            " &
"FROM   BAANDB.TTDREC940301@PLN01 TDREC940     " &
"                                              " &
"INNER JOIN ( select L.T$FIRE$L,               " &
"                    L.T$ITEM$L T$ITEM,        " &
"                    SUM(L.T$PRIC$L) T$PRIC$L, " &
"                    SUM(L.T$QNTY$L) T$QNTY$L, " &
"                    SUM(L.T$GAMT$L) T$GAMT$L, " &
"                    SUM(NVL(ICMS.T$AMNT$L,0)) ICMS," &
"                    SUM(CASE WHEN T$ISCO$C  = 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_COM_CONV,   " &
"                    SUM(CASE WHEN T$ISCO$C != 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_SEM_CONV    " &
"               from BAANDB.TTDREC941301@PLN01 L     " &
"          left join baandb.ttdrec942301@pln01 ICMS  " &
"                 on ICMS.T$FIRE$L = L.T$FIRE$L      " &
"                and ICMS.T$LINE$L = L.T$LINE$L      " &
"                and ICMS.T$BRTY$L = 1               " &
"          left join baandb.ttdrec942301@pln01 ICST  " &
"                 on ICST.T$FIRE$L = L.T$FIRE$L      " &
"                and ICST.T$LINE$L = L.T$LINE$L      " &
"                and ICST.T$BRTY$L = 2               " &
"          left join baandb.ttdrec949301@pln01 ICCP  " &
"                 on  ICCP.T$FIRE$L = ICST.T$FIRE$L  " &
"                and ICCP.T$BRTY$L = ICST.T$BRTY$L   " &
"           group by L.T$FIRE$L,                     " &
"                    L.T$ITEM$L ) TDREC941           " &
"        ON TDREC941.T$FIRE$L = TDREC940.T$FIRE$L    " &
"                                                    " &
" LEFT JOIN ( SELECT DISTINCT                        " &
"                    b.ID_DEPART,                    " &
"                    b.DEPART_NAME,                  " &
"                    a.sku                           " &
"               from WMWHSE3.sku a " &
"         inner join ENTERPRISE.DEPARTSECTORSKU b         " &
"                 on to_char(b.ID_DEPART) = to_char(a.SKUGROUP) ) DEPART " &      
"        ON DEPART.sku = TRIM(TDREC941.T$ITEM)                           " &
"                                                                        " &
"INNER JOIN ( select RC.RECEIPTKEY        ASN,                           " &
"                    RC.WHSEID            ID_FILIAL,                     " &
"                    CL.UDF2              DESCR_FILIAL,                  " &
"                    TPNT.DESCRIPTION     OPERACAO,                      " &
"                    RD.SUSR1             NF,                            " &
"                    RC.SUPPLIERCODE,                                    " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE,      " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE)  " &
"                                         DT_NR                  " &
"               from WMWHSE3.RECEIPT  RC  " &
"         inner join WMWHSE3.RECEIPTDETAIL RD " &
"                 on RD.RECEIPTKEY =  RC.RECEIPTKEY " &
"         inner join ENTERPRISE.CODELKUP  CL        " &
"                 on UPPER(CL.UDF1) = RC.WHSEID     " &
"          left join ( SELECT clkp.code  COD,       " &
"                             trans.description     " &
"                        FROM WMWHSE3.codelkup clkp " &
"                  INNER JOIN WMWHSE3.translationlist trans  " &
"                          ON trans.code = clkp.code          " &
"                         AND trans.joinkey1 = clkp.listname  " &
"                       WHERE clkp.listname = 'RECEIPTYPE'    " &
"                         AND trans.locale = 'pt'             " &
"                         AND trans.tblname = 'CODELKUP'      " &
"                         AND Trim(clkp.code) is not null ) tpnt    " &
"                 on TO_CHAR(tpnt.COD) = TO_CHAR(rc.TYPE) " &
"              where RD.SUSR1 IS NOT NULL " &
"           group by RC.RECEIPTKEY,       " &
"                    RC.WHSEID,           " &
"                    CL.UDF2,             " &
"                    TPNT.DESCRIPTION,    " &
"                    RD.SUSR1,            " &
"                    RC.SUPPLIERCODE,     " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE, " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE) ) QWMS " &
"        ON QWMS.NF = TDREC940.T$DOCN$L || '/' || TDREC940.T$SERI$L " &
"       AND QWMS.SUPPLIERCODE  = TDREC940.T$BPID$L " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD001301@PLN01 TCIBD001     " &
"        ON TCIBD001.T$ITEM = TDREC941.T$ITEM      " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD936301@PLN01 TCIBD936     " &
"        ON TCIBD936.T$IFGC$L = TCIBD001.T$IFGC$L  " &
"                                                  " &
"WHERE TDREC940.T$RFDT$L IN (1,2,5,10,28)          " &
"  AND TRUNC(QWMS.DT_NR) " &
" Between '" + Parameters!DataDe.Value + "'  " &
"  And '" + Parameters!DataAte.Value + "' " &
"   AND CASE WHEN NVL(TDREC940.T$STAT$L, 0) not in (1,3,4,5,6,200,201)  " &
"  THEN 0   " &
"   ELSE TDREC940.T$STAT$L " &
"  END IN (" + JOIN(Parameters!Situacao.Value, ", ") + ")   " &
"Union " &
"SELECT QWMS.ASN,         " &
"       QWMS.ID_FILIAL,   " &
"       QWMS.DESCR_FILIAL," &
"       QWMS.OPERACAO,    " &
"       QWMS.DT_NR,       " &
"       CASE WHEN TDREC940.T$STAT$L =   1 THEN 'ABERTO'                 " &
"            WHEN TDREC940.T$STAT$L =   3 THEN 'NÃO APROVADO'           " &
"            WHEN TDREC940.T$STAT$L =   4 THEN 'APROVADO'               " &
"            WHEN TDREC940.T$STAT$L =   5 THEN 'APROVADO COM PROBLEMA'  " &
"            WHEN TDREC940.T$STAT$L =   6 THEN 'ESTORNADO'              " &
"            WHEN TDREC940.T$STAT$L = 200 THEN 'AGURARDANDO WMS'        " &
"            WHEN TDREC940.T$STAT$L = 201 THEN 'PRONTO PARA ENVIAR WMS' " &
"            ELSE                              'NÃO APLICAVEL'          " &
"        END                                      SITUACAO_NOTA,        " &
"       QWMS.NF,                                                        " &
"       CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(TDREC940.T$DATE$L,           " &
"         'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')  " &
"        AT time zone 'America/Sao_Paulo') AS DATE)   DATA_EMISSAO,         " &
"       TDREC940.T$FOVN$L                         CNPJ_FORNCEDOR,       " &
"       TDREC940.T$OPFC$L                         CFOP,                 " &
"       TDREC940.T$OPOR$L                         SEQ_CFOP,             " &
"       DEPART.ID_DEPART                          ID_DEPARTAMENTO,      " &
"       DEPART.DEPART_NAME                        DESCR_DEPARTAMENTO,   " &
"       TDREC941.T$ITEM                           ID_ITEM,              " &
"       TCIBD001.T$DSCA                           DESCR_ITEM,           " &
"       TCIBD936.T$FRAT$L                         NBM,                  " &
"       TCIBD936.T$IFGC$L                         SEQ_NBM,              " &
"       TDREC941.T$PRIC$L                         CUSTO,                " &
"       TDREC941.T$QNTY$L                         QTDE,                 " &
"       TDREC941.T$GAMT$L                         VALOR_MERCARIA,       " &
"       TDREC941.ICMS ICMS_PROPRIO,          " &
"       TDREC941.ICMS_ST_COM_CONV,           " &
"       TDREC941.ICMS_ST_SEM_CONV            " &
"FROM   BAANDB.TTDREC940301@PLN01 TDREC940     " &
"                                              " &
"INNER JOIN ( select L.T$FIRE$L,               " &
"                    L.T$ITEM$L T$ITEM,        " &
"                    SUM(L.T$PRIC$L) T$PRIC$L, " &
"                    SUM(L.T$QNTY$L) T$QNTY$L, " &
"                    SUM(L.T$GAMT$L) T$GAMT$L, " &
"                    SUM(NVL(ICMS.T$AMNT$L,0)) ICMS," &
"                    SUM(CASE WHEN T$ISCO$C  = 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_COM_CONV,   " &
"                    SUM(CASE WHEN T$ISCO$C != 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_SEM_CONV    " &
"               from BAANDB.TTDREC941301@PLN01 L     " &
"          left join baandb.ttdrec942301@pln01 ICMS  " &
"                 on ICMS.T$FIRE$L = L.T$FIRE$L      " &
"                and ICMS.T$LINE$L = L.T$LINE$L      " &
"                and ICMS.T$BRTY$L = 1               " &
"          left join baandb.ttdrec942301@pln01 ICST  " &
"                 on ICST.T$FIRE$L = L.T$FIRE$L      " &
"                and ICST.T$LINE$L = L.T$LINE$L      " &
"                and ICST.T$BRTY$L = 2               " &
"          left join baandb.ttdrec949301@pln01 ICCP  " &
"                 on  ICCP.T$FIRE$L = ICST.T$FIRE$L  " &
"                and ICCP.T$BRTY$L = ICST.T$BRTY$L   " &
"           group by L.T$FIRE$L,                     " &
"                    L.T$ITEM$L ) TDREC941           " &
"        ON TDREC941.T$FIRE$L = TDREC940.T$FIRE$L    " &
"                                                    " &
" LEFT JOIN ( SELECT DISTINCT                        " &
"                    b.ID_DEPART,                    " &
"                    b.DEPART_NAME,                  " &
"                    a.sku                           " &
"               from WMWHSE4.sku a " &
"         inner join ENTERPRISE.DEPARTSECTORSKU b         " &
"                 on to_char(b.ID_DEPART) = to_char(a.SKUGROUP) ) DEPART " &      
"        ON DEPART.sku = TRIM(TDREC941.T$ITEM)                           " &
"                                                                        " &
"INNER JOIN ( select RC.RECEIPTKEY        ASN,                           " &
"                    RC.WHSEID            ID_FILIAL,                     " &
"                    CL.UDF2              DESCR_FILIAL,                  " &
"                    TPNT.DESCRIPTION     OPERACAO,                      " &
"                    RD.SUSR1             NF,                            " &
"                    RC.SUPPLIERCODE,                                    " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE,      " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE)  " &
"                                         DT_NR                  " &
"               from WMWHSE4.RECEIPT  RC  " &
"         inner join WMWHSE4.RECEIPTDETAIL RD " &
"                 on RD.RECEIPTKEY =  RC.RECEIPTKEY " &
"         inner join ENTERPRISE.CODELKUP  CL        " &
"                 on UPPER(CL.UDF1) = RC.WHSEID     " &
"          left join ( SELECT clkp.code  COD,       " &
"                             trans.description     " &
"                        FROM WMWHSE4.codelkup clkp " &
"                  INNER JOIN WMWHSE4.translationlist trans  " &
"                          ON trans.code = clkp.code          " &
"                         AND trans.joinkey1 = clkp.listname  " &
"                       WHERE clkp.listname = 'RECEIPTYPE'    " &
"                         AND trans.locale = 'pt'             " &
"                         AND trans.tblname = 'CODELKUP'      " &
"                         AND Trim(clkp.code) is not null ) tpnt    " &
"                 on TO_CHAR(tpnt.COD) = TO_CHAR(rc.TYPE) " &
"              where RD.SUSR1 IS NOT NULL " &
"           group by RC.RECEIPTKEY,       " &
"                    RC.WHSEID,           " &
"                    CL.UDF2,             " &
"                    TPNT.DESCRIPTION,    " &
"                    RD.SUSR1,            " &
"                    RC.SUPPLIERCODE,     " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE, " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE) ) QWMS " &
"        ON QWMS.NF = TDREC940.T$DOCN$L || '/' || TDREC940.T$SERI$L " &
"       AND QWMS.SUPPLIERCODE  = TDREC940.T$BPID$L " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD001301@PLN01 TCIBD001     " &
"        ON TCIBD001.T$ITEM = TDREC941.T$ITEM      " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD936301@PLN01 TCIBD936     " &
"        ON TCIBD936.T$IFGC$L = TCIBD001.T$IFGC$L  " &
"                                                  " &
"WHERE TDREC940.T$RFDT$L IN (1,2,5,10,28)          " &
"  AND TRUNC(QWMS.DT_NR) " &
" Between '" + Parameters!DataDe.Value + "'  " &
"  And '" + Parameters!DataAte.Value + "' " &
"   AND CASE WHEN NVL(TDREC940.T$STAT$L, 0) not in (1,3,4,5,6,200,201)  " &
"  THEN 0   " &
"   ELSE TDREC940.T$STAT$L " &
"  END IN (" + JOIN(Parameters!Situacao.Value, ", ") + ")   " &
"Union " &
"SELECT QWMS.ASN,         " &
"       QWMS.ID_FILIAL,   " &
"       QWMS.DESCR_FILIAL," &
"       QWMS.OPERACAO,    " &
"       QWMS.DT_NR,       " &
"       CASE WHEN TDREC940.T$STAT$L =   1 THEN 'ABERTO'                 " &
"            WHEN TDREC940.T$STAT$L =   3 THEN 'NÃO APROVADO'           " &
"            WHEN TDREC940.T$STAT$L =   4 THEN 'APROVADO'               " &
"            WHEN TDREC940.T$STAT$L =   5 THEN 'APROVADO COM PROBLEMA'  " &
"            WHEN TDREC940.T$STAT$L =   6 THEN 'ESTORNADO'              " &
"            WHEN TDREC940.T$STAT$L = 200 THEN 'AGURARDANDO WMS'        " &
"            WHEN TDREC940.T$STAT$L = 201 THEN 'PRONTO PARA ENVIAR WMS' " &
"            ELSE                              'NÃO APLICAVEL'          " &
"        END                                      SITUACAO_NOTA,        " &
"       QWMS.NF,                                                        " &
"       CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(TDREC940.T$DATE$L,           " &
"         'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')  " &
"        AT time zone 'America/Sao_Paulo') AS DATE)   DATA_EMISSAO,         " &
"       TDREC940.T$FOVN$L                         CNPJ_FORNCEDOR,       " &
"       TDREC940.T$OPFC$L                         CFOP,                 " &
"       TDREC940.T$OPOR$L                         SEQ_CFOP,             " &
"       DEPART.ID_DEPART                          ID_DEPARTAMENTO,      " &
"       DEPART.DEPART_NAME                        DESCR_DEPARTAMENTO,   " &
"       TDREC941.T$ITEM                           ID_ITEM,              " &
"       TCIBD001.T$DSCA                           DESCR_ITEM,           " &
"       TCIBD936.T$FRAT$L                         NBM,                  " &
"       TCIBD936.T$IFGC$L                         SEQ_NBM,              " &
"       TDREC941.T$PRIC$L                         CUSTO,                " &
"       TDREC941.T$QNTY$L                         QTDE,                 " &
"       TDREC941.T$GAMT$L                         VALOR_MERCARIA,       " &
"       TDREC941.ICMS ICMS_PROPRIO,          " &
"       TDREC941.ICMS_ST_COM_CONV,           " &
"       TDREC941.ICMS_ST_SEM_CONV            " &
"FROM   BAANDB.TTDREC940301@PLN01 TDREC940     " &
"                                              " &
"INNER JOIN ( select L.T$FIRE$L,               " &
"                    L.T$ITEM$L T$ITEM,        " &
"                    SUM(L.T$PRIC$L) T$PRIC$L, " &
"                    SUM(L.T$QNTY$L) T$QNTY$L, " &
"                    SUM(L.T$GAMT$L) T$GAMT$L, " &
"                    SUM(NVL(ICMS.T$AMNT$L,0)) ICMS," &
"                    SUM(CASE WHEN T$ISCO$C  = 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_COM_CONV,   " &
"                    SUM(CASE WHEN T$ISCO$C != 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_SEM_CONV    " &
"               from BAANDB.TTDREC941301@PLN01 L     " &
"          left join baandb.ttdrec942301@pln01 ICMS  " &
"                 on ICMS.T$FIRE$L = L.T$FIRE$L      " &
"                and ICMS.T$LINE$L = L.T$LINE$L      " &
"                and ICMS.T$BRTY$L = 1               " &
"          left join baandb.ttdrec942301@pln01 ICST  " &
"                 on ICST.T$FIRE$L = L.T$FIRE$L      " &
"                and ICST.T$LINE$L = L.T$LINE$L      " &
"                and ICST.T$BRTY$L = 2               " &
"          left join baandb.ttdrec949301@pln01 ICCP  " &
"                 on  ICCP.T$FIRE$L = ICST.T$FIRE$L  " &
"                and ICCP.T$BRTY$L = ICST.T$BRTY$L   " &
"           group by L.T$FIRE$L,                     " &
"                    L.T$ITEM$L ) TDREC941           " &
"        ON TDREC941.T$FIRE$L = TDREC940.T$FIRE$L    " &
"                                                    " &
" LEFT JOIN ( SELECT DISTINCT                        " &
"                    b.ID_DEPART,                    " &
"                    b.DEPART_NAME,                  " &
"                    a.sku                           " &
"               from WMWHSE5.sku a " &
"         inner join ENTERPRISE.DEPARTSECTORSKU b         " &
"                 on to_char(b.ID_DEPART) = to_char(a.SKUGROUP) ) DEPART " &      
"        ON DEPART.sku = TRIM(TDREC941.T$ITEM)                           " &
"                                                                        " &
"INNER JOIN ( select RC.RECEIPTKEY        ASN,                           " &
"                    RC.WHSEID            ID_FILIAL,                     " &
"                    CL.UDF2              DESCR_FILIAL,                  " &
"                    TPNT.DESCRIPTION     OPERACAO,                      " &
"                    RD.SUSR1             NF,                            " &
"                    RC.SUPPLIERCODE,                                    " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE,      " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE)  " &
"                                         DT_NR                  " &
"               from WMWHSE5.RECEIPT  RC  " &
"         inner join WMWHSE5.RECEIPTDETAIL RD " &
"                 on RD.RECEIPTKEY =  RC.RECEIPTKEY " &
"         inner join ENTERPRISE.CODELKUP  CL        " &
"                 on UPPER(CL.UDF1) = RC.WHSEID     " &
"          left join ( SELECT clkp.code  COD,       " &
"                             trans.description     " &
"                        FROM WMWHSE5.codelkup clkp " &
"                  INNER JOIN WMWHSE5.translationlist trans  " &
"                          ON trans.code = clkp.code          " &
"                         AND trans.joinkey1 = clkp.listname  " &
"                       WHERE clkp.listname = 'RECEIPTYPE'    " &
"                         AND trans.locale = 'pt'             " &
"                         AND trans.tblname = 'CODELKUP'      " &
"                         AND Trim(clkp.code) is not null ) tpnt    " &
"                 on TO_CHAR(tpnt.COD) = TO_CHAR(rc.TYPE) " &
"              where RD.SUSR1 IS NOT NULL " &
"           group by RC.RECEIPTKEY,       " &
"                    RC.WHSEID,           " &
"                    CL.UDF2,             " &
"                    TPNT.DESCRIPTION,    " &
"                    RD.SUSR1,            " &
"                    RC.SUPPLIERCODE,     " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE, " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE) ) QWMS " &
"        ON QWMS.NF = TDREC940.T$DOCN$L || '/' || TDREC940.T$SERI$L " &
"       AND QWMS.SUPPLIERCODE  = TDREC940.T$BPID$L " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD001301@PLN01 TCIBD001     " &
"        ON TCIBD001.T$ITEM = TDREC941.T$ITEM      " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD936301@PLN01 TCIBD936     " &
"        ON TCIBD936.T$IFGC$L = TCIBD001.T$IFGC$L  " &
"                                                  " &
"WHERE TDREC940.T$RFDT$L IN (1,2,5,10,28)          " &
"  AND TRUNC(QWMS.DT_NR) " &
" Between '" + Parameters!DataDe.Value + "'  " &
"  And '" + Parameters!DataAte.Value + "' " &
"   AND CASE WHEN NVL(TDREC940.T$STAT$L, 0) not in (1,3,4,5,6,200,201)  " &
"  THEN 0   " &
"   ELSE TDREC940.T$STAT$L " &
"  END IN (" + JOIN(Parameters!Situacao.Value, ", ") + ")   " &
"Union " &
"SELECT QWMS.ASN,         " &
"       QWMS.ID_FILIAL,   " &
"       QWMS.DESCR_FILIAL," &
"       QWMS.OPERACAO,    " &
"       QWMS.DT_NR,       " &
"       CASE WHEN TDREC940.T$STAT$L =   1 THEN 'ABERTO'                 " &
"            WHEN TDREC940.T$STAT$L =   3 THEN 'NÃO APROVADO'           " &
"            WHEN TDREC940.T$STAT$L =   4 THEN 'APROVADO'               " &
"            WHEN TDREC940.T$STAT$L =   5 THEN 'APROVADO COM PROBLEMA'  " &
"            WHEN TDREC940.T$STAT$L =   6 THEN 'ESTORNADO'              " &
"            WHEN TDREC940.T$STAT$L = 200 THEN 'AGURARDANDO WMS'        " &
"            WHEN TDREC940.T$STAT$L = 201 THEN 'PRONTO PARA ENVIAR WMS' " &
"            ELSE                              'NÃO APLICAVEL'          " &
"        END                                      SITUACAO_NOTA,        " &
"       QWMS.NF,                                                        " &
"       CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(TDREC940.T$DATE$L,           " &
"         'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')  " &
"        AT time zone 'America/Sao_Paulo') AS DATE)   DATA_EMISSAO,         " &
"       TDREC940.T$FOVN$L                         CNPJ_FORNCEDOR,       " &
"       TDREC940.T$OPFC$L                         CFOP,                 " &
"       TDREC940.T$OPOR$L                         SEQ_CFOP,             " &
"       DEPART.ID_DEPART                          ID_DEPARTAMENTO,      " &
"       DEPART.DEPART_NAME                        DESCR_DEPARTAMENTO,   " &
"       TDREC941.T$ITEM                           ID_ITEM,              " &
"       TCIBD001.T$DSCA                           DESCR_ITEM,           " &
"       TCIBD936.T$FRAT$L                         NBM,                  " &
"       TCIBD936.T$IFGC$L                         SEQ_NBM,              " &
"       TDREC941.T$PRIC$L                         CUSTO,                " &
"       TDREC941.T$QNTY$L                         QTDE,                 " &
"       TDREC941.T$GAMT$L                         VALOR_MERCARIA,       " &
"       TDREC941.ICMS ICMS_PROPRIO,          " &
"       TDREC941.ICMS_ST_COM_CONV,           " &
"       TDREC941.ICMS_ST_SEM_CONV            " &
"FROM   BAANDB.TTDREC940301@PLN01 TDREC940     " &
"                                              " &
"INNER JOIN ( select L.T$FIRE$L,               " &
"                    L.T$ITEM$L T$ITEM,        " &
"                    SUM(L.T$PRIC$L) T$PRIC$L, " &
"                    SUM(L.T$QNTY$L) T$QNTY$L, " &
"                    SUM(L.T$GAMT$L) T$GAMT$L, " &
"                    SUM(NVL(ICMS.T$AMNT$L,0)) ICMS," &
"                    SUM(CASE WHEN T$ISCO$C  = 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_COM_CONV,   " &
"                    SUM(CASE WHEN T$ISCO$C != 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_SEM_CONV    " &
"               from BAANDB.TTDREC941301@PLN01 L     " &
"          left join baandb.ttdrec942301@pln01 ICMS  " &
"                 on ICMS.T$FIRE$L = L.T$FIRE$L      " &
"                and ICMS.T$LINE$L = L.T$LINE$L      " &
"                and ICMS.T$BRTY$L = 1               " &
"          left join baandb.ttdrec942301@pln01 ICST  " &
"                 on ICST.T$FIRE$L = L.T$FIRE$L      " &
"                and ICST.T$LINE$L = L.T$LINE$L      " &
"                and ICST.T$BRTY$L = 2               " &
"          left join baandb.ttdrec949301@pln01 ICCP  " &
"                 on  ICCP.T$FIRE$L = ICST.T$FIRE$L  " &
"                and ICCP.T$BRTY$L = ICST.T$BRTY$L   " &
"           group by L.T$FIRE$L,                     " &
"                    L.T$ITEM$L ) TDREC941           " &
"        ON TDREC941.T$FIRE$L = TDREC940.T$FIRE$L    " &
"                                                    " &
" LEFT JOIN ( SELECT DISTINCT                        " &
"                    b.ID_DEPART,                    " &
"                    b.DEPART_NAME,                  " &
"                    a.sku                           " &
"               from WMWHSE6.sku a " &
"         inner join ENTERPRISE.DEPARTSECTORSKU b         " &
"                 on to_char(b.ID_DEPART) = to_char(a.SKUGROUP) ) DEPART " &      
"        ON DEPART.sku = TRIM(TDREC941.T$ITEM)                           " &
"                                                                        " &
"INNER JOIN ( select RC.RECEIPTKEY        ASN,                           " &
"                    RC.WHSEID            ID_FILIAL,                     " &
"                    CL.UDF2              DESCR_FILIAL,                  " &
"                    TPNT.DESCRIPTION     OPERACAO,                      " &
"                    RD.SUSR1             NF,                            " &
"                    RC.SUPPLIERCODE,                                    " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE,      " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE)  " &
"                                         DT_NR                  " &
"               from WMWHSE6.RECEIPT  RC  " &
"         inner join WMWHSE6.RECEIPTDETAIL RD " &
"                 on RD.RECEIPTKEY =  RC.RECEIPTKEY " &
"         inner join ENTERPRISE.CODELKUP  CL        " &
"                 on UPPER(CL.UDF1) = RC.WHSEID     " &
"          left join ( SELECT clkp.code  COD,       " &
"                             trans.description     " &
"                        FROM WMWHSE6.codelkup clkp " &
"                  INNER JOIN WMWHSE6.translationlist trans  " &
"                          ON trans.code = clkp.code          " &
"                         AND trans.joinkey1 = clkp.listname  " &
"                       WHERE clkp.listname = 'RECEIPTYPE'    " &
"                         AND trans.locale = 'pt'             " &
"                         AND trans.tblname = 'CODELKUP'      " &
"                         AND Trim(clkp.code) is not null ) tpnt    " &
"                 on TO_CHAR(tpnt.COD) = TO_CHAR(rc.TYPE) " &
"              where RD.SUSR1 IS NOT NULL " &
"           group by RC.RECEIPTKEY,       " &
"                    RC.WHSEID,           " &
"                    CL.UDF2,             " &
"                    TPNT.DESCRIPTION,    " &
"                    RD.SUSR1,            " &
"                    RC.SUPPLIERCODE,     " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE, " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE) ) QWMS " &
"        ON QWMS.NF = TDREC940.T$DOCN$L || '/' || TDREC940.T$SERI$L " &
"       AND QWMS.SUPPLIERCODE  = TDREC940.T$BPID$L " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD001301@PLN01 TCIBD001     " &
"        ON TCIBD001.T$ITEM = TDREC941.T$ITEM      " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD936301@PLN01 TCIBD936     " &
"        ON TCIBD936.T$IFGC$L = TCIBD001.T$IFGC$L  " &
"                                                  " &
"WHERE TDREC940.T$RFDT$L IN (1,2,5,10,28)          " &
"  AND TRUNC(QWMS.DT_NR) " &
" Between '" + Parameters!DataDe.Value + "'  " &
"  And '" + Parameters!DataAte.Value + "' " &
"   AND CASE WHEN NVL(TDREC940.T$STAT$L, 0) not in (1,3,4,5,6,200,201)  " &
"  THEN 0   " &
"   ELSE TDREC940.T$STAT$L " &
"  END IN (" + JOIN(Parameters!Situacao.Value, ", ") + ")   " &
"Union " &
"SELECT QWMS.ASN,         " &
"       QWMS.ID_FILIAL,   " &
"       QWMS.DESCR_FILIAL," &
"       QWMS.OPERACAO,    " &
"       QWMS.DT_NR,       " &
"       CASE WHEN TDREC940.T$STAT$L =   1 THEN 'ABERTO'                 " &
"            WHEN TDREC940.T$STAT$L =   3 THEN 'NÃO APROVADO'           " &
"            WHEN TDREC940.T$STAT$L =   4 THEN 'APROVADO'               " &
"            WHEN TDREC940.T$STAT$L =   5 THEN 'APROVADO COM PROBLEMA'  " &
"            WHEN TDREC940.T$STAT$L =   6 THEN 'ESTORNADO'              " &
"            WHEN TDREC940.T$STAT$L = 200 THEN 'AGURARDANDO WMS'        " &
"            WHEN TDREC940.T$STAT$L = 201 THEN 'PRONTO PARA ENVIAR WMS' " &
"            ELSE                              'NÃO APLICAVEL'          " &
"        END                                      SITUACAO_NOTA,        " &
"       QWMS.NF,                                                        " &
"       CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(TDREC940.T$DATE$L,           " &
"         'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')  " &
"        AT time zone 'America/Sao_Paulo') AS DATE)   DATA_EMISSAO,         " &
"       TDREC940.T$FOVN$L                         CNPJ_FORNCEDOR,       " &
"       TDREC940.T$OPFC$L                         CFOP,                 " &
"       TDREC940.T$OPOR$L                         SEQ_CFOP,             " &
"       DEPART.ID_DEPART                          ID_DEPARTAMENTO,      " &
"       DEPART.DEPART_NAME                        DESCR_DEPARTAMENTO,   " &
"       TDREC941.T$ITEM                           ID_ITEM,              " &
"       TCIBD001.T$DSCA                           DESCR_ITEM,           " &
"       TCIBD936.T$FRAT$L                         NBM,                  " &
"       TCIBD936.T$IFGC$L                         SEQ_NBM,              " &
"       TDREC941.T$PRIC$L                         CUSTO,                " &
"       TDREC941.T$QNTY$L                         QTDE,                 " &
"       TDREC941.T$GAMT$L                         VALOR_MERCARIA,       " &
"       TDREC941.ICMS ICMS_PROPRIO,          " &
"       TDREC941.ICMS_ST_COM_CONV,           " &
"       TDREC941.ICMS_ST_SEM_CONV            " &
"FROM   BAANDB.TTDREC940301@PLN01 TDREC940     " &
"                                              " &
"INNER JOIN ( select L.T$FIRE$L,               " &
"                    L.T$ITEM$L T$ITEM,        " &
"                    SUM(L.T$PRIC$L) T$PRIC$L, " &
"                    SUM(L.T$QNTY$L) T$QNTY$L, " &
"                    SUM(L.T$GAMT$L) T$GAMT$L, " &
"                    SUM(NVL(ICMS.T$AMNT$L,0)) ICMS," &
"                    SUM(CASE WHEN T$ISCO$C  = 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_COM_CONV,   " &
"                    SUM(CASE WHEN T$ISCO$C != 1 THEN NVL(ICST.T$AMNT$L,0) ELSE 0 END) ICMS_ST_SEM_CONV    " &
"               from BAANDB.TTDREC941301@PLN01 L     " &
"          left join baandb.ttdrec942301@pln01 ICMS  " &
"                 on ICMS.T$FIRE$L = L.T$FIRE$L      " &
"                and ICMS.T$LINE$L = L.T$LINE$L      " &
"                and ICMS.T$BRTY$L = 1               " &
"          left join baandb.ttdrec942301@pln01 ICST  " &
"                 on ICST.T$FIRE$L = L.T$FIRE$L      " &
"                and ICST.T$LINE$L = L.T$LINE$L      " &
"                and ICST.T$BRTY$L = 2               " &
"          left join baandb.ttdrec949301@pln01 ICCP  " &
"                 on  ICCP.T$FIRE$L = ICST.T$FIRE$L  " &
"                and ICCP.T$BRTY$L = ICST.T$BRTY$L   " &
"           group by L.T$FIRE$L,                     " &
"                    L.T$ITEM$L ) TDREC941           " &
"        ON TDREC941.T$FIRE$L = TDREC940.T$FIRE$L    " &
"                                                    " &
" LEFT JOIN ( SELECT DISTINCT                        " &
"                    b.ID_DEPART,                    " &
"                    b.DEPART_NAME,                  " &
"                    a.sku                           " &
"               from WMWHSE7.sku a " &
"         inner join ENTERPRISE.DEPARTSECTORSKU b         " &
"                 on to_char(b.ID_DEPART) = to_char(a.SKUGROUP) ) DEPART " &      
"        ON DEPART.sku = TRIM(TDREC941.T$ITEM)                           " &
"                                                                        " &
"INNER JOIN ( select RC.RECEIPTKEY        ASN,                           " &
"                    RC.WHSEID            ID_FILIAL,                     " &
"                    CL.UDF2              DESCR_FILIAL,                  " &
"                    TPNT.DESCRIPTION     OPERACAO,                      " &
"                    RD.SUSR1             NF,                            " &
"                    RC.SUPPLIERCODE,                                    " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE,      " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE)  " &
"                                         DT_NR                  " &
"               from WMWHSE7.RECEIPT  RC  " &
"         inner join WMWHSE7.RECEIPTDETAIL RD " &
"                 on RD.RECEIPTKEY =  RC.RECEIPTKEY " &
"         inner join ENTERPRISE.CODELKUP  CL        " &
"                 on UPPER(CL.UDF1) = RC.WHSEID     " &
"          left join ( SELECT clkp.code  COD,       " &
"                             trans.description     " &
"                        FROM WMWHSE7.codelkup clkp " &
"                  INNER JOIN WMWHSE7.translationlist trans  " &
"                          ON trans.code = clkp.code          " &
"                         AND trans.joinkey1 = clkp.listname  " &
"                       WHERE clkp.listname = 'RECEIPTYPE'    " &
"                         AND trans.locale = 'pt'             " &
"                         AND trans.tblname = 'CODELKUP'      " &
"                         AND Trim(clkp.code) is not null ) tpnt    " &
"                 on TO_CHAR(tpnt.COD) = TO_CHAR(rc.TYPE) " &
"              where RD.SUSR1 IS NOT NULL " &
"           group by RC.RECEIPTKEY,       " &
"                    RC.WHSEID,           " &
"                    CL.UDF2,             " &
"                    TPNT.DESCRIPTION,    " &
"                    RD.SUSR1,            " &
"                    RC.SUPPLIERCODE,     " &
"                    CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(RC.ADDDATE, " &
"                      'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') " &
"                        AT time zone 'America/Sao_Paulo') AS DATE) ) QWMS " &
"        ON QWMS.NF = TDREC940.T$DOCN$L || '/' || TDREC940.T$SERI$L " &
"       AND QWMS.SUPPLIERCODE  = TDREC940.T$BPID$L " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD001301@PLN01 TCIBD001     " &
"        ON TCIBD001.T$ITEM = TDREC941.T$ITEM      " &
"                                                  " &
"INNER JOIN BAANDB.TTCIBD936301@PLN01 TCIBD936     " &
"        ON TCIBD936.T$IFGC$L = TCIBD001.T$IFGC$L  " &
"                                                  " &
"WHERE TDREC940.T$RFDT$L IN (1,2,5,10,28)          " &
"  AND TRUNC(QWMS.DT_NR) " &
" Between '" + Parameters!DataDe.Value + "'  " &
"  And '" + Parameters!DataAte.Value + "' " &
"   AND CASE WHEN NVL(TDREC940.T$STAT$L, 0) not in (1,3,4,5,6,200,201)  " &
"  THEN 0   " &
"   ELSE TDREC940.T$STAT$L " &
"  END IN (" + JOIN(Parameters!Situacao.Value, ", ") + ")   " &
" 		 " &
"ORDER BY 3,5,6 "

)