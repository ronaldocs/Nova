--
SELECT d.t$cnst COD_MODALIDADE,
       l.t$desc DESCR
FROM tttadv401000 d,
     tttadv140000 l
WHERE d.t$cpac='tf'
AND d.t$cdom='acp.tpay'
AND d.t$vers='B61U'
AND d.t$rele='a'
AND d.t$cust='stnd'
AND l.t$clab=d.t$za_clab
AND l.t$clan='p'
AND l.t$cpac='tf'
AND l.t$vers=(select max(l1.t$vers) from tttadv140000 l1 where l1.t$clab=l.t$clab AND l1.t$clan=l.t$clan AND l1.t$cpac=l.t$cpac)