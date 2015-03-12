SELECT Q1.TP_TRANSACAO            TP_TRANSACAO
     , Q1.DATA                    DATA
     , Q1.ID_UNEG                 ID_UNEG
     , Q1.NOME_UNEG               NOME_UNEG
     , Q1.COD_VENDEDOR            COD_VENDEDOR
     , Q1.NOM_VENDEDOR            NOM_VENDEDOR        --INCLUIR
     , Q1.PEDIDO                  PEDIDO
     , Q1.ENTREGA                 ENTREGA
     , Q1.CODE_ATIVACAO           CODE_ATIVACAO
     , Q1.ID_CLIENTE              ID_CLIENTE
     , Q1.NOME_CLIENTE            NOME_CLIENTE
     , Q1.EMAIL_CLIENTE           EMAIL_CLIENTE
     , Q1.TELEFONE_CLIENTE        TELEFONE_CLIENTE
     , Q1.CEP_CLIENTE             CEP_CLIENTE
     , Q1.ENDERECO_CLIENTE        ENDERECO_CLIENTE
     , Q1.COMPLEMENTO             COMPLEMENTO
     , Q1.MUNICIPIO               MUNICIPIO
     , Q1.ESTADO                  ESTADO
     , Q1.BAIRRO                  BAIRRO
     , Q1.ITEM                    ITEM
     , Q1.DESCR_ITEM              DESCR_ITEM
     , SUM(Q1.VALOR_VENDA)        VALOR_VENDA
     , SUM(Q1.CUSTO_UNI *         
       ABS(Q1.QUANT))             CUSTO
     , SUM(Q1.VALOR_VENDA) -      
       SUM(Q1.CUSTO_UNI *         
       ABS(Q1.QUANT))             VL_REPASSE  
     , Q1.ID_CANAL                ID_CANAL
     , Q1.DESCR_CANAL             DESCR_CANAL
	 
FROM ( SELECT CASE WHEN ZNCOM005.T$CANC$C = 1
                     THEN 'CANCELAMENTO'
                   ELSE 'VENDA' 
               END                   TP_TRANSACAO
            , ZNCOM005.T$DATE$C      DATA
            , ZNCOM005.T$UNEG$C      ID_UNEG
            , ZNINT002.T$DESC$C      NOME_UNEG
            , ZNSLS400.T$CVEN$C      COD_VENDEDOR -- OBS: NÃO TEMOS O NOME NO LN TEMOS SOMENTE O CÓDIGO QUE VEM DO FRONT
            , ZNCOM005.T$PECL$C      PEDIDO
            , ZNCOM005.T$ENTR$C      ENTREGA
            , ZNCOM005.T$CDAS$C      CODE_ATIVACAO
            , ZNSLS400.T$ICLF$C      ID_CLIENTE
            , ZNSLS400.T$NOMF$C      NOME_CLIENTE
            , ZNSLS400.T$EMAF$C      EMAIL_CLIENTE
            , ZNSLS400.T$TELF$C      TELEFONE_CLIENTE
            , ZNSLS400.T$CEPF$C      CEP_CLIENTE
            , ZNSLS400.T$LOGF$C      ENDERECO_CLIENTE
            , ZNSLS400.T$COMF$C      COMPLEMENTO
            , ZNSLS400.T$CIDF$C      MUNICIPIO
            , ZNSLS400.T$UFFA$C      ESTADO
            , ZNSLS400.T$BAIF$C      BAIRRO
            , ZNCOM005.T$ITEM$C      ITEM
            , TCIBD001.T$DSCA        DESCR_ITEM
            , ZNCOM005.T$AMTI$C *
              ABS(ZNCOM005.T$QUAN$C) VALOR_VENDA
			
            , ( SELECT SUM(A.T$AVAT$1) KEEP (DENSE_RANK LAST ORDER BY  A.T$INDT, A.T$SEQN) 
                                     VALOR
                  FROM BAANDB.TTICPR305301 A 
                 WHERE A.T$ITEM = ZNCOM005.T$ITEM$C
                   AND A.T$INDT <= ZNCOM005.T$DATE$C )
                                     CUSTO_UNI
									 
            , ZNCOM005.T$QUAN$C      QUANT 
            , ZNSLS400.T$IDCA$C      ID_CANAL
            , TCMCS045.T$DSCA        DESCR_CANAL
  
         FROM BAANDB.TZNCOM005301 ZNCOM005

   INNER JOIN BAANDB.TZNSLS400301 ZNSLS400 
           ON ZNSLS400.T$NCIA$C = ZNCOM005.T$NCIA$C
          AND ZNSLS400.T$UNEG$C = ZNCOM005.T$UNEG$C
          AND ZNSLS400.T$PECL$C = ZNCOM005.T$PECL$C
          AND ZNSLS400.T$SQPD$C = ZNCOM005.T$SQPD$C
   	   
   INNER JOIN BAANDB.TZNINT002301 ZNINT002 
           ON ZNINT002.T$NCIA$C = ZNCOM005.T$NCIA$C
          AND ZNINT002.T$UNEG$C = ZNCOM005.T$UNEG$C
   	   
   INNER JOIN BAANDB.TTCIBD001301 TCIBD001 
           ON TCIBD001.T$ITEM = ZNCOM005.T$ITEM$C
       
    LEFT JOIN BAANDB.TTCMCS045301 TCMCS045 
           ON TCMCS045.T$CREG = ZNSLS400.T$IDCA$C ) Q1
		
GROUP BY Q1.TP_TRANSACAO
       , Q1.DATA
       , Q1.ID_UNEG
       , Q1.NOME_UNEG
       , Q1.COD_VENDEDOR
       , Q1.PEDIDO
       , Q1.ENTREGA
       , Q1.CODE_ATIVACAO
       , Q1.ID_CLIENTE
       , Q1.NOME_CLIENTE
       , Q1.EMAIL_CLIENTE
       , Q1.TELEFONE_CLIENTE
       , Q1.CEP_CLIENTE
       , Q1.ENDERECO_CLIENTE
       , Q1.COMPLEMENTO
       , Q1.MUNICIPIO
       , Q1.ESTADO
       , Q1.BAIRRO
       , Q1.ITEM
       , Q1.DESCR_ITEM  
       , Q1.ID_CANAL
       , Q1.DESCR_CANAL
