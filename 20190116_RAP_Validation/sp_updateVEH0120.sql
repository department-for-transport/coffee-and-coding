-- =============================================
-- Author:		Thomas Parry
-- Create date: 2018
-- =============================================
use Vehicles_Stock;
DROP PROCEDURE [RAP].[sp_updateVEH0120];

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RAP].[sp_updateVEH0120]
	@year int
	,@quarter int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

---	Don't forget to change Global variables and 'from' statements to latest quarter
---	Also add a line for latest quarter for both GB and UK to each of the 'select' statements below

--- select top 1000 * from RAP.rawVEH0120
--- truncate table RAP.rawVEH0120

	IF(@year is null
		or @quarter is null
		)
	BEGIN
		RAISERROR('Input cannot be null',18,0)
		RETURN
	END

	IF(@year < 1994
		or @quarter not in (1,2,3,4)
		or @year = 2008 and @quarter not in (3,4)
		or @year < 2008 and @quarter <> 4
		)
	BEGIN
		RAISERROR('Input not for valid licensed stock database',18,0)
		RETURN
	END

	DECLARE @UK tinyint = 1;

	SET @UK = case when @year > 2014
					or @year = 2014 and @quarter in (3,4) then 1
					else 0
				end
	
	IF NOT EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'rawVEH0120')
	BEGIN
		SET ANSI_NULLS ON;
		SET QUOTED_IDENTIFIER ON;
		CREATE TABLE Vehicles_Stock.[RAP].[rawVEH0120](
			[Date] [varchar](50) NULL,
			[MakeID] [varchar](2) NULL,
			[ModelID] [varchar](3) NULL,
			[BodyType] [varchar](6) NOT NULL,
			[Number] [int] NULL
		)
	END

	delete from vehicles_stock.RAP.rawVEH0120
	where [Date] in ('GB ' + CAST(@year as VARCHAR(4)) +
						' Q' + CAST(@quarter as VARCHAR(4))
				 ,'UK ' + CAST(@year as VARCHAR(4)) +
						 ' Q' + CAST(@quarter as VARCHAR(4))
					)

	--select 'GB ' + CAST(@year as VARCHAR(4)) +
	--					'Q' + CAST(@quarter as VARCHAR(4))
	--			 ,'UK ' + CAST(@year as VARCHAR(4)) +
	--					 'Q' + CAST(@quarter as VARCHAR(4))

	DECLARE @DB varchar(20) = 'Vehicles_Stock'

	SET @DB = case when @year between 1994 and 2012 then 'Vehicles_Stock_Hist'
					when @year between 2013 and 2014 then 'Vehicles_Stock_Hist2'
					else 'Vehicles_Stock'
				end

	DECLARE @query as NVARCHAR(MAX)

	SET @QUERY = '
		insert into Vehicles_Stock.RAP.rawVEH0120
		select ''GB ' + CAST(@year as VARCHAR(4)) +
				 ' Q' + CAST(@quarter as VARCHAR(4)) + ''' as [Date]
			,MakeID
			,ModelID
			,case when bodytype = ''cars'' then ''Cars''
					when bodytype = ''MOTORCYCLES, MOPEDS & SCOOTERS'' then ''Bikes''
					when bodytype = ''goods - light'' then ''LGVs''
					when bodytype = ''goods - heavy'' then ''HGVs''
					when bodytype = ''buses & coaches'' then ''Buses''
					else ''Others''
				end as BodyType
			,SUM(1) as Number
		from ' + @DB + '.dbo.LicStock_' + CAST(@year as VARCHAR(4)) +
				 'Q' + CAST(@quarter as VARCHAR(4)) + 
		case when @year > 2009 then ' where country=''gb''' else '' end
		+ ' group by MakeID
			,ModelID
			,case when bodytype = ''cars'' then ''Cars''
					when bodytype = ''MOTORCYCLES, MOPEDS & SCOOTERS'' then ''Bikes''
					when bodytype = ''goods - light'' then ''LGVs''
					when bodytype = ''goods - heavy'' then ''HGVs''
					when bodytype = ''buses & coaches'' then ''Buses''
					else ''Others''
				end'

	exec(@query)

	IF(@UK = 1)
	BEGIN
		SET @QUERY = '
			insert into Vehicles_Stock.RAP.rawVEH0120
			select ''UK ' + CAST(@year as VARCHAR(4)) +
					 ' Q' + CAST(@quarter as VARCHAR(4)) + ''' as [Date]
				,MakeID
				,ModelID
				,case when bodytype = ''cars'' then ''Cars''
						when bodytype = ''MOTORCYCLES, MOPEDS & SCOOTERS'' then ''Bikes''
						when bodytype = ''goods - light'' then ''LGVs''
						when bodytype = ''goods - heavy'' then ''HGVs''
						when bodytype = ''buses & coaches'' then ''Buses''
						else ''Others''
					end as BodyType
				,SUM(1) as Number
			from ' + @DB + '.dbo.LicStock_' + CAST(@year as VARCHAR(4)) +
					 'Q' + CAST(@quarter as VARCHAR(4)) + 
			' group by MakeID
				,ModelID
				,case when bodytype = ''cars'' then ''Cars''
						when bodytype = ''MOTORCYCLES, MOPEDS & SCOOTERS'' then ''Bikes''
						when bodytype = ''goods - light'' then ''LGVs''
						when bodytype = ''goods - heavy'' then ''HGVs''
						when bodytype = ''buses & coaches'' then ''Buses''
						else ''Others''
					end'
		exec(@query)
	END

	----///---///---///---///---///---///---///---///---///---///---///---///---///---///---///---///

	IF EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'VEH0120_Cars') DROP TABLE Vehicles_Stock.RAP.VEH0120_Cars
	IF EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'VEH0120_Bikes') DROP TABLE Vehicles_Stock.RAP.VEH0120_Bikes
	IF EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'VEH0120_LGVs') DROP TABLE Vehicles_Stock.RAP.VEH0120_LGVs
	IF EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'VEH0120_HGVs') DROP TABLE Vehicles_Stock.RAP.VEH0120_HGVs
	IF EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'VEH0120_Buses') DROP TABLE Vehicles_Stock.RAP.VEH0120_Buses
	IF EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'VEH0120_Others') DROP TABLE Vehicles_Stock.RAP.VEH0120_Others

	DECLARE @cols AS NVARCHAR(MAX)
			,@queryOutput AS NVARCHAR(MAX)

	select @cols = STUFF(
						(SELECT ',' + QUOTENAME([Date]) 
							from RAP.rawVEH0120
							group by [Date]
							order by [Date] desc
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,1,'') 

	--- Cars
	set @queryOutput = 'SELECT Make,Model,' + @cols + '
				into Vehicles_Stock.RAP.VEH0120_Cars
				from (
					select coalesce(UPPER(MakeDesc),''MISSING'') as Make
						,coalesce(UPPER(ModelDesc),''MISSING'') as Model
						,[Date]
						,Number
					from RAP.rawVEH0120 v
					left join Vehicles_LookupTables.dbo.MakeModelLookup m
						on v.makeid = m.MakeCode
						and v.modelid = m.ModelCode
					where BodyType = ''Cars''
				) x
				pivot 
				(
					sum(Number)
					for [Date] in (' + @cols + ')
				) p
				order by Make,Model'

	execute(@queryOutput);
	
	--- Motorcycles
	set @queryOutput = 'SELECT Make,Model,' + @cols + '
				into Vehicles_Stock.RAP.VEH0120_Bikes
				from (
					select coalesce(UPPER(MakeDesc),''MISSING'') as Make
						,coalesce(UPPER(ModelDesc),''MISSING'') as Model
						,[Date]
						,Number
					from RAP.rawVEH0120 v
					left join Vehicles_LookupTables.dbo.MakeModelLookup m
						on v.makeid = m.MakeCode
						and v.modelid = m.ModelCode
					where BodyType = ''Bikes''
				) x
				pivot 
				(
					sum(Number)
					for [Date] in (' + @cols + ')
				) p
				order by Make,Model'

	execute(@queryOutput);
	
	--- LGVs
	set @queryOutput = 'SELECT Make,Model,' + @cols + '
				into Vehicles_Stock.RAP.VEH0120_LGVs
				from (
					select coalesce(UPPER(MakeDesc),''MISSING'') as Make
						,coalesce(UPPER(ModelDesc),''MISSING'') as Model
						,[Date]
						,Number
					from RAP.rawVEH0120 v
					left join Vehicles_LookupTables.dbo.MakeModelLookup m
						on v.makeid = m.MakeCode
						and v.modelid = m.ModelCode
					where BodyType = ''LGVs''
				) x
				pivot 
				(
					sum(Number)
					for [Date] in (' + @cols + ')
				) p
				order by Make,Model'

	execute(@queryOutput);
	
	--- HGVs
	set @queryOutput = 'SELECT Make,Model,' + @cols + '
				into Vehicles_Stock.RAP.VEH0120_HGVs
				from (
					select coalesce(UPPER(MakeDesc),''MISSING'') as Make
						,coalesce(UPPER(ModelDesc),''MISSING'') as Model
						,[Date]
						,Number
					from RAP.rawVEH0120 v
					left join Vehicles_LookupTables.dbo.MakeModelLookup m
						on v.makeid = m.MakeCode
						and v.modelid = m.ModelCode
					where BodyType = ''HGVs''
				) x
				pivot 
				(
					sum(Number)
					for [Date] in (' + @cols + ')
				) p
				order by Make,Model'

	execute(@queryOutput);
	
	--- Buses
	set @queryOutput = 'SELECT Make,Model,' + @cols + '
				into Vehicles_Stock.RAP.VEH0120_Buses
				from (
					select coalesce(UPPER(MakeDesc),''MISSING'') as Make
						,coalesce(UPPER(ModelDesc),''MISSING'') as Model
						,[Date]
						,Number
					from RAP.rawVEH0120 v
					left join Vehicles_LookupTables.dbo.MakeModelLookup m
						on v.makeid = m.MakeCode
						and v.modelid = m.ModelCode
					where BodyType = ''Buses''
				) x
				pivot 
				(
					sum(Number)
					for [Date] in (' + @cols + ')
				) p
				order by Make,Model'

	execute(@queryOutput);
	
	--- Others
	set @queryOutput = 'SELECT Make,Model,' + @cols + '
				into Vehicles_Stock.RAP.VEH0120_Others
				from (
					select coalesce(UPPER(MakeDesc),''MISSING'') as Make
						,coalesce(UPPER(ModelDesc),''MISSING'') as Model
						,[Date]
						,Number
					from RAP.rawVEH0120 v
					left join Vehicles_LookupTables.dbo.MakeModelLookup m
						on v.makeid = m.MakeCode
						and v.modelid = m.ModelCode
					where BodyType = ''Others''
				) x
				pivot 
				(
					sum(Number)
					for [Date] in (' + @cols + ')
				) p
				order by Make,Model'

	execute(@queryOutput);

	----///---///---///---///---///---///---///---///---///---///---///---///---///---///---///---///

	IF EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'VEH0128_Cars') DROP TABLE Vehicles_Stock.RAP.VEH0128_Cars
	IF EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'VEH0128_Bikes') DROP TABLE Vehicles_Stock.RAP.VEH0128_Bikes
	IF EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'VEH0128_LGVs') DROP TABLE Vehicles_Stock.RAP.VEH0128_LGVs
	IF EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'VEH0128_HGVs') DROP TABLE Vehicles_Stock.RAP.VEH0128_HGVs
	IF EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'VEH0128_Buses') DROP TABLE Vehicles_Stock.RAP.VEH0128_Buses
	IF EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'VEH0128_Others') DROP TABLE Vehicles_Stock.RAP.VEH0128_Others
	
	select @cols = STUFF(
						(SELECT ',' + QUOTENAME([Date]) 
							from RAP.rawVEH0120
							group by [Date]
							order by [Date] desc
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,1,'') 

	--- Cars
	set @queryOutput = 'SELECT [Generic model],' + @cols + '
				into Vehicles_Stock.RAP.VEH0128_Cars
				from (
					select coalesce(UPPER(GenModel),''MAKE MISSING MODEL MISSING'') as [Generic model]
						,[Date]
						,Number
					from RAP.rawVEH0120 v
					left join Vehicles_LookupTables.dbo.MakeModelLookup m
						on v.makeid = m.MakeCode
						and v.modelid = m.ModelCode
					where BodyType = ''Cars''
				) x
				pivot 
				(
					sum(Number)
					for [Date] in (' + @cols + ')
				) p
				order by 2 desc,1'

	execute(@queryOutput);
	
	--- Motorcycles
	set @queryOutput = 'SELECT [Generic model],' + @cols + '
				into Vehicles_Stock.RAP.VEH0128_Bikes
				from (
					select coalesce(UPPER(GenModel),''MAKE MISSING MODEL MISSING'') as [Generic model]
						,[Date]
						,Number
					from RAP.rawVEH0120 v
					left join Vehicles_LookupTables.dbo.MakeModelLookup m
						on v.makeid = m.MakeCode
						and v.modelid = m.ModelCode
					where BodyType = ''Bikes''
				) x
				pivot 
				(
					sum(Number)
					for [Date] in (' + @cols + ')
				) p
				order by [Generic model]'

	execute(@queryOutput);
	
	--- LGVs
	set @queryOutput = 'SELECT [Generic model],' + @cols + '
				into Vehicles_Stock.RAP.VEH0128_LGVs
				from (
					select coalesce(UPPER(GenModel),''MAKE MISSING MODEL MISSING'') as [Generic model]
						,[Date]
						,Number
					from RAP.rawVEH0120 v
					left join Vehicles_LookupTables.dbo.MakeModelLookup m
						on v.makeid = m.MakeCode
						and v.modelid = m.ModelCode
					where BodyType = ''LGVs''
				) x
				pivot 
				(
					sum(Number)
					for [Date] in (' + @cols + ')
				) p
				order by 2 desc, 1'

	execute(@queryOutput);
	
	--- HGVs
	set @queryOutput = 'SELECT [Generic model],' + @cols + '
				into Vehicles_Stock.RAP.VEH0128_HGVs
				from (
					select coalesce(UPPER(GenModel),''MAKE MISSING MODEL MISSING'') as [Generic model]
						,[Date]
						,Number
					from RAP.rawVEH0120 v
					left join Vehicles_LookupTables.dbo.MakeModelLookup m
						on v.makeid = m.MakeCode
						and v.modelid = m.ModelCode
					where BodyType = ''HGVs''
				) x
				pivot 
				(
					sum(Number)
					for [Date] in (' + @cols + ')
				) p
				order by [Generic model]'

	execute(@queryOutput);
	
	--- Buses
	set @queryOutput = 'SELECT [Generic model],' + @cols + '
				into Vehicles_Stock.RAP.VEH0128_Buses
				from (
					select coalesce(UPPER(GenModel),''MAKE MISSING MODEL MISSING'') as [Generic model]
						,[Date]
						,Number
					from RAP.rawVEH0120 v
					left join Vehicles_LookupTables.dbo.MakeModelLookup m
						on v.makeid = m.MakeCode
						and v.modelid = m.ModelCode
					where BodyType = ''Buses''
				) x
				pivot 
				(
					sum(Number)
					for [Date] in (' + @cols + ')
				) p
				order by [Generic model]'

	execute(@queryOutput);
	
	--- Others
	set @queryOutput = 'SELECT [Generic model],' + @cols + '
				into Vehicles_Stock.RAP.VEH0128_Others
				from (
					select coalesce(UPPER(GenModel),''MAKE MISSING MODEL MISSING'') as [Generic model]
						,[Date]
						,Number
					from RAP.rawVEH0120 v
					left join Vehicles_LookupTables.dbo.MakeModelLookup m
						on v.makeid = m.MakeCode
						and v.modelid = m.ModelCode
					where BodyType = ''Others''
				) x
				pivot 
				(
					sum(Number)
					for [Date] in (' + @cols + ')
				) p
				order by [Generic model]'
				
	execute(@queryOutput);

	print('Finished processing VEH0120');
	print('Finished processing VEH0128');
END
GO

