select *
From CovidDeaths
select *
From CovidVaccinations

-- Select data we are going to be using
select location, date, total_cases, New_Cases, Total_deaths, Population
From CovidDeaths
order by 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying for an individual in any country

SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT) * 100 AS Death_Percentage
FROM CovidDeaths
ORDER BY 1, 2;

-- Looking at total cases vs Population
-- Shows what percenatge of population got covid

SELECT location, date, total_cases, Population, CAST(total_cases AS FLOAT) / CAST(Population AS FLOAT) * 100 AS Infected_Percentage
FROM CovidDeaths
ORDER BY Infected_Percentage Desc

-- Looking at death rate per population

SELECT Distinct(location), Population, Max(total_deaths) As Total_Deaths, Max (CAST(total_deaths AS FLOAT) / CAST(Population AS FLOAT) * 100) As Death_per_Population
FROM CovidDeaths
Group By Location, Population
Order by Death_per_Population DESC

-- Looking at Total Cases Vs Total Deaths

SELECT Distinct(location), max(cast (total_cases as int)) As Total_cases, Max(Cast(total_deaths as int)) As Total_deaths
FROM CovidDeaths
Group By Location
order by 1

-- Looking at Mortality rate (Number of people dying from those infected)

WITH CTE_Mortality AS (SELECT Distinct(location), max(cast (total_cases as int)) As Total_cases, Max(Cast(total_deaths as int)) As Total_deaths
FROM CovidDeaths
Group By Location) 
Select *,
Case
When Total_deaths = '0' then 'Null'
ELSE Cast (total_deaths as Float)/ Cast (total_cases as Float) * 100
End As Mortality
from cte_Mortality
Order by Mortality Desc


-- Global Numbers

--- Looking at death counts per continent
select continent, Max(cast(total_deaths as int)) as Totaldeathcount
From CovidDeaths
Where Continent is not null
Group By continent
Order by totaldeathcount Desc

--- Daily cases and deaths around the world
select date, New_cases, New_deaths
From CovidDeaths
Order by date  

--- total Cases and total Deaths around the world

SELECT 
    location, date, SUM(CAST(new_cases AS int)) OVER (PARTITION BY location ORDER BY date) AS Total_cases, 
    Total_deaths
FROM 
    Coviddeaths
WHERE 
    location LIKE '%world%'
GROUP BY 
    location, date, Total_deaths, new_cases

	--covid-19 Mortality rate around the world

With Cte_CovidWorld AS (SELECT 
    location, date, SUM(CAST(new_cases AS int)) OVER (PARTITION BY location ORDER BY date) AS Total_cases, 
    Total_deaths
FROM 
    Coviddeaths
WHERE 
    location LIKE '%world%'
GROUP BY 
    location, date, Total_deaths, new_cases)

	SELECT Location, date, total_cases, Total_deaths, 
	(cast(total_deaths as float)/cast(total_cases as float)) * 100 As Mortality_rate
	From Cte_CovidWorld

-- Looking at Average Mortality Rate

With Cte_CovidWorld AS (SELECT 
    location, date, SUM(CAST(new_cases AS int)) OVER (PARTITION BY location ORDER BY date) AS Total_cases, 
    Total_deaths
FROM 
    Coviddeaths
WHERE 
    location LIKE '%world%'
GROUP BY 
    location, date, Total_deaths, new_cases)

	SELECT Location, 
	AVG (cast(total_deaths as float)/cast(total_cases as float)) * 100 As Mortality_rate
	From Cte_CovidWorld
	Group By Location

	Select Date, Sum(New_cases) as total_cases
	From CovidDeaths
	Group By Date
	order by 1

-- looking at total population vs vaccination

Select cd.continent, cd.location, cd.date, cd.population, Cv.new_vaccinations, Sum(Cast(cv.new_vaccinations as Float)) over (Partition by cd.location order by Cd.date) as Rolling_Vaccination_Count
From Coviddeaths CD
join CovidVaccinations CV
On CD.Location=CV.Location and Cd.date=CV.date
Where cd.Continent is not Null and cv.new_vaccinations is not Null
Group By cd.continent, cd.location, cd.date, cd.population, Cv.new_vaccinations
Order by 2, 3

-- Looking at percentage of people  vaccinated in each country

With Popvac as(
Select cd.continent, cd.location, cd.date, cd.population, Cv.new_vaccinations, Sum(Cast(cv.new_vaccinations as Float)) over (Partition by cd.location order by Cd.date) as Rolling_Vaccination_Count
From Coviddeaths CD
join CovidVaccinations CV
On CD.Location=CV.Location and Cd.date=CV.date
Where cd.Continent is not Null and cv.new_vaccinations is not Null
Group By cd.continent, cd.location, cd.date, cd.population, Cv.new_vaccinations)

Select location, population,Max(Rolling_vaccination_count) AS total_Vaccinations, Max(rolling_vaccination_count/Population) * 100 as Vaccination_Percentage
From popvac
Group By Location, Population
Order by 4 desc
