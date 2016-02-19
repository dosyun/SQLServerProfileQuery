--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	sys.indexes					テーブル、ビュー、テーブル値関数など、テーブル オブジェクトのインデックスまたはヒープごとに 1 行のデータを格納します
--		object_id				テーブルID
--		name					テーブル名
--		index_id				インデックスID(0:ヒープ, 1:クラスター化インデックス, 1:非クラスター化インデックス)
--		Type					インデックス種類(0:ヒープ, 1:クラスター化, 2:非クラスター化, 3:XML, 4:空間, 5:メモリ最適化列ストアインデックス, 6:非クラスター化列ストアインデックス
--		type_desc				インデックス種類の説明(HEAP, CLUSTERED, NONCLUSTERED, XML, SPATIAL, CLUSTERED COLUMNSTORE, NONCLUSTERED COLUMNSTORE)
--		is_unique				1:一意なインデックス, 0:非一意なインデックス
--		data_space_id			インデックスのデータ領域ID。データ領域はファイルグループまたはパーティション構成。0:object_idはテーブル値関数。
--		ignore_dup_key			1:IGNORE_DUP_KEYオン, 0:IGNORE_DUP_KEYオフ
--		is_primary_key			1:インデックスはPRIMARY KEY制約の一部です。
--		is_unique_constraint	1:インデックスはUNIQUE制約の一部です。
--		fill_factor				0:インデックスが作成または再構築された場合に使用されるFILLFACTORのパーセンテージ
--		is_padded				1:PADINDEXオン, 0:PADINDEXオフ
--		is_disabled				1:インデックスが無効, 0:インデックスが有効
--		is_hypothetical			1:仮想的インデックス(データへのアクセスパスとして直接使用はできません。列レベルの統計を保持しています), 0:非仮想的インデックス
--		allow_row_locks			1:行ロックを許可, 0:行ロックを許可しない
--		allow_page_locks		1:ページ ロックを許可します, 0:ページ ロックを許可しない
--		has_filter				1:フィルタ付インデックス(フィルター定義を満たす行だけが含まれる), 0:フィルタなしインデックス
--		filter_definition		フィルター選択されたインデックスに含まれる行のサブセットの式。ヒープまたはフィルター選択されたインデックス以外のインデックスの場合はNULL
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	sys.dm_db_index_usage_stats	さまざまな種類のインデックス操作の数と、各種の操作が前回実行された時刻を返します。
--		database_id				データベースのID。
--		object_id				テーブルまたはビューのID。
--		index_id				ID。
--		user_seeks				ユーザクエリによるシーク数。
--		user_scans				ユーザクエリによるスキャン数。
--		user_lookups			ユーザクエリによるブックマーク参照数。
--		user_updates			ユーザクエリによる更新数。
--		last_user_seek			前回のユーザシークの時刻。
--		last_user_scan			前回のユーザスキャンの時刻。
--		last_user_lookup		前回のユーザ参照の時刻。
--		last_user_update		前回のユーザ更新の時刻。
--		system_seeks			システムクエリによるシーク数。
--		system_scans			システムクエリによるスキャン数。
--		system_lookups			システムクエリによる参照数。
--		system_updates			システムクエリによる更新数。
--		last_system_seek		前回のシステムシークの時刻。
--		last_system_scan		前回のシステムスキャンの時刻。
--		last_system_lookup		前回のシステム参照の時刻。
--		last_system_update		前回のシステム更新の時刻。
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--張ったのに全く使われていない可能性のあるインデックスを探す------------------------------------------------------------------------------------------------------------------------------------------
--	書込回数 >> 読込回数なインデックスをチェックして見直す
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
EXECUTE sys.sp_MSforeachdb 'IF ''?''  NOT IN (''master'', ''tempDB'',''model'',''msdb'')
BEGIN
USE [?];

SELECT
    OBJECT_NAME(s.[object_id])                              AS [Table Name],
	i.name                                                  AS [Index Name],
	i.index_id                                              AS [Index Id],
	i.is_disabled                                           AS [Is Disabled],	--1:無効/0:有効
	user_updates                                            AS [Total Writes],	--書込回数(update)
	user_seeks + user_scans + user_lookups                  AS [Total Reads],	--読込回数(seek/scan/lookup)
    user_updates - (user_seeks + user_scans + user_lookups) AS [Difference]		--書込回数-読込回数
FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
   ON s.[object_id] = i.[object_id]
   AND i.index_id = s.index_id
WHERE OBJECTPROPERTY(s.[object_id],''IsUserTable'') = 1
  AND s.database_id = DB_ID()
  AND user_updates > (user_seeks + user_scans + user_lookups)
  AND i.index_id > 1
ORDER BY
    [Difference]   DESC,
	[Total Writes] DESC,
	[Total Reads]  ASC
OPTION (RECOMPILE);

END'
