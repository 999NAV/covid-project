select * from ..CovidDeaths
select * from project.dbo.CovidVaccinations
order by 3,4
-- select data that we are going to be using
select location ,date , total_cases , new_cases,total_deaths , population 
from project..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total Deaths

select location ,date , total_cases , new_cases,(total_deaths/total_cases)*100 as  DeathPercentage
from project..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs population 
--shows what percentage of population got covid
select location ,date , total_cases , population,(total_deaths/total_cases)*100 as  percentagePopulationInfected
from project..CovidDeaths
where location like '%states'
and  continent is not null
order by 1,2


--looking at countries with highest infection rate
select location ,population, max(total_cases) as HighInfectionCount, max(total_cases/population)*100 as  PercentagePopulationInfected
from project..CovidDeaths
group by location , population 
order by PercentagePopulationInfected desc

--showing countries with highest Death count per population

select location , max(cast(Total_deaths as int)) as TotalDeathCount 
from project..CovidDeaths
where continent is not null
group by location 
order by TotalDeathCount desc

--lets break things down by location

select location , max(cast(Total_deaths as int)) as TotalDeathCount 
from project..CovidDeaths
where continent is  null
group by location 
order by TotalDeathCount desc

--lets break things down by continent
-- showing continents with highest death count 

select continent , max(cast(Total_deaths as int)) as TotalDeathCount 
from project..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers

select  sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from project..CovidDeaths
where continent is not null 
--group by date 
order by 1,2

--looking at total population vs vaccinations

select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations 
,sum(CONVERT(bigint, vac.new_vaccinations)) over(Partition by dea.location order by dea.location,
 dea.Date) as RollingPeopleVaccinated 
from project..CovidDeaths dea 
join  project.dbo.CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte

with PopvsVac (continent , location , date , population , New_vaccinations , RollingPeopleVaccinated )
as

(
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations 
,sum(CONVERT(bigint, vac.new_vaccinations)) over(Partition by dea.location order by dea.location,
 dea.Date) as RollingPeopleVaccinated 
from project..CovidDeaths dea 
join  project.dbo.CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
)
select * , (RollingPeopleVaccinated/population)*100
from PopvsVac


-- temp table 
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated

(
continent nvarchar(255), location nvarchar(255), date datetime , population numeric , New_vaccinations numeric , RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations 
,sum(CONVERT(bigint, vac.new_vaccinations)) over(Partition by dea.location order by dea.location,
 dea.Date) as RollingPeopleVaccinated 
from project..CovidDeaths dea 
join  project.dbo.CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
--where dea.continent is not null

select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- creating view to store data for later visualizations 
create view PercentPopulationVaccinated as 
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations 
,sum(CONVERT(bigint, vac.new_vaccinations)) over(Partition by dea.location order by dea.location,
 dea.Date) as RollingPeopleVaccinated 
from project..CovidDeaths dea 
join  project.dbo.CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
	 where dea.continent is not null

	 select * from PercentPopulationVaccinated





