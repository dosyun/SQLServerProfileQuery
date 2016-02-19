CREATE TABLE #TBLSize (
  Tblname       varchar(80),	--�̈�̎g�p����v�������I�u�W�F�N�g�̖��O�B�I�u�W�F�N�g�̃X�L�[�}���͕Ԃ���܂���B �X�L�[�}�����K�v�ȏꍇ�́Asys.dm_db_partition_stats �܂��� sys.dm_db_index_physical_stats ���I�Ǘ��r���[���g�p���āA�Ή�����T�C�Y�����擾���Ă��������B
  TblRows       int,			--�e�[�u���Ɋ܂܂��s���B �w�肵���I�u�W�F�N�g�� Service Broker �L���[�̏ꍇ�A���̗�ɂ̓L���[�̃��b�Z�[�W�����\������܂��B
  TblReserved   varchar(80),	--���[�U�[�e�[�u���̗\��̈�̍��v�B
  TblData       varchar(80),	--���[�U�[�e�[�u���̃f�[�^�g�p�̈�̍��v�B
  TblIndex_Size varchar(80),	--���[�U�[�e�[�u���̃C���f�b�N�X�g�p�̈�̍��v�B
  TblUnused     varchar(80)		--���[�U�[�e�[�u���p�ɗ\�񂳂�Ă���A�g�p����Ă��Ȃ��̈�̍��v�B
)

--Table �̎g�p�̈����-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Index Space �� Data Space �𒴂��Ȃ����Ƃ��`�F�b�N
--	Index Space �� Total Space ���傫���Ȃ肷���Ȃ����Ƃ��`�F�b�N
--
--	Sp_SpaceUsed
--		���݂̃f�[�^�x�[�X�̃e�[�u���A�C���f�b�N�X�t���r���[�A�܂��� Service Broker �L���[�Ŏg�p����Ă���A�s���A�f�B�X�N�̗\��̈�A����уf�B�X�N�g�p�̈��\�����܂��B
--		�܂��A�f�[�^�x�[�X�S�̂Ŏg�p����Ă���f�B�X�N�̗\��̈�ƃf�B�X�N�g�p�̈��\�����܂��B
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
EXEC sys.sp_MSforeachdb 'IF ''?'' NOT IN (''master'', ''tempDB'',''model'',''msdb'')
BEGIN
USE [?];
DECLARE @tablename varchar(80) 

DECLARE TblName_cursor CURSOR FOR SELECT NAME FROM sysobjects WHERE xType = ''U''
OPEN TblName_cursor
FETCH NEXT FROM TblName_cursor INTO @tablename

WHILE @@FETCH_STATUS = 0
BEGIN
   INSERT INTO #tblSize(Tblname, TblRows, TblReserved, TblData, TblIndex_Size, TblUnused)
   EXEC Sp_SpaceUsed @tablename
      
   -- Get the next author.
   FETCH NEXT FROM TblName_cursor INTO @tablename
END

CLOSE TblName_cursor
DEALLOCATE TblName_cursor
END
'

--�댯��50���𒊏o
SELECT TOP (50) * FROM (
    SELECT
	    CAST(Tblname as Varchar(30))                                             AS [Table],
	    CAST(TblRows as Varchar(14))                                             AS [Row Count],
	    CAST(LEFT(TblReserved,   CHARINDEX(' KB', TblReserved  )) as int) / 1024 AS [Total Space (MB)],
        CAST(LEFT(TblData,       CHARINDEX(' KB', TblData      )) as int) / 1024 AS [Data Space (MB)],	--Index Space �� Data Space �𒴂��Ȃ�����
	    CAST(LEFT(TblIndex_Size, CHARINDEX(' KB', TblIndex_Size)) as int) / 1024 AS [Index Space (MB)],	--Index Space �� Total Space ���傫���Ȃ肷���Ȃ�����
        CAST(LEFT(TblUnused,     CHARINDEX(' KB', TblUnused    )) as int) / 1024 AS [Unused Space (MB)]
    FROM #tblSize
) AS q
WHERE [Data Space (MB)] < [Index Space (MB)]
ORDER BY [Total Space (MB)] DESC

/* 100���o�[�W����
SELECT TOP (100)
    CAST(Tblname as Varchar(30)) 'Table',
	CAST(TblRows as Varchar(14)) 'Row Count',
	CAST(LEFT(TblReserved,   CHARINDEX(' KB', TblReserved  )) as int) / 1024 AS 'Total Space (MB)',
    CAST(LEFT(TblData,       CHARINDEX(' KB', TblData      )) as int) / 1024 AS 'Data Space (MB)',
	CAST(LEFT(TblIndex_Size, CHARINDEX(' KB', TblIndex_Size)) as int) / 1024 AS 'Index Space (MB)',
    CAST(LEFT(TblUnused,     CHARINDEX(' KB', TblUnused    )) as int) / 1024 AS 'Unused Space (MB)'
FROM #tblSize
Order by [Total Space (MB)] Desc
*/

DROP TABLE #TblSize

--DB�ʃL���b�V���T�C�Y�W�v--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--sys.dm_os_buffer_descriptors
--  �o�b�t�@�[ �v�[���ɂ��邷�ׂẴf�[�^ �y�[�W�Ɋւ������Ԃ��܂��B
--  ���̃r���[�̏o�͂́A�o�b�t�@�[ �v�[�����̃f�[�^�x�[�X �y�[�W�̃f�B�X�g���r���[�V�������f�[�^�x�[�X�A�I�u�W�F�N�g�A�܂��͎�ނɏ]���Č��肷�邽�߂Ɏg�p�ł��܂��B
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
    DB_NAME(database_id)  AS [Database Name],
    COUNT(1) * 8 / 1024.0 AS [Cached Size (MB)]
FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
WHERE database_id > 4      -- system databases
  AND database_id <> 32767 -- ResourceDB
GROUP BY DB_NAME(database_id)
ORDER BY [Cached Size (MB)] DESC OPTION (RECOMPILE);
