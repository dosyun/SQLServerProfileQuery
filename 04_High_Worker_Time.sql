--時間がかかりすぎる、CPU 使いすぎるクエリを抽出(条件無し)--------------------------------------------------------------------------------------------------------------------------------------------
--	[max_elapsed_time (ms)]が1000を超えないことをチェック
--	[avg_elapsed_time (ms)]が100を超えないことをチェック
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT TOP (250)
	qs.execution_count									AS [execution_count],			--前回のコンパイル時以降に、プランが実行された回数
	qs.total_rows										AS [total_rows],				--クエリによって返される行の合計数
	qs.last_rows										AS [last_rows],					--クエリの前回の実行で返された行数
	qs.min_rows											AS [min_rows],					--前回のコンパイル時以降に、プランが実行された回数を超える、クエリによって返される行の最小数
	qs.max_rows											AS [max_rows],					--前回のコンパイル時以降に、プランが実行された回数を超える、クエリによって返される行の最大数
	qs.last_elapsed_time / 1000							AS [last_elapsed_time (ms)],	--このプランの前回の実行完了までの経過時間
	qs.min_elapsed_time  / 1000							AS [min_elapsed_time (ms)],		--任意のプランの実行完了までの最小経過時間
	qs.max_elapsed_time  / 1000							AS [max_elapsed_time (ms)],		--任意のプランの実行完了までの最大経過時間(1000を超えないこと!!!!)
	total_worker_time    / 1000							AS [total_worker_time (ms)],	--このプランの実行完了までの経過時間の合計
	total_logical_reads									AS [total_logical_reads],		--コンパイル後にプランの実行で使用された CPU 時間の合計
	(qs.total_elapsed_time / 1000) / qs.execution_count	AS [avg_elapsed_time (ms)],		--平均実行時間(100を超えないこと!!!!)
	(qs.total_worker_time / 1000)  / qs.execution_count	AS [avg_worker_time (ms)], 		--平均CPU使用時間
	SUBSTRING(qt.TEXT,qs.statement_start_offset/2 +1,
		(
			CASE WHEN qs.statement_end_offset = -1
				 THEN LEN(CONVERT(NVARCHAR(MAX), qt.TEXT)) * 2
				 ELSE qs.statement_end_offset
			END - qs.statement_start_offset
		) / 2
	) AS query_text,
	qs.plan_handle 
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
ORDER BY qs.total_worker_time DESC OPTION (RECOMPILE);
