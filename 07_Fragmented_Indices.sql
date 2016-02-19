--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	sys.dm_db_index_physical_stats
--		指定したテーブルまたはビューのデータとインデックスに関する、サイズおよび断片化情報を返します。
--		インデックスの場合、各パーティションの B ツリーのレベルごとに 1 行のデータが返されます。
--		ヒープ(インデックス無し)の場合、各パーティションの IN_ROW_DATA アロケーション ユニットごとに 1 行のデータが返されます。
--		ラージオブジェクト(LOB)データの場合、各パーティションの LOB_DATA アロケーション ユニットごとに 1 行のデータが返されます。
--		テーブルに行オーバーフローデータが存在する場合、各パーティションの ROW_OVERFLOW_DATA アロケーションユニットごとに 1 行のデータが返されます。
--		xVelocity メモリ最適化列ストア インデックスに関する情報は返されません。
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--断片化のひどいインデックス、クラスタ化インデックスの一覧--------------------------------------------------------------------------------------------------------------------------------------------
--	avg_fragmentation_in_percentが50%以下が理想。超えてたら再構築すると良い。が、現状はほとんどが98%...
--	なのでavg_fragmentation_in_percentは、現状あまり問題視していない。IoDriveすげー
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
EXEC sys.sp_MSforeachdb   'IF ''?''  NOT IN (''master'', ''tempDB'',''model'',''msdb'')
BEGIN
USE [?];

SELECT
    DB_NAME(database_id) AS [Database Name],
	OBJECT_NAME(ps.OBJECT_ID) AS [Object Name],
	i.name AS [Index Name],
	ps.index_id,
	index_type_desc,				--インデックスの種類(Heap/ClusteredIndex/NonclusteredIndex/PrimaryXmlIndex/SpatialIndex/XmlIndex)
	avg_fragmentation_in_percent,	--論理的な断片化の割合(ここが50%以下であることが理想)
	fragment_count,					--インデックス内の断片化(物理的に連続したリーフページ)の数
	page_count						--インデックスページまたはデータページの合計数
FROM       sys.dm_db_index_physical_stats(DB_ID(),NULL, NULL, NULL ,''LIMITED'') AS ps 
INNER JOIN sys.indexes                                                           AS i WITH (NOLOCK)
   ON ps.[object_id] = i.[object_id] 
  AND ps.index_id = i.index_id
WHERE database_id = DB_ID()
  AND page_count > 1500
ORDER BY avg_fragmentation_in_percent DESC OPTION (RECOMPILE);
END'
