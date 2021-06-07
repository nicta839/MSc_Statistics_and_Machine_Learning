#########
### 2 ###
#########

from pyspark import SparkContext
from pyspark.sql import SQLContext, Row
from pyspark.sql import functions as F

sc = SparkContext()
sqlContext = SQLContext(sc)

rdd = sc.textFile("BDA/input/temperature-readings.csv")

parts = rdd.map(lambda line: line.split(";"))

temp_readings = parts.map(lambda p: Row(
    station=p[0], 
    year=p[1].split("-")[0], 
    month=p[1].split("-")[1], 
    value=float(p[3])))

df_temps = sqlContext.createDataFrame(temp_readings)
df_temps.registerTempTable("temp_readings")

df_temps = df_temps.filter((df_temps["year"] >= 1950) & \
    (df_temps["year"] <= 2014) & \
    (df_temps["value"] > 10)) \
    .drop_duplicates()
    
# Duplicate counts for each station included
df_temps_grouped = df_temps.groupBy(["year", "month"]).count().sort("count", ascending = False)
df_temps_grouped.rdd.saveAsTextFile("BDA/output/LAB2_2")

# Distinct monthly counts 
df_temps_distinct = df_temps.select(["year", "month", "station"]).distinct()
df_temps_grouped_distinct = df_temps_distinct.groupBy(["year", "month"]).count().sort("count", ascending = False)
df_temps_grouped_distinct.rdd.saveAsTextFile("BDA/output/LAB2_2_DISTINCT")