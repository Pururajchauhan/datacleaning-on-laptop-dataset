-- data cleaning

SELECT * FROM sql_cx_live.laptopdata;

 -- create a backup of data 
create table laptop_backup like laptopdata;
insert into laptop_backup
select * from laptopdata;
-- check memory consumption for reference
select data_length/1024 from information_schema.Tables
where table_schema = 'sql_cx_live'
and table_name = 'laptopdata';

-- drop non important cols
alter table laptopdata drop column `Unnamed: 0`;
select * from laptopdata;
-- drop null values
delete from laptopdata
where `index` in (select `index` from laptopdata
where Company is null and typename is null and inches is null
and screenresolution is null and cpu is null and ram is null and memory is null and Gpu is null and Opsys is null and weight is null and price is null )
;
DELETE FROM laptopdata
WHERE Company IS NULL
   OR typename IS NULL
   OR inches IS NULL
   OR screenresolution IS NULL
   OR cpu IS NULL
   OR ram IS NULL
   OR memory IS NULL
   OR Gpu IS NULL
   OR Opsys IS NULL
   OR weight IS NULL
   OR price IS NULL;

-- drop duplicates
-- subse phele check krenge ki data mai duplicates hai ya nhi
SELECT Company, typename, inches, screenresolution, cpu,
       ram, memory, gpu, opsys, weight, price,
       COUNT(*) AS cnt
FROM laptopdata
GROUP BY Company, typename, inches, screenresolution, cpu,
         ram, memory, gpu, opsys, weight, price
HAVING COUNT(*) > 1;
-- table mai id column add krnege jabhi delete possible hai
ALTER TABLE laptopdata
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;
-- aab duplicate delete krenge
DELETE t1
FROM laptopdata t1
JOIN laptopdata t2
  ON t1.Company = t2.Company
 AND t1.typename = t2.typename
 AND t1.inches = t2.inches
 AND t1.screenresolution = t2.screenresolution
 AND t1.cpu = t2.cpu
 AND t1.ram = t2.ram
 AND t1.memory = t2.memory
 AND t1.gpu = t2.gpu
 AND t1.opsys = t2.opsys
 AND t1.weight = t2.weight
 AND t1.price = t2.price
 AND t1.id > t2.id;
 -- aab id column bhi drop kr denge
 ALTER TABLE laptopdata
DROP COLUMN id;
-- clean Ram-> change col type
alter table laptopdata modify column Inches decimal(10,1);


UPDATE laptopdata
SET Ram = REPLACE(Ram, 'GB', '');
-- clean weight -> change col type


UPDATE laptopdata
SET Weight = TRIM(REPLACE(REPLACE(Weight, 'kg', ''), 'Kg', ''));



-- round price col and change to integer
UPDATE laptopdata
SET Price = ROUND(Price);

-- change the opsys col
select OpSys,
Case
when OpSys Like '%mac%' then 'macos'
when OpSys Like '%window%' then 'window'
when OpSys Like '%linux%' then 'linux'
when OpSys Like '%No OS%' then 'N/A'
else 'other'
end as 'OS_brand'
from laptopdata;

update laptopdata
set OpSys = 
Case
when OpSys Like '%mac%' then 'macos'
when OpSys Like '%window%' then 'window'
when OpSys Like '%linux%' then 'linux'
when OpSys Like '%No OS%' then 'N/A'
else 'other'
end;

-- Gpu
alter table laptopdata
add column gpu_brand  varchar(255) after Gpu,
add column gpu_name varchar(255) after gpu_brand;
select * from laptopdata;

UPDATE laptopdata
SET gpu_brand = SUBSTRING_INDEX(Gpu, ' ', 1);


UPDATE laptopdata
SET gpu_name = TRIM(REPLACE(Gpu, gpu_brand, ''));
                
SELECT * FROM laptopdata;


ALTER TABLE laptopdata DROP COLUMN Gpu;


SELECT * FROM laptopdata;


ALTER TABLE laptopdata
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;


SELECT * FROM laptopdata;


UPDATE laptopdata
SET cpu_brand = SUBSTRING_INDEX(Cpu, ' ', 1);
								


UPDATE laptopdata
SET cpu_speed = CAST(
    REPLACE(SUBSTRING_INDEX(Cpu, ' ', -1), 'GHz', '')
    AS DECIMAL(3,1)
);                         
 
UPDATE laptopdata
SET cpu_name = REPLACE(REPLACE(Cpu,cpu_brand,''),SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,''),' ',-1),'');
                                        
                    
SELECT * FROM laptopdata;


ALTER TABLE laptopdata DROP COLUMN Cpu;


SELECT ScreenResolution,
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1)
FROM laptopdata;


ALTER TABLE laptopdata 
ADD COLUMN resolution_width INTEGER AFTER ScreenResolution,
ADD COLUMN resolution_height INTEGER AFTER resolution_width;


SELECT * FROM laptopdata;


UPDATE laptopdata
SET resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1);






ALTER TABLE laptopdata
ADD COLUMN touchscreen INTEGER AFTER resolution_height;





UPDATE laptopdata
SET touchscreen = ScreenResolution LIKE '%Touch%';


SELECT * FROM laptopdata;


ALTER TABLE laptopdata
DROP COLUMN ScreenResolution;


SELECT * FROM laptops;


SELECT cpu_name,
SUBSTRING_INDEX(TRIM(cpu_name),' ',2)
FROM laptopdata;


UPDATE laptopdata
SET cpu_name = SUBSTRING_INDEX(TRIM(cpu_name),' ',2);


SELECT DISTINCT cpu_name FROM laptopdata;

select * from laptopdata;


SELECT Memory FROM laptops;


ALTER TABLE laptopdata
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;


SELECT Memory,
CASE
        WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%' THEN 'SSD'
    WHEN Memory LIKE '%HDD%' THEN 'HDD'
    WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END AS 'memory_type'
FROM laptopdata;


UPDATE laptopdata
SET memory_type = CASE
        WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%' THEN 'SSD'
    WHEN Memory LIKE '%HDD%' THEN 'HDD'
    WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END;


SELECT Memory,
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END
FROM laptopdata;


UPDATE laptopdata
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
secondary_storage = CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END;


SELECT 
primary_storage,
CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage,
CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END
FROM laptopdata;


UPDATE laptopdata
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END;


select * from laptopdata;



ALTER TABLE laptopdata DROP COLUMN Memory;


SELECT * FROM laptopdata;
