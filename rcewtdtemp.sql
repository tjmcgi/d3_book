SELECT entity, commodityid, s.iso, s.loadzone, datatype, CAST(w.flowdate AS TIMESTAMP) flowdate, (max(tmp) / 2.0 + min(tmp) / 2.0) avg_tmp, actload, (max(tmp) / 2.0 + min(tmp) / 2.0) * actload tmp_load, CASE WHEN (max(tmp) / 2.0 + min(tmp) / 2.0) > 65 THEN (max(tmp) / 2.0 + min(tmp) / 2.0) - 65 ELSE 0 END * actload cdd_load, CASE WHEN (max(tmp) / 2.0 + min(tmp) / 2.0) < 65 THEN 65 - (max(tmp) / 2.0 + min(tmp) / 2.0) ELSE 0 END * actload hdd_load, min(tmp) * actload mintmp_load FROM (SELECT w.* FROM curves.weather w INNER JOIN (SELECT stationcode, flowdate, hour, max(asofdate) md FROM curves.weather GROUP BY stationcode, flowdate, hour) mw ON w.stationcode = mw.stationcode AND w.flowdate = mw.flowdate AND w.hour = mw.hour AND w.asofdate = mw.md) w INNER JOIN curves.stationmap s ON w.stationcode = s.stationcode INNER JOIN (SELECT entity, commodityid, iso, loadzone, sum(annualvolume / contractcount) actload FROM profiles.vw_currentcustlist GROUP BY iso, loadzone, entity, commodityid) pnl ON s.iso = pnl.iso AND s.loadzone = pnl.loadzone GROUP BY s.iso, s.loadzone, datatype, actload, CAST(w.flowdate AS TIMESTAMP), entity, commodityid