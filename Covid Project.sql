--Data exploration of covid deaths and vaccinations

SELECT * 
FROM Project..Covid_Deaths
ORDER BY 3,4


SELECT * 
FROM Project..Covid_Vaccines
ORDER BY 3,4


-- Selecting the focus data for analysis

SELECT location,
       date,
       total_cases,
	   new_cases,
	   total_deaths,
	   population
FROM Project..Covid_Deaths
WHERE total_cases IS NOT NULL
ORDER BY 1,2


--Death percentage of covid cases within Australia
--Total covid deaths vs total covid cases

SELECT location,date,total_deaths,total_cases, ROUND((cast(total_deaths as decimal)/cast(total_cases as decimal))*100, 2) AS Death_Percentage
FROM Project..Covid_Deaths
WHERE location = 'Australia'
ORDER BY 1,2


--Infection rate of covid within Australia
--Total covid cases vs Population

SELECT location,
       population,
       MAX(total_cases) AS highest_infections, 
	   ROUND(MAX(total_cases/population)*100, 2) AS infection_rate
FROM Project..Covid_Deaths
WHERE location = 'Australia'
GROUP BY location,population


--Death rate of covid within Australia
--Total covid deaths vs Population

SELECT location,
       population,
       MAX(cast(total_deaths as int)) AS total_deaths, 
	   ROUND((MAX(cast(total_deaths as int))/population)*100, 2) AS death_rate
FROM Project..Covid_Deaths
WHERE location = 'Australia'
GROUP BY location,population


--New vaccination rolling count by country

WITH vaccstatus (location, population, date, total_deaths, newly_vaccinated, rolling_vaccinated) AS
(SELECT cd.location, population, cd.date,total_deaths, new_vaccinations AS newly_vaccinated,
SUM(CAST(new_vaccinations as bigint)) OVER (Partition BY cd.location order by cd.location, cd.date ) AS rolling_vaccinated
FROM Project..Covid_Deaths AS cd
JOIN Project..Covid_Vaccines AS cv
ON cd.location = cv.location
AND cd.date = cv.date)


--New vaccinations percentage within Australia
--New vaccinated vs Population

SELECT *, ROUND((rolling_vaccinated/population)*100, 2) AS vaccinated_percentage
FROM vaccstatus
WHERE location = 'Australia'



--Creating Views for future visualisations
USE Project
GO
Create View PercentPopulationVaccinated as
SELECT cd.location, population, cd.date,total_deaths, new_vaccinations AS newly_vaccinated,
SUM(CAST(new_vaccinations as bigint)) OVER (Partition BY cd.location order by cd.location, cd.date ) AS rolling_vaccinated
FROM Project..Covid_Deaths AS cd
JOIN Project..Covid_Vaccines AS cv
ON cd.location = cv.location
AND cd.date = cv.date
GROUP BY population, cd.date, cd.location, total_deaths, new_vaccinations


USE Project
GO
Create View PercentPopulationInfected as
SELECT location,
       population,
       MAX(total_cases) AS highest_infections, 
	   ROUND(MAX(total_cases/population)*100, 2) AS infection_rate
FROM Project..Covid_Deaths
WHERE location = 'Australia'
GROUP BY location,population;

USE Project
GO
Create View PercentPopulationDeath as
SELECT location,date,total_deaths,total_cases, ROUND((cast(total_deaths as decimal)/cast(total_cases as decimal))*100, 2) AS Death_Percentage
FROM Project..Covid_Deaths
WHERE location = 'Australia';