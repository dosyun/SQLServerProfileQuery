DBCC FREESYSTEMCACHE('SQL Plans')
GO

SELECT
	qs.execution_count,
	qs.total_rows,
	qs.last_rows,
	qs.min_rows,
	qs.max_rows,
	qs.last_elapsed_time,
	qs.min_elapsed_time,
	qs.max_elapsed_time,
	total_worker_time,
	total_logical_reads,
	qs.total_elapsed_time / qs.execution_count AS [avg_elapsed_time], 
	qs.total_worker_time  / qs.execution_count AS [avg_worker_time], 
	SUBSTRING(qt.TEXT,qs.statement_start_offset/2 +1,
	(CASE WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.TEXT)) * 2 ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) AS query_text,
	qs.plan_handle,
	qp.query_plan
FROM sys.dm_exec_query_stats                       AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle)    AS qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE CAST(qp.query_plan as nvarchar(max)) LIKE '%Index Scan%'
ORDER BY qs.total_worker_time DESC OPTION (RECOMPILE);
