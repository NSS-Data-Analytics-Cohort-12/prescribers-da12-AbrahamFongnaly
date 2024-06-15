-- ## Prescribers Database

-- For this exericse, you'll be working with a database derived from the [Medicare Part D Prescriber Public Use File](https://www.hhs.gov/guidance/document/medicare-provider-utilization-and-payment-data-part-d-prescriber-0). More information about the data is contained in the Methodology PDF file. See also the included entity-relationship diagram.

-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
-- select total_claim_count, nppes_provider_first_name, npi
-- from prescription
-- 	join prescriber
-- 	using (npi)
-- 	order by total_claim_count DESC;
--1912011792, DAVID, 4538

--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
-- select nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, prescription.total_claim_count
-- from prescriber
-- join prescription
-- using (npi)
-- order by total_claim_count DESC;
--DAVID, COFFEY, Family Practice, 4538

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?
-- select total_claim_count, prescriber.specialty_description
-- from prescription 
-- join prescriber
-- using (npi)
-- order by total_claim_count desc;
-- 4538, family practice

--     b. Which specialty had the most total number of claims for opioids?
--  select total_claim_count, drug.drug_name, drug.opioid_drug_flag, prescriber.specialty_description
-- from prescription
-- join drug
-- using (drug_name)
-- 	 join prescriber
-- 	 using (npi)
-- order by total_claim_count DESC;
-- 4538, family practice, Oxycodone HCL

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
-- select total_claim_count, prescriber.specialty_description
-- from prescription 
-- join prescriber
-- using (npi)
-- order by total_claim_count;
-- no, lowest claim count is 11, associated to family practice
--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?
-- select total_drug_cost as drug_cost, drug.generic_name 
-- from prescription
-- join drug
-- using (drug_name)
-- order by drug_cost desc, drug.generic_name desc;
-- pirfenidone, 2829174.30
--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
-- select total_drug_cost/total_day_supply as cost_per_day, drug.generic_name
-- from prescription
-- join drug
-- using (drug_name)
-- order by cost_per_day desc;
-- 7141.106 Immun Glob G

-- select round(total_drug_cost/total_day_supply, 2) as cost_per_day, drug.generic_name
-- from prescription
-- join drug
-- using (drug_name)
-- order by cost_per_day desc
-- 7141.11 Immun Glob G
-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 
-- select drug_name, opioid_drug_flag, antibiotic_drug_flag,
-- 	case when opioid_drug_flag = 'Y' then 'opioid'
-- 	when antibiotic_drug_flag = 'Y' then 'antibiotic'
-- 	else 'Neither' end as neither
-- from drug
-- order by drug_name;
--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
-- select 
-- 	case when opioid_drug_flag = 'Y' then 'opioid'
-- 	when antibiotic_drug_flag = 'Y' then 'antibiotic'
-- 	else 'Neither' end as neither,
-- 	sum (prescription.total_drug_cost) as drug_total_cost
-- from drug
-- 	join prescription
-- using (drug_name)
-- group by neither
-- order by drug_total_cost;

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
-- select count(fips_county.state) as tn_cbsas
-- from fips_county
-- join cbsa
-- using (fipscounty)
-- where fips_county.state like '%TN%'
--42 

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
-- select cbsa.cbsaname, sum(population) as total_population
-- from population
-- join cbsa
-- using (fipscounty)
-- group by 1
-- order by total_population desc
-- Nashville, 1830410
-- Morristown, 116352
 
--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
-- select
-- 	fips_county.county,
-- 	max(population.population) as max_population
-- from population
-- join fips_county
-- using (fipscounty)
-- where fips_county.fipscounty not in (select fipscounty from cbsa)
-- group by fips_county.county
-- order by max_population desc;
--Sevier, 95523

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
-- select drug_name, total_claim_count
-- from prescription
-- where total_claim_count >= 3000;
-- Oxycodone, 4538
--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
-- select drug_name, total_claim_count, drug.opioid_drug_flag
-- from prescription
-- join drug
-- using (drug_name)
-- where total_claim_count >= 3000 
-- 	and drug.opioid_drug_flag = 'Y'
--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
-- select drug.drug_name, prescription.total_claim_count, drug.opioid_drug_flag, prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name
-- from prescription
-- join drug
-- on drug.drug_name= prescription.drug_name
-- join prescriber 
-- on prescriber.npi=prescription.npi
-- where total_claim_count >= 3000 
-- 	and drug.opioid_drug_flag = 'Y'
-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
-- select prescriber.npi, drug.drug_name
-- from prescriber
-- cross join drug
-- where prescriber.nppes_provider_city = 'NASHVILLE'
-- and opioid_drug_flag = 'Y'
-- and prescriber.specialty_description = 'Pain Management'

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
-- select total_claim_count, prescriber.npi, drug.drug_name
-- from prescriber
-- cross join drug
-- left join prescription
-- using (drug_name, npi)
-- where prescriber.nppes_provider_city = 'NASHVILLE'
-- and opioid_drug_flag = 'Y'
-- and prescriber.specialty_description = 'Pain Management'
-- order by 1 desc;

--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
-- select coalesce(total_claim_count, 0), prescriber.npi, drug.drug_name
-- from prescriber
-- cross join drug
-- left join prescription
-- using (drug_name, npi)
-- where prescriber.nppes_provider_city = 'NASHVILLE'
-- and opioid_drug_flag = 'Y'
-- and prescriber.specialty_description = 'Pain Management'
-- order by 1;