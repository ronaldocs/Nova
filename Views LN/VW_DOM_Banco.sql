-- #FAF.064 - 22-mai-2014, Fabio Ferreira, 	Adicionados os c�digos do banco do site
--**********************************************************************************************************************************************************
Select distinct * from																--#FAF.064.n 
(select cast(a.t$baoc$l as varchar(3)) CD_Banco,
        ( select b.t$bnam from  baandb.ttfcmg011201 b
          where b.t$baoc$l=a.t$baoc$l
          and rownum=1) DS_Banco
from baandb.ttfcmg011201 a
UNION select cast(TO_CHAR(c.t$idbc$c) as varchar(3)) Cod_Banco,											--#FAF.064.sn
		(select d.t$desc$c from BAANDB.tzncmg020201 d
		 where d.t$idbc$c=c.t$idbc$c
		 and rownum=1) Ds_Banco
from BAANDB.tzncmg020201 c)
UNION Select '0' CD_Banco,  'N�o Associado' DS_Banco from dual						--#FAF.064.en
order by 1