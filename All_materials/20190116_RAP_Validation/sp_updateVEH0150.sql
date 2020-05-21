-- =============================================
-- Author:		Thomas Parry
-- Create date: 2018
-- =============================================
use Vehicles_Newreg;
DROP PROCEDURE [RAP].[sp_updateVEH0150];

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RAP].[sp_updateVEH0150]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
	
	IF EXISTS(Select top 1 * FROM Vehicles_NewReg.dbo.sysobjects where [name] like 'VEH0150_GB') DROP TABLE Vehicles_NewReg.RAP.VEH0150_GB
	IF EXISTS(Select top 1 * FROM Vehicles_NewReg.dbo.sysobjects where [name] like 'VEH0150_UK') DROP TABLE Vehicles_NewReg.RAP.VEH0150_UK
	IF EXISTS(Select top 1 * FROM Vehicles_NewReg.dbo.sysobjects where [name] like 'tmpULEV') DROP TABLE Vehicles_NewReg.RAP.tmpULEV

	declare @lastmonth varchar(10)
	declare @lastquarter varchar(10)
	declare @lastyear varchar(10)
	set @lastmonth=(select MAX(monthfirstreg) from newregfinal)
	set @lastquarter=(
		case when SUBSTRING(@lastmonth,6,2) between '01' and '02' then 
			cast(cast(LEFT(@lastmonth,4) as float)-1 as varchar(10))+'-'+'12'
		when SUBSTRING(@lastmonth,6,2) between '03' and '05' then LEFT(@lastmonth,4)+'-'+'03'
		when SUBSTRING(@lastmonth,6,2) between '06' and '08' then LEFT(@lastmonth,4)+'-'+'06'
		when SUBSTRING(@lastmonth,6,2) between '09' and '11' then LEFT(@lastmonth,4)+'-'+'09'
     		else LEFT(@lastmonth,4)+'-'+'12' end)
	set @lastyear=(
		case when SUBSTRING(@lastmonth,6,2) < '12' then cast(cast(LEFT(@lastmonth,4) as float)-1 
			as varchar(10))+'-'+'12'
		else LEFT(@lastmonth,4)+'-'+'12' end)
		
	select '1' as PerNum
		,null as Sort
		,left(monthfirstreg,4) as Date
		,count(case when bodytype = 'cars' then 1 end) / 1000.0 as Cars
		,count(case when bodytype = 'MOTORCYCLES, MOPEDS & SCOOTERS' then 1 end) / 1000.0 as Motorcycles
		,count(case when bodytype = 'GOODS - LIGHT' then 1 end) / 1000.0 as [Light Goods Vehicles]
		,count(case when bodytype = 'GOODS - HEAVY' then 1 end) / 1000.0 as [Heavy Goods Vehicles]
		,count(case when bodytype = 'BUSES & COACHES' then 1 end) / 1000.0 as [Buses & coaches]
		,count(case when bodytype in ('AGRICULTURAL', 'NOT RECORDED','OTHERS','SPECIAL PURPOSE','TRICYCLES','TAXIS') then 1 end) / 1000.0 as [Other vehicles]
		,sum(1) / 1000.0 as Total
		,cast(null as float) as [Year-on-year change in total vehicles]
		,avg(case when bodytype='cars' and (co2 > 0 or propulsiontype='electricity') then co2 else null end) as [Average CO2 emissions for newly registered cars]
		,cast(null as float) as [Ultra Low Emission Vehicles (ULEVs)]
		,cast(null as float) as [Ultra Low Emission Cars]
		,cast(null as float) as [Plug-in Grant Eligible Cars and Vans]
		,cast(null as float) as [Plug-in Non Grant Eligible Cars and Vans]

	into Vehicles_NewReg.RAP.VEH0150_GB

	from dbo.newregfinal
	where Country = 'gb' and MonthFirstReg <= @lastyear
	group by left(MonthFirstReg,4)

	union all

	select '2' as PerNum
		,null
		,left(monthfirstreg,4) + ' '
			+ CASE WHEN right(monthfirstreg,2) in ('01','02','03') THEN 'Q1'
					WHEN right(monthfirstreg,2) in ('04','05','06') THEN 'Q2'
					WHEN right(monthfirstreg,2) in ('07','08','09') THEN 'Q3'
					ELSE 'Q4'
			END as Date
		,count(case when bodytype = 'cars' then 1 end) / 1000.0 as Cars
		,count(case when bodytype = 'MOTORCYCLES, MOPEDS & SCOOTERS' then 1 end) / 1000.0 as Bikes
		,count(case when bodytype = 'GOODS - LIGHT' then 1 end) / 1000.0 as LGV
		,count(case when bodytype = 'GOODS - HEAVY' then 1 end) / 1000.0 as HGV
		,count(case when bodytype = 'BUSES & COACHES' then 1 end) / 1000.0 as Bus
		,count(case when bodytype in ('AGRICULTURAL', 'NOT RECORDED','OTHERS','SPECIAL PURPOSE','TRICYCLES','TAXIS') then 1 end) / 1000.0 as Other
		,sum(1) / 1000.0 as Total
		,cast(null as float) as YoY
		,avg(case when bodytype='cars' and (co2 > 0 or propulsiontype='electricity') then co2 else null end) as [AvgCo2]
		,cast(null as float) as Ulev
		,cast(null as float) as UlevCars
		,cast(null as float) as PluginGrant
		,cast(null as float) as PluginNonGrant
	from dbo.newregfinal
	where Country = 'gb' and MonthFirstReg <= @lastquarter
	group by left(monthfirstreg,4) + ' '
			+ CASE WHEN right(monthfirstreg,2) in ('01','02','03') THEN 'Q1'
					WHEN right(monthfirstreg,2) in ('04','05','06') THEN 'Q2'
					WHEN right(monthfirstreg,2) in ('07','08','09') THEN 'Q3'
					ELSE 'Q4'
			END

	union all

	select '3' as PerNum
		,MonthFirstReg as Sort
		,LEFT(datename(month,MonthFirstReg + '-01'),3) + ' '
			+ left(monthfirstreg,4)
			as Date
		,count(case when bodytype = 'cars' then 1 end) / 1000.0 as Cars
		,count(case when bodytype = 'MOTORCYCLES, MOPEDS & SCOOTERS' then 1 end) / 1000.0 as Bikes
		,count(case when bodytype = 'GOODS - LIGHT' then 1 end) / 1000.0 as LGV
		,count(case when bodytype = 'GOODS - HEAVY' then 1 end) / 1000.0 as HGV
		,count(case when bodytype = 'BUSES & COACHES' then 1 end) / 1000.0 as Bus
		,count(case when bodytype in ('AGRICULTURAL', 'NOT RECORDED','OTHERS','SPECIAL PURPOSE','TRICYCLES','TAXIS') then 1 end) / 1000.0 as Other
		,sum(1) / 1000.0 as Total
		,cast(null as float) as YoY
		,avg(case when bodytype='cars' and (co2 > 0 or propulsiontype='electricity') then co2 else null end) as [AvgCo2]
		,cast(null as float) as Ulev
		,cast(null as float) as UlevCars
		,cast(null as float) as PluginGrant
		,cast(null as float) as PluginNonGrant
	from dbo.newregfinal
	where Country = 'gb' and MonthFirstReg <= @lastmonth
	group by MonthFirstReg
		,LEFT(datename(month,MonthFirstReg + '-01'),3) + ' '
			+ left(monthfirstreg,4)

	order by Pernum,Sort,Date

----////----////----////----////----////----////----////----////----////----////----////----////----////----////

	update RAP.VEH0150_GB
	set [Average CO2 emissions for newly registered cars] = null
	where Date like '%2001%' or Date like '%2002%'

----////----////----////----////----////----////----////----////----////----////----////----////----////----////
	
	select '1' as PerNum
		,left(monthfirstreg,4) as Date
		,sum(1) / 1000.0 as Ulev
		,count(case when bodytype = 'cars' then 1 end) / 1000.0 as UlevCars
		,count(case when category <=4 and (bodytype='goods - light' or (bodytype='cars' and cattype not in ('L6', 'L7'))) then 1 end) / 1000.0 as PluginGrant
		,count(case when category > 4 and (bodytype='goods - light' or (bodytype='cars' and cattype not in ('L6', 'L7'))) and plugin = 1 then 1 end) / 1000.0 as PluginNonGrant

	into Vehicles_NewReg.RAP.tmpULEV

	from dbo.ULEV_NewReg n
	left join vehicles_lookuptables.dbo.PlugIns p
		on n.makeid = p.makeid
		and n.modelid = p.modelid
	where valid = 1 and MonthFirstReg <= @lastyear and country = 'gb'
	group by left(monthfirstreg,4)

	union all

	select '2' as PerNum
		,left(monthfirstreg,4) + ' '
			+ CASE WHEN right(monthfirstreg,2) in ('01','02','03') THEN 'Q1'
					WHEN right(monthfirstreg,2) in ('04','05','06') THEN 'Q2'
					WHEN right(monthfirstreg,2) in ('07','08','09') THEN 'Q3'
					ELSE 'Q4'
			END as Date
		,sum(1) / 1000.0 as Ulev
		,count(case when bodytype = 'cars' then 1 end) / 1000.0 as UlevCars
		,count(case when category <=4 and (bodytype='goods - light' or (bodytype='cars' and cattype not in ('L6', 'L7'))) then 1 end) / 1000.0 as PluginGrant
		,count(case when category > 4 and (bodytype='goods - light' or (bodytype='cars' and cattype not in ('L6', 'L7'))) and plugin = 1 then 1 end) / 1000.0 as PluginNonGrant

	from dbo.ULEV_NewReg n
	left join vehicles_lookuptables.dbo.PlugIns p
		on n.makeid = p.makeid
		and n.modelid = p.modelid
	where valid = 1 and MonthFirstReg <= @lastquarter and country = 'gb'
	group by left(monthfirstreg,4) + ' '
			+ CASE WHEN right(monthfirstreg,2) in ('01','02','03') THEN 'Q1'
					WHEN right(monthfirstreg,2) in ('04','05','06') THEN 'Q2'
					WHEN right(monthfirstreg,2) in ('07','08','09') THEN 'Q3'
					ELSE 'Q4'
			END

	union all

	select '3' as PerNum
		,LEFT(datename(month,MonthFirstReg + '-01'),3) + ' '
			+ left(monthfirstreg,4)
			as Date
		,sum(1) / 1000.0 as Ulev
		,count(case when bodytype = 'cars' then 1 end) / 1000.0 as UlevCars
		,count(case when category <=4 and (bodytype='goods - light' or (bodytype='cars' and cattype not in ('L6', 'L7'))) then 1 end) / 1000.0 as PluginGrant
		,count(case when category > 4 and (bodytype='goods - light' or (bodytype='cars' and cattype not in ('L6', 'L7'))) and plugin = 1 then 1 end) / 1000.0 as PluginNonGrant

	from dbo.ULEV_NewReg n
	left join vehicles_lookuptables.dbo.PlugIns p
		on n.makeid = p.makeid
		and n.modelid = p.modelid
	where valid = 1 and MonthFirstReg <= @lastmonth and country = 'gb'
	group by LEFT(datename(month,MonthFirstReg + '-01'),3) + ' '
			+ left(monthfirstreg,4)

	order by Pernum,Date
	
----////----////----////----////----////----////----////----////----////----////----////----////----////----////
	
	update RAP.VEH0150_GB
	set [Ultra Low Emission Vehicles (ULEVs)] = u.Ulev
		,[Ultra Low Emission Cars] = u.UlevCars
		,[Plug-in Grant Eligible Cars and Vans] = u.PluginGrant
		,[Plug-in Non Grant Eligible Cars and Vans] = u.PluginNonGrant
	from RAP.tmpULEV u
	join RAP.VEH0150_GB v
	on u.PerNum = v.PerNum
		and u.Date = v.Date

	update a
	set [Year-on-year change in total vehicles] = -100.0 + (a.Total * 100.0) / cast(b.Total as float)
	FROM [Vehicles_NewReg].[RAP].[VEH0150_GB] a
	left join [Vehicles_NewReg].[RAP].[VEH0150_GB] b
	on a.pernum = b.pernum
	and cast(case a.pernum
			when 1 then a.date
			when 2 then left(a.date,4)
			when 3 then right(a.date,4)
		end as int)
		= cast(case b.pernum
			when 1 then b.date
			when 2 then left(b.date,4)
			when 3 then right(b.date,4)
		end as int) + 1
	and case a.pernum
			when 1 then ''
			when 2 then right(a.Date,2)
			when 3 then left(a.Date,3)
		end
		= case b.pernum
			when 1 then ''
			when 2 then right(b.Date,2)
			when 3 then left(b.Date,3)
		end
		
----////----////----////----////----////----////----////----////----////----////----////----////----////----////

	IF EXISTS(Select top 1 * FROM Vehicles_NewReg.dbo.sysobjects where [name] like 'tmpULEV') DROP TABLE Vehicles_NewReg.RAP.tmpULEV

	select '1' as PerNum
		,null as Sort
		,left(monthfirstreg,4) as Date
		,count(case when bodytype = 'cars' then 1 end) / 1000.0 as Cars
		,count(case when bodytype = 'MOTORCYCLES, MOPEDS & SCOOTERS' then 1 end) / 1000.0 as Motorcycles
		,count(case when bodytype = 'GOODS - LIGHT' then 1 end) / 1000.0 as [Light Goods Vehicles]
		,count(case when bodytype = 'GOODS - HEAVY' then 1 end) / 1000.0 as [Heavy Goods Vehicles]
		,count(case when bodytype = 'BUSES & COACHES' then 1 end) / 1000.0 as [Buses & coaches]
		,count(case when bodytype in ('AGRICULTURAL', 'NOT RECORDED','OTHERS','SPECIAL PURPOSE','TRICYCLES','TAXIS') then 1 end) / 1000.0 as [Other vehicles]
		,sum(1) / 1000.0 as Total
		,cast(null as float) as [Year-on-year change in total vehicles]
		,avg(case when bodytype='cars' and (co2 > 0 or propulsiontype='electricity') then co2 else null end) as [Average CO2 emissions for newly registered cars]
		,cast(null as float) as [Ultra Low Emission Vehicles (ULEVs)]
		,cast(null as float) as [Ultra Low Emission Cars]
		,cast(null as float) as [Plug-in Grant Eligible Cars and Vans]
		,cast(null as float) as [Plug-in Non Grant Eligible Cars and Vans]

	into Vehicles_NewReg.RAP.VEH0150_UK

	from dbo.newregfinal
	where MonthFirstReg >= '2015-01' and MonthFirstReg <= @lastyear
	group by left(MonthFirstReg,4)

	union all

	select '2' as PerNum
		,null
		,left(monthfirstreg,4) + ' '
			+ CASE WHEN right(monthfirstreg,2) in ('01','02','03') THEN 'Q1'
					WHEN right(monthfirstreg,2) in ('04','05','06') THEN 'Q2'
					WHEN right(monthfirstreg,2) in ('07','08','09') THEN 'Q3'
					ELSE 'Q4'
			END as Date
		,count(case when bodytype = 'cars' then 1 end) / 1000.0 as Cars
		,count(case when bodytype = 'MOTORCYCLES, MOPEDS & SCOOTERS' then 1 end) / 1000.0 as Bikes
		,count(case when bodytype = 'GOODS - LIGHT' then 1 end) / 1000.0 as LGV
		,count(case when bodytype = 'GOODS - HEAVY' then 1 end) / 1000.0 as HGV
		,count(case when bodytype = 'BUSES & COACHES' then 1 end) / 1000.0 as Bus
		,count(case when bodytype in ('AGRICULTURAL', 'NOT RECORDED','OTHERS','SPECIAL PURPOSE','TRICYCLES','TAXIS') then 1 end) / 1000.0 as Other
		,sum(1) / 1000.0 as Total
		,cast(null as float) as YoY
		,avg(case when bodytype='cars' and (co2 > 0 or propulsiontype='electricity') then co2 else null end) as [AvgCo2]
		,cast(null as float) as Ulev
		,cast(null as float) as UlevCars
		,cast(null as float) as PluginGrant
		,cast(null as float) as PluginNonGrant
	from dbo.newregfinal
	where MonthFirstReg >= '2014-07' and MonthFirstReg <= @lastquarter
	group by left(monthfirstreg,4) + ' '
			+ CASE WHEN right(monthfirstreg,2) in ('01','02','03') THEN 'Q1'
					WHEN right(monthfirstreg,2) in ('04','05','06') THEN 'Q2'
					WHEN right(monthfirstreg,2) in ('07','08','09') THEN 'Q3'
					ELSE 'Q4'
			END

	union all

	select '3' as PerNum
		,MonthFirstReg as Sort
		,LEFT(datename(month,MonthFirstReg + '-01'),3) + ' '
			+ left(monthfirstreg,4)
			as Date
		,count(case when bodytype = 'cars' then 1 end) / 1000.0 as Cars
		,count(case when bodytype = 'MOTORCYCLES, MOPEDS & SCOOTERS' then 1 end) / 1000.0 as Bikes
		,count(case when bodytype = 'GOODS - LIGHT' then 1 end) / 1000.0 as LGV
		,count(case when bodytype = 'GOODS - HEAVY' then 1 end) / 1000.0 as HGV
		,count(case when bodytype = 'BUSES & COACHES' then 1 end) / 1000.0 as Bus
		,count(case when bodytype in ('AGRICULTURAL', 'NOT RECORDED','OTHERS','SPECIAL PURPOSE','TRICYCLES','TAXIS') then 1 end) / 1000.0 as Other
		,sum(1) / 1000.0 as Total
		,cast(null as float) as YoY
		,avg(case when bodytype='cars' and (co2 > 0 or propulsiontype='electricity') then co2 else null end) as [AvgCo2]
		,cast(null as float) as Ulev
		,cast(null as float) as UlevCars
		,cast(null as float) as PluginGrant
		,cast(null as float) as PluginNonGrant
	from dbo.newregfinal
	where MonthFirstReg >= '2014-07' and MonthFirstReg <= @lastmonth
	group by MonthFirstReg
		,LEFT(datename(month,MonthFirstReg + '-01'),3) + ' '
			+ left(monthfirstreg,4)

	order by Pernum,Sort,Date

----////----////----////----////----////----////----////----////----////----////----////----////----////----////

	update RAP.VEH0150_UK
	set [Average CO2 emissions for newly registered cars] = null
	where Date like '%2001%' or Date like '%2002%'

----////----////----////----////----////----////----////----////----////----////----////----////----////----////
	
	select '1' as PerNum
		,left(monthfirstreg,4) as Date
		,sum(1) / 1000.0 as Ulev
		,count(case when bodytype = 'cars' then 1 end) / 1000.0 as UlevCars
		,count(case when category <=4 and (bodytype='goods - light' or (bodytype='cars' and cattype not in ('L6', 'L7'))) then 1 end) / 1000.0 as PluginGrant
		,count(case when category > 4 and (bodytype='goods - light' or (bodytype='cars' and cattype not in ('L6', 'L7'))) and plugin = 1 then 1 end) / 1000.0 as PluginNonGrant

	into Vehicles_NewReg.RAP.tmpULEV

	from dbo.ULEV_NewReg n
	left join vehicles_lookuptables.dbo.PlugIns p
		on n.makeid = p.makeid
		and n.modelid = p.modelid
	where valid = 1 and MonthFirstReg <= @lastyear and MonthFirstReg >= '2015-01'
	group by left(monthfirstreg,4)

	union all

	select '2' as PerNum
		,left(monthfirstreg,4) + ' '
			+ CASE WHEN right(monthfirstreg,2) in ('01','02','03') THEN 'Q1'
					WHEN right(monthfirstreg,2) in ('04','05','06') THEN 'Q2'
					WHEN right(monthfirstreg,2) in ('07','08','09') THEN 'Q3'
					ELSE 'Q4'
			END as Date
		,sum(1) / 1000.0 as Ulev
		,count(case when bodytype = 'cars' then 1 end) / 1000.0 as UlevCars
		,count(case when category <=4 and (bodytype='goods - light' or (bodytype='cars' and cattype not in ('L6', 'L7'))) then 1 end) / 1000.0 as PluginGrant
		,count(case when category > 4 and (bodytype='goods - light' or (bodytype='cars' and cattype not in ('L6', 'L7'))) and plugin = 1 then 1 end) / 1000.0 as PluginNonGrant

	from dbo.ULEV_NewReg n
	left join vehicles_lookuptables.dbo.PlugIns p
		on n.makeid = p.makeid
		and n.modelid = p.modelid
	where valid = 1 and MonthFirstReg <= @lastquarter and MonthFirstReg >= '2014-07'
	group by left(monthfirstreg,4) + ' '
			+ CASE WHEN right(monthfirstreg,2) in ('01','02','03') THEN 'Q1'
					WHEN right(monthfirstreg,2) in ('04','05','06') THEN 'Q2'
					WHEN right(monthfirstreg,2) in ('07','08','09') THEN 'Q3'
					ELSE 'Q4'
			END

	union all

	select '3' as PerNum
		,LEFT(datename(month,MonthFirstReg + '-01'),3) + ' '
			+ left(monthfirstreg,4)
			as Date
		,sum(1) / 1000.0 as Ulev
		,count(case when bodytype = 'cars' then 1 end) / 1000.0 as UlevCars
		,count(case when category <=4 and (bodytype='goods - light' or (bodytype='cars' and cattype not in ('L6', 'L7'))) then 1 end) / 1000.0 as PluginGrant
		,count(case when category > 4 and (bodytype='goods - light' or (bodytype='cars' and cattype not in ('L6', 'L7'))) and plugin = 1 then 1 end) / 1000.0 as PluginNonGrant

	from dbo.ULEV_NewReg n
	left join vehicles_lookuptables.dbo.PlugIns p
		on n.makeid = p.makeid
		and n.modelid = p.modelid
	where valid = 1 and MonthFirstReg <= @lastmonth and MonthFirstReg >= '2014-07'
	group by LEFT(datename(month,MonthFirstReg + '-01'),3) + ' '
			+ left(monthfirstreg,4)

	order by Pernum,Date
	
----////----////----////----////----////----////----////----////----////----////----////----////----////----////

	update v
	set [Ultra Low Emission Vehicles (ULEVs)] = u.Ulev
		,[Ultra Low Emission Cars] = u.UlevCars
		,[Plug-in Grant Eligible Cars and Vans] = u.PluginGrant
		,[Plug-in Non Grant Eligible Cars and Vans] = u.PluginNonGrant
	from RAP.tmpULEV u
	join RAP.VEH0150_UK v
	on u.PerNum = v.PerNum
		and u.Date = v.Date
		
	update a
	set [Year-on-year change in total vehicles] = -100.0 + (a.Total * 100.0) / cast(b.Total as float)
	FROM [Vehicles_NewReg].[RAP].[VEH0150_UK] a
	left join [Vehicles_NewReg].[RAP].[VEH0150_UK] b
	on a.pernum = b.pernum
	and cast(case a.pernum
			when 1 then a.date
			when 2 then left(a.date,4)
			when 3 then right(a.date,4)
		end as int)
		= cast(case b.pernum
			when 1 then b.date
			when 2 then left(b.date,4)
			when 3 then right(b.date,4)
		end as int) + 1
	and case a.pernum
			when 1 then ''
			when 2 then right(a.Date,2)
			when 3 then left(a.Date,3)
		end
		= case b.pernum
			when 1 then ''
			when 2 then right(b.Date,2)
			when 3 then left(b.Date,3)
		end

----////----////----////----////----////----////----////----////----////----////----////----////----////----////
	
	print('Finished processing VEH0150');
END
GO

