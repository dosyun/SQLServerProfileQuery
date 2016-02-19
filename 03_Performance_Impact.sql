--���Ԃ������肷����ACPU �g��������N�G���𒊏o(�����t��)--------------------------------------------------------------------------------------------------------------------------------------------
--	[max_elapsed_time (ms)]��1000�𒴂��Ȃ����Ƃ��`�F�b�N
--	[avg_elapsed_time (ms)]��100�𒴂��Ȃ����Ƃ��`�F�b�N
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT TOP (250)
    qs.execution_count									AS [execution_count],			--�O��̃R���p�C�����ȍ~�ɁA�v���������s���ꂽ��
    qs.total_rows										AS [total_rows],				--�N�G���ɂ���ĕԂ����s�̍��v��
	qs.last_rows										AS [last_rows],					--�N�G���̑O��̎��s�ŕԂ��ꂽ�s��
	qs.min_rows											AS [min_rows],					--�O��̃R���p�C�����ȍ~�ɁA�v���������s���ꂽ�񐔂𒴂���A�N�G���ɂ���ĕԂ����s�̍ŏ���
	qs.max_rows											AS [max_rows],					--�O��̃R���p�C�����ȍ~�ɁA�v���������s���ꂽ�񐔂𒴂���A�N�G���ɂ���ĕԂ����s�̍ő吔
    qs.last_elapsed_time  / 1000                        AS [last_elapsed_time (ms)],	--���̃v�����̑O��̎��s�����܂ł̌o�ߎ���
	qs.min_elapsed_time   / 1000                        AS [min_elapsed_time (ms)],		--�C�ӂ̃v�����̎��s�����܂ł̍ŏ��o�ߎ���
	qs.max_elapsed_time   / 1000                        AS [max_elapsed_time (ms)],		--�C�ӂ̃v�����̎��s�����܂ł̍ő�o�ߎ���(1000�𒴂��Ȃ�����!!!!)
	qs.total_elapsed_time / 1000                        AS [total_elapsed_time (ms)],	--���̃v�����̎��s�����܂ł̌o�ߎ��Ԃ̍��v
    total_worker_time     / 1000                        AS [total_worker_time (ms)],	--�R���p�C����Ƀv�����̎��s�Ŏg�p���ꂽ CPU ���Ԃ̍��v
	total_logical_reads                                 AS [total_logical_reads],		--�R���p�C����ɂ��̃v�����̎��s�ōs��ꂽ�_���ǂݎ��̍��v��
	total_logical_writes                                AS [total_logical_writes],		--�v������ 1 ��̎��s�ōs��ꂽ�_���������݂̍ő吔
    (qs.total_elapsed_time / 1000) / qs.execution_count AS [avg_elapsed_time (ms)],		--���ώ��s����(100�𒴂��Ȃ�����!!!!)
    (qs.total_worker_time  / 1000) / qs.execution_count AS [avg_worker_time (ms)],		--����CPU�g�p����
    SUBSTRING(qt.TEXT, qs.statement_start_offset / 2 + 1,
        (
	        CASE WHEN qs.statement_end_offset = -1
                 THEN LEN(CONVERT(NVARCHAR(MAX), qt.TEXT)) * 2
                 ELSE qs.statement_end_offset
            END - qs.statement_start_offset
        ) / 2
	)													AS [query_text],
	qs.plan_handle										AS [plan_handle]
FROM sys.dm_exec_query_stats                    AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
WHERE qs.total_elapsed_time / qs.execution_count > 1000
  AND execution_count > 1000
--ORDER BY qs.total_elapsed_time DESC OPTION (RECOMPILE);
ORDER BY qs.max_elapsed_time DESC OPTION (RECOMPILE);
