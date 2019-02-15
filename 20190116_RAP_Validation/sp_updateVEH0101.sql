-- =============================================
-- Author:		Thomas Parry
-- Create date: 2018
-- =============================================
use Vehicles_Stock;
DROP PROCEDURE [RAP].[sp_updateVEH0101];

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RAP].[sp_updateVEH0101]
	@year int
	,@quarter int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;

---	Don't forget to change Global variables and 'from' statements to latest quarter
---	Also add a line for latest quarter for both GB and UK to each of the 'select' statements below

--- select top 1000 * from RAP.rawVEH0101
--- truncate table RAP.rawVEH0101

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
	
	IF NOT EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'rawVEH0101')
	BEGIN
		SET ANSI_NULLS ON;
		SET QUOTED_IDENTIFIER ON;
		CREATE TABLE Vehicles_Stock.[RAP].[rawVEH0101](
			[UK] int NULL,
			[Quarter] [varchar](50) NULL,
			[BodyType] [varchar](6) NOT NULL,
			[Number] [int] NULL
		)
	END

	delete from vehicles_stock.RAP.rawVEH0101
	where [Quarter] = CAST(@year as VARCHAR(4)) + ' Q' + CAST(@quarter as VARCHAR(4))

	DECLARE @DB varchar(20) = 'Vehicles_Stock'

	SET @DB = case when @year between 1994 and 2012 then 'Vehicles_Stock_Hist'
					when @year between 2013 and 2014 then 'Vehicles_Stock_Hist2'
					else 'Vehicles_Stock'
				end

	DECLARE @query as NVARCHAR(MAX)

	SET @QUERY = '
		insert into Vehicles_Stock.RAP.rawVEH0101
		select 0 as UK
			,''' + CAST(@year as VARCHAR(4)) + ' Q' + CAST(@quarter as VARCHAR(4)) + ''' as [Quarter]
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
		+ ' group by case when bodytype = ''cars'' then ''Cars''
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
		insert into Vehicles_Stock.RAP.rawVEH0101
		select 1 as UK
			,''' + CAST(@year as VARCHAR(4)) + ' Q' + CAST(@quarter as VARCHAR(4)) + ''' as [Quarter]
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
		' group by case when bodytype = ''cars'' then ''Cars''
					when bodytype = ''MOTORCYCLES, MOPEDS & SCOOTERS'' then ''Bikes''
					when bodytype = ''goods - light'' then ''LGVs''
					when bodytype = ''goods - heavy'' then ''HGVs''
					when bodytype = ''buses & coaches'' then ''Buses''
					else ''Others''
				end'

		exec(@query)
	END

	----///---///---///---///---///---///---///---///---///---///---///---///---///---///---///---
	IF EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'VEH0101_GB') DROP TABLE Vehicles_Stock.RAP.VEH0101_GB
	IF EXISTS(Select top 1 * FROM Vehicles_Stock.dbo.sysobjects where [name] like 'VEH0101_UK') DROP TABLE Vehicles_Stock.RAP.VEH0101_UK
	
	select [Quarter] as [Date]

		,sum(case when bodytype = 'Cars' then Number end) / 1000.0 as Cars
		,sum(case when bodytype = 'Bikes' then Number end) / 1000.0 as Motorcycles
		,sum(case when bodytype = 'LGVs' then Number end) / 1000.0 as [Light Goods Vehicles]
		,sum(case when bodytype = 'HGVs' then Number end) / 1000.0 as [Heavy Goods Vehicles]
		,sum(case when bodytype in ('LGVs','HGVs') then Number end) / 1000.0 as [All Goods Vehicles]
		,sum(case when bodytype = 'Buses' then Number end) / 1000.0 as [Buses & coaches]
		,sum(case when bodytype = 'Others' then Number end) / 1000.0 as [Other vehicles]
		,sum(Number) / 1000.0 as Total
		,cast(null as float) as [Year-on-year change in total vehicles]
	
	into Vehicles_Stock.RAP.VEH0101_GB
	from Vehicles_Stock.RAP.rawVEH0101
	where UK = 0
	group by [Quarter]

	union all

	select [Quarter]
		,[Cars]
		,[Bikes]
		,[LGVs]
		,[HGVs]
		,[GVs]
		,[Buses]
		,[Other]
		,[Total]
		,[YoY]
	from Vehicles_Stock.RAP.rawVEH0101_IDS

	order by [Date]

	select [Quarter] as [Date]

		,sum(case when bodytype = 'Cars' then Number end) / 1000.0 as Cars
		,sum(case when bodytype = 'Bikes' then Number end) / 1000.0 as Motorcycles
		,sum(case when bodytype = 'LGVs' then Number end) / 1000.0 as [Light Goods Vehicles]
		,sum(case when bodytype = 'HGVs' then Number end) / 1000.0 as [Heavy Goods Vehicles]
		,sum(case when bodytype in ('LGVs','HGVs') then Number end) / 1000.0 as [All Goods Vehicles]
		,sum(case when bodytype = 'Buses' then Number end) / 1000.0 as [Buses & coaches]
		,sum(case when bodytype = 'Others' then Number end) / 1000.0 as [Other vehicles]
		,sum(Number) / 1000.0 as Total
		,cast(null as float) as [Year-on-year change in total vehicles]
	
	into Vehicles_Stock.RAP.VEH0101_UK
	from Vehicles_Stock.RAP.rawVEH0101
	where UK = 1
	group by [Quarter]
	order by [Quarter]
	
	update a
	set [Year-on-year change in total vehicles] = -100.0 + (a.Total * 100.0) / cast(b.Total as float)
	FROM [Vehicles_Stock].[RAP].[VEH0101_GB] a
	left join [Vehicles_Stock].[RAP].[VEH0101_GB] b
	on left(a.date,4) = left(b.date,4) + 1
		and  right(a.Date,2) = right(b.Date,2)
		
	update a
	set [Year-on-year change in total vehicles] = -100.0 + (a.Total * 100.0) / cast(b.Total as float)
	FROM [Vehicles_Stock].[RAP].[VEH0101_UK] a
	left join [Vehicles_Stock].[RAP].[VEH0101_UK] b
	on left(a.date,4) = left(b.date,4) + 1
		and  right(a.Date,2) = right(b.Date,2)

	print('Finished processing VEH0101');
END
GO

