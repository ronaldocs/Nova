SELECT d.t$cnst CD_GENERO,
       l.t$desc DS_GENERO
FROM baandb.tttadv401000 d,
     baandb.tttadv140000 l
WHERE d.t$cpac='tc'
AND d.t$cdom='kitm'
AND d.t$vers='B61'
AND d.t$rele='a'
AND d.t$cust=' '
AND l.t$clab=d.t$za_clab
AND l.t$clan='p'
AND l.t$cpac='tc'
AND l.t$vers='B61'
AND l.t$rele='a'
AND l.t$cust=' '
order by 1