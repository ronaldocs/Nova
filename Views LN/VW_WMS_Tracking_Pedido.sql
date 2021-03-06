﻿--	FAF.004 - 13-mai-2014, Fabio Ferreira, 	Correção timezone
--	FAF.000 - 18-jun-2014, Fabio Ferreira,	Inclusão de campos que estavam pedentes de definição	
--	04/05/2015 - Correção Timezone e CD_GAIOLA -Rosana							
--*******************************************************************************************************************************************
SELECT
      OD.ORDERKEY NR_PEDIDO_WMS, 
      O.WHSEID CD_ARMAZEM,
      SUM(O.TOTALQTY) NR_VOLUME,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE1.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.STATUS>=51) DT_INICIO_PICKING,
      SUM(OD.QTYPICKED) NR_VOLUME_FINALIZADOS,
      SUM(OD.SHIPPEDQTY) NR_VOLUME_CONFERIDOS,
      (SELECT OSH.STATUS FROM WMWHSE1.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE1.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
       AND ROWNUM=1) CD_ULTIMA_OCORRENCIA,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MAX(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE1.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY) DT_ULT_ATUALIZACAO,
          O.EXTERNORDERKEY CD_EXTERNO_ORDER_KEY,
          O.CARRIERCODE CD_TRANSPORTADORA,
      (SELECT OSH.SERIALKEY FROM WMWHSE1.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE1.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
          AND ROWNUM=1) CD_ULTIMO_TRACKING,
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cd.ADDDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE1.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1) DT_INCLUSAO_VL_CARGA,
      CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(O.ACTUALSHIPDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) DT_SAIDA_CAMINHAO, 
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cg.CLOSEDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE1.CAGEID cg, WMWHSE1.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1 and cg.cageid=cd.CAGEID) DT_FECHA_GAIOLA,
      TO_CHAR(cd.cageid) ID_GAIOLA
FROM
      WMWHSE1.ORDERDETAIL OD
      left join WMWHSE1.CAGEIDDETAIL cd
      on cd.ORDERID=OD.ORDERKEY,
      WMWHSE1.ORDERS O
WHERE O.ORDERKEY=OD.ORDERKEY
GROUP BY OD.ORDERKEY, O.EXTERNORDERKEY, O.CARRIERCODE, O.WHSEID, O.ACTUALSHIPDATE, cd.cageid
UNION
SELECT
      OD.ORDERKEY NR_PEDIDO_WMS, 
      O.WHSEID CD_ARMAZEM,
      SUM(O.TOTALQTY) NR_VOLUME,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE2.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.STATUS>=51) DT_INICIO_PICKING,
      SUM(OD.QTYPICKED) NR_VOLUME_FINALIZADOS,
      SUM(OD.SHIPPEDQTY) NR_VOLUME_CONFERIDOS,
      (SELECT OSH.STATUS FROM WMWHSE2.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE2.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
       AND ROWNUM=1) CD_ULTIMA_OCORRENCIA,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE2.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY) DT_ULT_ATUALIZACAO,
          O.EXTERNORDERKEY CD_EXTERNO_ORDER_KEY,
          O.CARRIERCODE CD_TRANSPORTADORA,
      (SELECT OSH.SERIALKEY FROM WMWHSE2.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE2.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
          AND ROWNUM=1) CD_ULTIMO_TRACKING,
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cd.ADDDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE2.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1) DT_INCLUSAO_VL_CARGA,
      CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(O.ACTUALSHIPDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) DT_SAIDA_CAMINHAO, 
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cg.CLOSEDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE2.CAGEID cg, WMWHSE2.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1 and cg.cageid=cd.CAGEID) DT_FECHA_GAIOLA,
      TO_CHAR(cd.cageid) ID_GAIOLA
FROM
      WMWHSE2.ORDERDETAIL OD
      left join WMWHSE2.CAGEIDDETAIL cd
      on cd.ORDERID=OD.ORDERKEY,
      WMWHSE2.ORDERS O
WHERE O.ORDERKEY=OD.ORDERKEY
GROUP BY OD.ORDERKEY, O.EXTERNORDERKEY, O.CARRIERCODE, O.WHSEID, O.ACTUALSHIPDATE, cd.cageid
UNION
SELECT
      OD.ORDERKEY NR_PEDIDO_WMS, 
      O.WHSEID CD_ARMAZEM,
      SUM(O.TOTALQTY) NR_VOLUME,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE3.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.STATUS>=51) DT_INICIO_PICKING,
      SUM(OD.QTYPICKED) NR_VOLUME_FINALIZADOS,
      SUM(OD.SHIPPEDQTY) NR_VOLUME_CONFERIDOS,
      (SELECT OSH.STATUS FROM WMWHSE3.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE3.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
       AND ROWNUM=1) CD_ULTIMA_OCORRENCIA,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE3.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY) DT_ULT_ATUALIZACAO,
          O.EXTERNORDERKEY CD_EXTERNO_ORDER_KEY,
          O.CARRIERCODE CD_TRANSPORTADORA,
      (SELECT OSH.SERIALKEY FROM WMWHSE3.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE3.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
          AND ROWNUM=1) CD_ULTIMO_TRACKING,
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cd.ADDDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE3.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1) DT_INCLUSAO_VL_CARGA,
      CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(O.ACTUALSHIPDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) DT_SAIDA_CAMINHAO, 
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cg.CLOSEDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE3.CAGEID cg, WMWHSE3.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1 and cg.cageid=cd.CAGEID) DT_FECHA_GAIOLA,
      TO_CHAR(cd.cageid) ID_GAIOLA
FROM
      WMWHSE3.ORDERDETAIL OD
      left join WMWHSE3.CAGEIDDETAIL cd
      on cd.ORDERID=OD.ORDERKEY,
      WMWHSE3.ORDERS O
WHERE O.ORDERKEY=OD.ORDERKEY
GROUP BY OD.ORDERKEY, O.EXTERNORDERKEY, O.CARRIERCODE, O.WHSEID, O.ACTUALSHIPDATE, cd.cageid
UNION
SELECT
      OD.ORDERKEY NR_PEDIDO_WMS, 
      O.WHSEID CD_ARMAZEM,
      SUM(O.TOTALQTY) NR_VOLUME,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE4.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.STATUS>=51) DT_INICIO_PICKING,
      SUM(OD.QTYPICKED) NR_VOLUME_FINALIZADOS,
      SUM(OD.SHIPPEDQTY) NR_VOLUME_CONFERIDOS,
      (SELECT OSH.STATUS FROM WMWHSE4.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE4.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
       AND ROWNUM=1) CD_ULTIMA_OCORRENCIA,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE4.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY) DT_ULT_ATUALIZACAO,
          O.EXTERNORDERKEY CD_EXTERNO_ORDER_KEY,
          O.CARRIERCODE CD_TRANSPORTADORA,
      (SELECT OSH.SERIALKEY FROM WMWHSE4.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE4.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
          AND ROWNUM=1) CD_ULTIMO_TRACKING,
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cd.ADDDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE4.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1) DT_INCLUSAO_VL_CARGA,
      CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(O.ACTUALSHIPDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) DT_SAIDA_CAMINHAO, 
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cg.CLOSEDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE4.CAGEID cg, WMWHSE4.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1 and cg.cageid=cd.CAGEID) DT_FECHA_GAIOLA,
      TO_CHAR(cd.cageid) ID_GAIOLA
FROM
      WMWHSE4.ORDERDETAIL OD
      left join WMWHSE4.CAGEIDDETAIL cd
      on cd.ORDERID=OD.ORDERKEY,
      WMWHSE4.ORDERS O
WHERE O.ORDERKEY=OD.ORDERKEY
GROUP BY OD.ORDERKEY, O.EXTERNORDERKEY, O.CARRIERCODE, O.WHSEID, O.ACTUALSHIPDATE, cd.cageid
UNION
SELECT
      OD.ORDERKEY NR_PEDIDO_WMS, 
      O.WHSEID CD_ARMAZEM,
      SUM(O.TOTALQTY) NR_VOLUME,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE5.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.STATUS>=51) DT_INICIO_PICKING,
      SUM(OD.QTYPICKED) NR_VOLUME_FINALIZADOS,
      SUM(OD.SHIPPEDQTY) NR_VOLUME_CONFERIDOS,
      (SELECT OSH.STATUS FROM WMWHSE5.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE5.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
       AND ROWNUM=1) CD_ULTIMA_OCORRENCIA,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE5.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY) DT_ULT_ATUALIZACAO,
          O.EXTERNORDERKEY CD_EXTERNO_ORDER_KEY,
          O.CARRIERCODE CD_TRANSPORTADORA,
      (SELECT OSH.SERIALKEY FROM WMWHSE5.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE5.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
          AND ROWNUM=1) CD_ULTIMO_TRACKING,
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cd.ADDDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE5.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1) DT_INCLUSAO_VL_CARGA,
      CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(O.ACTUALSHIPDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) DT_SAIDA_CAMINHAO, 
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cg.CLOSEDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE5.CAGEID cg, WMWHSE5.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1 and cg.cageid=cd.CAGEID) DT_FECHA_GAIOLA,
      TO_CHAR(cd.cageid) ID_GAIOLA
FROM
      WMWHSE5.ORDERDETAIL OD
      left join WMWHSE5.CAGEIDDETAIL cd
      on cd.ORDERID=OD.ORDERKEY,
      WMWHSE5.ORDERS O
WHERE O.ORDERKEY=OD.ORDERKEY
GROUP BY OD.ORDERKEY, O.EXTERNORDERKEY, O.CARRIERCODE, O.WHSEID, O.ACTUALSHIPDATE, cd.cageid
UNION
SELECT
      OD.ORDERKEY NR_PEDIDO_WMS, 
      O.WHSEID CD_ARMAZEM,
      SUM(O.TOTALQTY) NR_VOLUME,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE6.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.STATUS>=51) DT_INICIO_PICKING,
      SUM(OD.QTYPICKED) NR_VOLUME_FINALIZADOS,
      SUM(OD.SHIPPEDQTY) NR_VOLUME_CONFERIDOS,
      (SELECT OSH.STATUS FROM WMWHSE6.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE6.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
       AND ROWNUM=1) CD_ULTIMA_OCORRENCIA,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE6.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY) DT_ULT_ATUALIZACAO,
          O.EXTERNORDERKEY CD_EXTERNO_ORDER_KEY,
          O.CARRIERCODE CD_TRANSPORTADORA,
      (SELECT OSH.SERIALKEY FROM WMWHSE6.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE6.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
          AND ROWNUM=1) CD_ULTIMO_TRACKING,
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cd.ADDDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE6.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1) DT_INCLUSAO_VL_CARGA,
      CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(O.ACTUALSHIPDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) DT_SAIDA_CAMINHAO, 
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cg.CLOSEDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE6.CAGEID cg, WMWHSE6.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1 and cg.cageid=cd.CAGEID) DT_FECHA_GAIOLA,
      TO_CHAR(cd.cageid) ID_GAIOLA
FROM
      WMWHSE6.ORDERDETAIL OD
      left join WMWHSE6.CAGEIDDETAIL cd
      on cd.ORDERID=OD.ORDERKEY,
      WMWHSE6.ORDERS O
WHERE O.ORDERKEY=OD.ORDERKEY
GROUP BY OD.ORDERKEY, O.EXTERNORDERKEY, O.CARRIERCODE, O.WHSEID, O.ACTUALSHIPDATE, cd.cageid
UNION
SELECT
      OD.ORDERKEY NR_PEDIDO_WMS, 
      O.WHSEID CD_ARMAZEM,
      SUM(O.TOTALQTY) NR_VOLUME,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE7.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.STATUS>=51) DT_INICIO_PICKING,
      SUM(OD.QTYPICKED) NR_VOLUME_FINALIZADOS,
      SUM(OD.SHIPPEDQTY) NR_VOLUME_CONFERIDOS,
      (SELECT OSH.STATUS FROM WMWHSE7.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE7.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
       AND ROWNUM=1) CD_ULTIMA_OCORRENCIA,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE7.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY) DT_ULT_ATUALIZACAO,
          O.EXTERNORDERKEY CD_EXTERNO_ORDER_KEY,
          O.CARRIERCODE CD_TRANSPORTADORA,
      (SELECT OSH.SERIALKEY FROM WMWHSE7.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE7.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
          AND ROWNUM=1) CD_ULTIMO_TRACKING,
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cd.ADDDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE7.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1) DT_INCLUSAO_VL_CARGA,
      CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(O.ACTUALSHIPDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) DT_SAIDA_CAMINHAO, 
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cg.CLOSEDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE7.CAGEID cg, WMWHSE7.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1 and cg.cageid=cd.CAGEID) DT_FECHA_GAIOLA,
      TO_CHAR(cd.cageid) ID_GAIOLA
FROM
      WMWHSE7.ORDERDETAIL OD
      left join WMWHSE7.CAGEIDDETAIL cd
      on cd.ORDERID=OD.ORDERKEY,
      WMWHSE7.ORDERS O
WHERE O.ORDERKEY=OD.ORDERKEY
GROUP BY OD.ORDERKEY, O.EXTERNORDERKEY, O.CARRIERCODE, O.WHSEID, O.ACTUALSHIPDATE, cd.cageid
UNION
SELECT
      OD.ORDERKEY NR_PEDIDO_WMS, 
      O.WHSEID CD_ARMAZEM,
      SUM(O.TOTALQTY) NR_VOLUME,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE8.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.STATUS>=51) DT_INICIO_PICKING,
      SUM(OD.QTYPICKED) NR_VOLUME_FINALIZADOS,
      SUM(OD.SHIPPEDQTY) NR_VOLUME_CONFERIDOS,
      (SELECT OSH.STATUS FROM WMWHSE8.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE8.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
       AND ROWNUM=1) CD_ULTIMA_OCORRENCIA,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE8.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY) DT_ULT_ATUALIZACAO,
          O.EXTERNORDERKEY CD_EXTERNO_ORDER_KEY,
          O.CARRIERCODE CD_TRANSPORTADORA,
      (SELECT OSH.SERIALKEY FROM WMWHSE8.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE8.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
          AND ROWNUM=1) CD_ULTIMO_TRACKING,
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cd.ADDDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE8.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1) DT_INCLUSAO_VL_CARGA,
      CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(O.ACTUALSHIPDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) DT_SAIDA_CAMINHAO, 
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cg.CLOSEDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE8.CAGEID cg, WMWHSE8.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1 and cg.cageid=cd.CAGEID) DT_FECHA_GAIOLA,
      TO_CHAR(cd.cageid) ID_GAIOLA
FROM
      WMWHSE8.ORDERDETAIL OD
      left join WMWHSE8.CAGEIDDETAIL cd
      on cd.ORDERID=OD.ORDERKEY,
      WMWHSE8.ORDERS O
WHERE O.ORDERKEY=OD.ORDERKEY
GROUP BY OD.ORDERKEY, O.EXTERNORDERKEY, O.CARRIERCODE, O.WHSEID, O.ACTUALSHIPDATE, cd.cageid
UNION
SELECT
      OD.ORDERKEY NR_PEDIDO_WMS, 
      O.WHSEID CD_ARMAZEM,
      SUM(O.TOTALQTY) NR_VOLUME,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE9.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.STATUS>=51) DT_INICIO_PICKING,
      SUM(OD.QTYPICKED) NR_VOLUME_FINALIZADOS,
      SUM(OD.SHIPPEDQTY) NR_VOLUME_CONFERIDOS,
      (SELECT OSH.STATUS FROM WMWHSE9.ORDERSTATUSHISTORY OSH 
       WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE9.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
       AND ROWNUM=1) CD_ULTIMA_OCORRENCIA,
      (SELECT CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(MIN(OSH.ADDDATE), 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) FROM WMWHSE9.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY) DT_ULT_ATUALIZACAO,
          O.EXTERNORDERKEY CD_EXTERNO_ORDER_KEY,
          O.CARRIERCODE CD_TRANSPORTADORA,
      (SELECT OSH.SERIALKEY FROM WMWHSE9.ORDERSTATUSHISTORY OSH 
          WHERE OSH.ORDERKEY=OD.ORDERKEY AND OSH.ADDDATE=(SELECT MAX(OSH2.ADDDATE) FROM WMWHSE9.ORDERSTATUSHISTORY OSH2 
                                                       WHERE OSH2.ORDERKEY=OSH.ORDERKEY)
          AND ROWNUM=1) CD_ULTIMO_TRACKING,
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cd.ADDDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE9.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1) DT_INCLUSAO_VL_CARGA,
      CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(O.ACTUALSHIPDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) DT_SAIDA_CAMINHAO, 
      (select CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(cg.CLOSEDATE, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT') 
          AT time zone 'America/Sao_Paulo') AS DATE) from WMWHSE9.CAGEID cg, WMWHSE9.CAGEIDDETAIL cd
          where cd.ORDERID=OD.ORDERKEY and ROWNUM=1 and cg.cageid=cd.CAGEID) DT_FECHA_GAIOLA,
      TO_CHAR(cd.cageid) ID_GAIOLA
FROM
      WMWHSE9.ORDERDETAIL OD
      left join WMWHSE9.CAGEIDDETAIL cd
      on cd.ORDERID=OD.ORDERKEY,
      WMWHSE9.ORDERS O
WHERE O.ORDERKEY=OD.ORDERKEY
GROUP BY OD.ORDERKEY, O.EXTERNORDERKEY, O.CARRIERCODE, O.WHSEID, O.ACTUALSHIPDATE, cd.cageid