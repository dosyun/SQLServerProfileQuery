--DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);

--CPU��I/O�̔䗦----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	[%signal (cpu) waits]��20%�𒴂��Ȃ����Ƃ��`�F�b�N
--	sys.dm_os_wait_stats		���s���ꂽ�X���b�h�ɂ�茟�o���ꂽ���ׂĂ̑ҋ@�Ɋւ������Ԃ��܂��B
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
    CAST(100.0 * SUM(signal_wait_time_ms)                / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [%signal (cpu) waits],	--CPU�N���ƂȂ�҂��̊���(20%�𒴂��Ȃ�����)
    CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [%resource waits]		--CPU�ȊO�Ŕ��������҂��̊���
FROM sys.dm_os_wait_stats WITH (NOLOCK) OPTION (RECOMPILE);	

--�eDatabase �� CPU, ���s���Ԕ䗦------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	[%CPU]��50%�𒴂��Ȃ����Ƃ��`�F�b�N
--	sys.dm_exec_query_stats		�L���b�V�����ꂽ�N�G�� �v�����̏W�v�p�t�H�[�}���X���v��Ԃ��܂��B�v�������L���b�V������폜�����ƁA�Ή�����s�����̃r���[����폜����܂��B
--	sys.dm_exec_plan_attributes	�v�����n���h���Ŏw�肵���v�����̃v�����������Ƃ�1�s�̃f�[�^��Ԃ��܂��B �L���b�V���L�[�̒l��v�����̓������s���ȂǁA����v�����Ɋւ���ڍׂ��擾�ł��܂��B
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH DB_CPU_Stats AS (
    SELECT
	    DatabaseID,
		DB_Name(DatabaseID)                                                                   AS [DatabaseName],
		SUM(total_worker_time)  / 1000.                                                       AS [CPU_Time (ms)],		--�R���p�C����Ƀv�����̎��s�Ŏg�p���ꂽ CPU ���Ԃ̍��v(�S�̎��Ԃ̂���CPU���g�p��������)
        SUM(total_elapsed_time) / 1000.                                                       AS [Elapsed_Time (ms)],	--���̃v�����̎��s�����܂ł̌o�ߎ��Ԃ̍��v(�S�̎���)
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
       CAST([CPU_Time (ms)]     * 1.0 / SUM([CPU_Time (ms)])     OVER() * 100.0 AS DECIMAL(5, 2)) AS [%CPU],	--50%�𒴂��Ȃ�����
       CAST([Elapsed_Time (ms)] * 1.0 / SUM([Elapsed_Time (ms)]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [%Elapsed]
FROM DB_CPU_Stats
WHERE DatabaseID > 4      -- system databases
  AND DatabaseID <> 32767 -- ResourceDB
ORDER BY row_num OPTION (RECOMPILE);

--�I�}�P------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
