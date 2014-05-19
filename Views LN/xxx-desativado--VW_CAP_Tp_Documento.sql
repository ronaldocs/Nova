SELECT d.t$cnst COD_DOCUMENTO,
       l.t$desc DESCR
FROM tttadv401000 d,
     tttadv140000 l
WHERE d.t$cpac='tc'
AND d.t$cdom='doty.l'
AND d.t$vers='B61U'
AND d.t$rele='a7'
AND d.t$cust='glo1'
AND l.t$clab=d.t$za_clab
AND l.t$clan='p'
AND l.t$cpac='tc'
AND l.t$vers='B61U'
AND l.t$rele='a7'
AND l.t$cust='glo1'