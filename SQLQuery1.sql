select *
from Portfolioproject..CovidDeaths$
order by 3,4


select * 
from Portfolioproject..CovidVacinations$
order by 3,4

select location ,date,total_cases,new_cases,total_deaths,population
from Portfolioproject..CovidDeaths$
order by 1,2

--looking at total cases vs total deaths

select location ,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from Portfolioproject..CovidDeaths$
where location like '%states%'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
select location ,date,total_cases,population,(total_deaths/population)*100 as deathpercentage
from Portfolioproject..CovidDeaths$
where location like '%states%'
order by 1,2




--looking at countries with highest infection rate compared to population

select location ,population,max(total_cases) as highestinfectioncount,max((total_deaths/total_cases))*100 as 
PercentagePopulationInfected
from Portfolioproject..CovidDeaths$
--where loaction like '%states%'
group by location,population
order by PercentagePopulationInfected desc

 
 -- Showing countries with highest death count
 select location ,max(cast(total_deaths as int)) as totalDeathcount
from Portfolioproject..CovidDeaths$
where continent is not null
group by location
order by  totalDeathcount desc

--Let's Break things by continent

select location ,max(cast(total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths$
where continent is not null
group by location
order by  totalDeathcount desc

--showig continent with the highest death count per population

select continent ,max(cast(total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths$
where continent is not null
group by continent
order by  totalDeathcount desc

--Global Numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths$
where continent is null
order by 1,2

--looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinate/population)*100 
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..['owid-covid-data$'] vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinate/population)*100 
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..['owid-covid-data$'] vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--temp table

drop table if exists #PercentagepopulationVaccinated

create table #PercentagepopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentagepopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinate/population)*100 
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..['owid-covid-data$'] vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentagepopulationVaccinated

