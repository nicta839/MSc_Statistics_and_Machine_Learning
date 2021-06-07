#########
### 3 ###
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
    day=p[1].split("-")[2],
    value=float(p[3])))

df_temps = sqlContext.createDataFrame(temp_readings)
df_temps.registerTempTable("temp_readings")

# Filter entries 
df_temps = df_temps.filter((df_temps["year"] >= 1960) & (df_temps["year"] <= 2014))

# Calculate Max and Min temperatures
df_temps = df_temps.groupBy("station", "year", "month", "day") \
    .agg(F.max("value").alias("maxTemp"), F.min("value").alias("minTemp"))

# Create new column calculating the average from Max and Min temperature column
df_temps = df_temps.withColumn("avgTemp", (df_temps["maxTemp"] + df_temps["minTemp"]) / 2)

# Grouping on month and year and calculating the average monthly temperature based on our newly created column avgTemp
df_temps = df_temps.groupBy(["station", "month", "year"]) \
    .agg(F.avg("avgTemp").alias("monthlyAvgTemp")).orderBy(["monthlyAvgTemp", "year"], ascending=[0,1])

df_temps.rdd.saveAsTextFile("BDA/output/LAB2_3")