select Q1.*
  from ( SELECT ZNFMD630.T$CFRW$C     ID_TRANSPORTADOR,
                TCMCS080.T$DSCA       DESCR_TRANSPORTADOR,
                ZNFMD630.T$CFRW$C ||
                ' - '             ||
                Trim(TCMCS080.T$DSCA) TRANSPORTADOR,
                ZNFMD630.T$DOCN$C     NOTA,
                ZNFMD630.T$SERI$C     SERIE,
                CISLI940.T$FDTC$L     ID_TIPO_NOTA,
                TCMCS966.T$DSCA$L     DESCR_TIPO_NOTA,
                ZNSLS401.T$UNEG$C     ID_UNEG,
                ZNINT002.T$DESC$C     DESCR_UNEG,
                ZNFMD640.T$COCI$C     OCORRENCIA,
                ZNFMD030.T$DSCI$C     DESCR_OCORRENCIA,
         
                CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(ZNFMD640.T$DATE$C, 
                  'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
                    AT time zone 'America/Sao_Paulo') AS DATE) 
                                      DT_OCORRENCIA,
         
                ZNSLS401.T$CEPE$C     CEP,
                ZNSLS401.T$UFEN$C     UF,
         
                CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(ZNSLS401.T$DTEP$C, 
                  'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
                    AT time zone 'America/Sao_Paulo') AS DATE) 
                                      DT_PROMETIDA,
         
                CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(ZNFMD630.T$DATE$C, 
                  'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
                    AT time zone 'America/Sao_Paulo') AS DATE) 
                                      DT_EXPEDICAO,
         
                CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(ZNSLS410.T$DTEN$C, 
                  'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
                    AT time zone 'America/Sao_Paulo') AS DATE) 
                                      DT_PERVISTA,
         
                CASE WHEN Trunc(CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(ZNSLS410.T$DTEC$C, 
                                  'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
                                    AT time zone 'America/Sao_Paulo') AS DATE)) > TO_DATE('01-01-1990', 'DD-MM-YYYY')
                       THEN CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(ZNSLS410.T$DTEC$C, 
                              'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
                                AT time zone 'America/Sao_Paulo') AS DATE) 
                     ELSE   CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(ZNSLS401.T$DTEP$C, 
         			         'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
         			           AT time zone 'America/Sao_Paulo') AS DATE) 
                 END                  DT_CORRIGIDA,
                
                ZNSLS401.T$ITPE$C     ID_TIPO_ENTREGA,
                ZNSLS002.T$DSCA$C     DESCR_TIPO_ENTREGA,
                
                CASE WHEN ZNSLS401.T$ITPE$C = 5
                       THEN ZNSLS401.T$DTEP$C
                     ELSE   NULL 
                 END                  DT_AGENDAMENTO,
                CASE WHEN ZNINT002.T$WSTP$C = 'B2B'
                       THEN 'B2C'
                     ELSE   'B2C' 
                 END                  TIPO_VENDA
         
         FROM       BAANDB.TZNFMD630301 ZNFMD630
         
         INNER JOIN BAANDB.TTCMCS080301 TCMCS080  
                 ON TCMCS080.T$CFRW  = ZNFMD630.T$CFRW$C
           
         INNER JOIN BAANDB.TCISLI940301 CISLI940  
                 ON CISLI940.T$FIRE$L = ZNFMD630.T$FIRE$C
         
         INNER JOIN BAANDB.TTCMCS966301 TCMCS966  
                 ON TCMCS966.T$FDTC$L = CISLI940.T$FDTC$L
         
         INNER JOIN ( select B.T$NCIA$C,
                             B.T$UNEG$C,
                             B.T$PECL$C,
                             B.T$SQPD$C,
                             B.T$ENTR$C,
                             B.T$ORNO$C
                        from BAANDB.TZNSLS004301 B
                    group by B.T$NCIA$C,
                             B.T$UNEG$C,
                             B.T$PECL$C,
                             B.T$SQPD$C,
                             B.T$ENTR$C,
                             B.T$ORNO$C ) ZNSLS004  
                 ON ZNSLS004.T$ORNO$C = ZNFMD630.T$ORNO$C
         
         INNER JOIN ( select C.T$NCIA$C,
                             C.T$UNEG$C,
                             C.T$PECL$C,
                             C.T$SQPD$C,
                             C.T$ENTR$C,
                             C.T$CEPE$C,
                             C.T$UFEN$C,
                             C.T$DTEP$C,
                             T$ITPE$C
                        from BAANDB.TZNSLS401301 C
                       where C.T$QTVE$C > 0
                    group by C.T$NCIA$C,
                             C.T$UNEG$C,
                             C.T$PECL$C,
                             C.T$SQPD$C,
                             C.T$ENTR$C,
                             C.T$CEPE$C,
                             C.T$UFEN$C,
                             C.T$DTEP$C,
                             C.T$ITPE$C ) ZNSLS401  
                 ON ZNSLS401.T$NCIA$C = ZNSLS004.T$NCIA$C
                AND ZNSLS401.T$UNEG$C = ZNSLS004.T$UNEG$C
                AND ZNSLS401.T$PECL$C = ZNSLS004.T$PECL$C
                AND ZNSLS401.T$SQPD$C = ZNSLS004.T$SQPD$C
                AND ZNSLS401.T$ENTR$C = ZNSLS004.T$ENTR$C
                     
         INNER JOIN ( select C.T$NCIA$C,
                             C.T$UNEG$C,
                             C.T$PECL$C,
                             C.T$SQPD$C,
                             C.T$ENTR$C,
                             MAX(C.T$DTEN$C) T$DTEN$C,
                             MAX(C.T$DTEC$C) T$DTEC$C
                        from BAANDB.TZNSLS410301 C
                    group by C.T$NCIA$C,
                             C.T$UNEG$C,
                             C.T$PECL$C,
                             C.T$SQPD$C,
                             C.T$ENTR$C ) ZNSLS410
                 ON ZNSLS410.T$NCIA$C = ZNSLS004.T$NCIA$C
                AND ZNSLS410.T$UNEG$C = ZNSLS004.T$UNEG$C
                AND ZNSLS410.T$PECL$C = ZNSLS004.T$PECL$C
                AND ZNSLS410.T$SQPD$C = ZNSLS004.T$SQPD$C
                AND ZNSLS410.T$ENTR$C = ZNSLS004.T$ENTR$C
         
         INNER JOIN ( select D.T$FILI$C,
                             D.T$ETIQ$C,
                             D.T$COCI$C,
                             D.T$DATE$C,
                             ROW_NUMBER() OVER (PARTITION BY D.T$FILI$C, D.T$ETIQ$C ORDER BY D.T$DATE$C DESC, D.T$UDAT$C DESC)  RN
                        from BAANDB.TZNFMD640301 D ) ZNFMD640 
                 ON ZNFMD640.T$FILI$C = ZNFMD630.T$FILI$C
                AND ZNFMD640.T$ETIQ$C = ZNFMD630.T$ETIQ$C
         
         INNER JOIN BAANDB.TZNINT002301 ZNINT002  
                 ON ZNINT002.T$NCIA$C = ZNSLS401.T$NCIA$C
                AND ZNINT002.T$UNEG$C = ZNSLS401.T$UNEG$C
             
         INNER JOIN BAANDB.TZNFMD030301 ZNFMD030  
                 ON ZNFMD030.T$OCIN$C = ZNFMD640.T$COCI$C
           
         INNER JOIN BAANDB.TZNSLS002301 ZNSLS002  
                 ON ZNSLS002.T$TPEN$C = ZNSLS401.T$ITPE$C            
            
         WHERE ZNFMD640.RN = 1
           AND ( select COUNT(*)
                   from BAANDB.TZNFMD640301 D
                  where D.T$FILI$C = ZNFMD630.T$FILI$C
                    and D.T$ETIQ$C = ZNFMD630.T$ETIQ$C
                    and D.T$COCI$C IN ('ENT', 'EXT', 'ROU', 'AVA', 'DEV', 'EXF', 'RIE', 'RTD') ) = 0 ) Q1
					
where Trunc(Q1.DT_CORRIGIDA)
      Between :DataCorrigidaDe
          And :DataCorrigidaAte

order by Q1.NOTA,
         Q1.DT_OCORRENCIA