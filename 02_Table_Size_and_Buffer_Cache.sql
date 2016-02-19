CREATE TABLE #TBLSize (
  Tblname       varchar(80),	--領域の使用情報を要求したオブジェクトの名前。オブジェクトのスキーマ名は返されません。 スキーマ名が必要な場合は、sys.dm_db_partition_stats または sys.dm_db_index_physical_stats 動的管理ビューを使用して、対応するサイズ情報を取得してください。
  TblRows       int,			--テーブルに含まれる行数。 指定したオブジェクトが Service Broker キューの場合、この列にはキューのメッセージ数が表示されます。
  TblReserved   varchar(80),	--ユーザーテーブルの予約領域の合計。
  TblData       varchar(80),	--ユーザーテーブルのデータ使用領域の合計。
  TblIndex_Size varchar(80),	--ユーザーテーブルのインデックス使用領域の合計。
  TblUnused     varchar(80)		--ユーザーテーブル用に予約されており、使用されていない領域の合計。
)

--Table の使用領域内訳-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Index Space が Data Space を超えないことをチェック
--	Index Space が Total Space より大きくなりすぎないことをチェック
--
--	Sp_SpaceUsed
--		現在のデータベースのテーブル、インデックス付きビュー、または Service Broker キューで使用されている、行数、ディスクの予約領域、およびディスク使用領域を表示します。
--		また、データベース全体で使用されているディスクの予約領域とディスク使用領域を表示します。
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

--危険な50件を抽出
SELECT TOP (50) * FROM (
    SELECT
	    CAST(Tblname as Varchar(30))                                             AS [Table],
	    CAST(TblRows as Varchar(14))                                             AS [Row Count],
	    CAST(LEFT(TblReserved,   CHARINDEX(' KB', TblReserved  )) as int) / 1024 AS [Total Space (MB)],
        CAST(LEFT(TblData,       CHARINDEX(' KB', TblData      )) as int) / 1024 AS [Data Space (MB)],	--Index Space が Data Space を超えないこと
	    CAST(LEFT(TblIndex_Size, CHARINDEX(' KB', TblIndex_Size)) as int) / 1024 AS [Index Space (MB)],	--Index Space が Total Space より大きくなりすぎないこと
        CAST(LEFT(TblUnused,     CHARINDEX(' KB', TblUnused    )) as int) / 1024 AS [Unused Space (MB)]
    FROM #tblSize
) AS q
WHERE [Data Space (MB)] < [Index Space (MB)]
ORDER BY [Total Space (MB)] DESC

/* 100件バージョン
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

--DB別キャッシュサイズ集計--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--sys.dm_os_buffer_descriptors
--  バッファー プールにあるすべてのデータ ページに関する情報を返します。
--  このビューの出力は、バッファー プール内のデータベース ページのディストリビューションをデータベース、オブジェクト、または種類に従って決定するために使用できます。
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
    DB_NAME(database_id)  AS [Database Name],
    COUNT(1) * 8 / 1024.0 AS [Cached Size (MB)]
FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
WHERE database_id > 4      -- system databases
  AND database_id <> 32767 -- ResourceDB
GROUP BY DB_NAME(database_id)
ORDER BY [Cached Size (MB)] DESC OPTION (RECOMPILE);
