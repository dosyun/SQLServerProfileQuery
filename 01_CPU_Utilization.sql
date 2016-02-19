--DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);

--CPUとI/Oの比率----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	[%signal (cpu) waits]が20%を超えないことをチェック
--	sys.dm_os_wait_stats		実行されたスレッドにより検出されたすべての待機に関する情報を返します。
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
    CAST(100.0 * SUM(signal_wait_time_ms)                / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [%signal (cpu) waits],	--CPU起因となる待ちの割合(20%を超えないこと)
    CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [%resource waits]		--CPU以外で発生した待ちの割合
FROM sys.dm_os_wait_stats WITH (NOLOCK) OPTION (RECOMPILE);	

--各Database の CPU, 実行時間比率------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	[%CPU]が50%を超えないことをチェック
--	sys.dm_exec_query_stats		キャッシュされたクエリ プランの集計パフォーマンス統計を返します。プランがキャッシュから削除されると、対応する行もこのビューから削除されます。
--	sys.dm_exec_plan_attributes	プランハンドルで指定したプランのプラン属性ごとに1行のデータを返します。 キャッシュキーの値やプランの同時実行数など、特定プランに関する詳細を取得できます。
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH DB_CPU_Stats AS (
    SELECT
	    DatabaseID,
		DB_Name(DatabaseID)                                                                   AS [DatabaseName],
		SUM(total_worker_time)  / 1000.                                                       AS [CPU_Time (ms)],		--コンパイル後にプランの実行で使用された CPU 時間の合計(全体時間のうちCPUを使用した時間)
        SUM(total_elapsed_time) / 1000.                                                       AS [Elapsed_Time (ms)],	--このプランの実行完了までの経過時間の合計(全体時間)
		(100. * (SUM(total_elapsed_time) - SUM(total_worker_time)) / SUM(total_elapsed_time)) AS [CPU Ratio]
    FROM sys.dm_exec_query_stats AS qs
    CROSS APPLY (
	    SELECT CONVERT(int, value) AS [DatabaseID]
		FROM sys.dm_exec_plan_attributes(qs.plan_handle) WHERE attribute = N'dbid'
    ) AS F_DB
	GROUP BY DatabaseID
)
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time (ms)] DESC)                                 AS [row_num],
       DatabaseName                                                                     AS [DatabaseName],
	   [CPU_Time (ms)]                                                                  AS [CPU_Time (ms)],
	   [Elapsed_Time (ms)]                                                              AS [ELapsed_Time (ms)],
	   [CPU Ratio]                                                                      AS [CPU Ratio],
       CAST([CPU_Time (ms)]     * 1.0 / SUM([CPU_Time (ms)])     OVER() * 100.0 AS DECIMAL(5, 2)) AS [%CPU],	--50%を超えないこと
       CAST([Elapsed_Time (ms)] * 1.0 / SUM([Elapsed_Time (ms)]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [%Elapsed]
FROM DB_CPU_Stats
WHERE DatabaseID > 4      -- system databases
  AND DatabaseID <> 32767 -- ResourceDB
ORDER BY row_num OPTION (RECOMPILE);

--オマケ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
WITH Waits AS (
    SELECT
	    wait_type, wait_time_ms / 1000.						AS wait_time_s,
        100. * wait_time_ms / SUM(wait_time_ms) OVER()		AS pct,
        ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC)		AS rn
    FROM sys.dm_os_wait_stats WITH (NOLOCK)
    WHERE wait_type NOT IN (N'CLR_SEMAPHORE',N'LAZYWRITER_SLEEP',N'RESOURCE_QUEUE',N'SLEEP_TASK',
                            N'SLEEP_SYSTEMTASK',N'SQLTRACE_BUFFER_FLUSH',N'WAITFOR', N'LOGMGR_QUEUE',N'CHECKPOINT_QUEUE',
                            N'REQUEST_FOR_DEADLOCK_SEARCH',N'XE_TIMER_EVENT',N'BROKER_TO_FLUSH',N'BROKER_TASK_STOP',N'CLR_MANUAL_EVENT',
                            N'CLR_AUTO_EVENT',N'DISPATCHER_QUEUE_SEMAPHORE', N'FT_IFTS_SCHEDULER_IDLE_WAIT',
                            N'XE_DISPATCHER_WAIT', N'XE_DISPATCHER_JOIN', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
                            N'ONDEMAND_TASK_QUEUE', N'BROKER_EVENTHANDLER', N'SLEEP_BPOOL_FLUSH')
)
SELECT
    W1.wait_type, 
    CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s,
    CAST(W1.pct         AS DECIMAL(12, 2)) AS pct,
    CAST(SUM(W2.pct)    AS DECIMAL(12, 2)) AS running_pct
FROM       Waits AS W1
INNER JOIN Waits AS W2
   ON W2.rn <= W1.rn
GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
HAVING SUM(W2.pct) - W1.pct < 99 OPTION (RECOMPILE); -- percentage threshold
*/
