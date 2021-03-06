Select Distinct

ORDERS.REFERENCEDOCUMENT                    PED_TERC,
ORDERS.ORDERKEY                             ID_PED,
TASKDETAIL.ASSIGNMENTNUMBER                 PROG,
WAVEDETAIL.WAVEKEY                          ONDA,
orderstatussetup.description                EVENTO,
ULTIMO_EVENTO.ADDWHO                        USUARIO,
    subStr( tu.usr_name,4,
            inStr(tu.usr_name, ',')-4 )      NOME,
ULTIMO_EVENTO.ADDDATE                       DT_EVENTO,
STATUSCANCELADO.ADDDATE                     DT_CANC,
ORDERS.WHSEID                               PLANTA,
CODELKUP.UDF2                               DESC_PLANTA

<<<<<<< HEAD
FROM      WMWHSE5.ORDERS

LEFT JOIN WMWHSE5.WAVEDETAIL
=======
FROM      WMWHSE4.ORDERS

LEFT JOIN WMWHSE4.WAVEDETAIL
>>>>>>> parent of cf75d17... Relatório R078
       ON WAVEDETAIL.ORDERKEY=ORDERS.ORDERKEY
       
LEFT JOIN TASKDETAIL
       ON TASKDETAIL.ORDERKEY=ORDERS.ORDERKEY
      AND TASKDETAIL.WAVEKEY=WAVEDETAIL.WAVEKEY
             
 LEFT JOIN ( SELECT a.ORDERKEY, 
                    a.ORDERLINENUMBER , 
                    max(a.STATUS)   STATUS, 
                    max(a.ADDDATE)  ADDDATE, 
                    max(a.ADDWHO)   ADDWHO 
<<<<<<< HEAD
              FROM WMWHSE5.ORDERSTATUSHISTORY a
              WHERE a.ADDDATE = ( select  max(b.adddate) 
                                  from    WMWHSE5.ORDERSTATUSHISTORY b
=======
              FROM WMWHSE4.ORDERSTATUSHISTORY a
              WHERE a.ADDDATE = ( select  max(b.adddate) 
                                  from    WMWHSE4.ORDERSTATUSHISTORY b
>>>>>>> parent of cf75d17... Relatório R078
                                  where   b.ORDERKEY = a.ORDERKEY
                                  and     b.ORDERLINENUMBER = a.ORDERLINENUMBER )
              GROUP BY a.ORDERKEY, 
                       a.ORDERLINENUMBER ) ULTIMO_EVENTO
              ON ULTIMO_EVENTO.ORDERKEY = ORDERS.ORDERKEY 
     
LEFT JOIN ( SELECT MAX(C.ADDDATE)  ADDDATE,
                    C.ORDERKEY
<<<<<<< HEAD
            FROM WMWHSE5.ORDERSTATUSHISTORY C
            WHERE C.STATUS=99
=======
            FROM WMWHSE4.ORDERSTATUSHISTORY C
            WHERE C.STATUS=98
>>>>>>> parent of cf75d17... Relatório R078
            GROUP BY C.ORDERKEY)  STATUSCANCELADO
       ON STATUSCANCELADO.ORDERKEY=ORDERS.ORDERKEY
            
LEFT JOIN ORDERSTATUSSETUP  
       ON ORDERSTATUSSETUP.CODE=ULTIMO_EVENTO.STATUS

LEFT JOIN ( SELECT a.UDF1, a.UDF2
            FROM  CODELKUP a
            WHERE LISTNAME='SCHEMA')  CODELKUP
       ON   UPPER(CODELKUP.UDF1)=UPPER(ORDERS.WHSEID)

<<<<<<< HEAD
LEFT JOIN WMWHSE5.taskmanageruser tu 
=======
LEFT JOIN WMWHSE4.taskmanageruser tu 
>>>>>>> parent of cf75d17... Relatório R078
       ON tu.userkey = ULTIMO_EVENTO.ADDWHO
       
order by ORDERS.ORDERKEY
