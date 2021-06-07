#########
### 1 ###
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
    value=float(p[3])))

df_temps = sqlContext.createDataFrame(temp_readings)
df_temps.registerTempTable("temp_readings")

df_temps = df_temps.filter((df_temps["year"] >= 1950) & (df_temps["year"] <= 2014))

max_temps = df_temps.groupBy("year").agg(F.max("value").alias("value"))
max_temps = max_temps.join(df_temps.select(["year", "station", "value"]), ["year", "value"], 'left') \
    .withColumnRenamed("value", "maxValue") \
    .orderBy(["maxValue", "year"], ascending=[0,1])

min_temps = df_temps.groupBy("year").agg(F.min("value").alias("value"))
min_temps = min_temps.join(df_temps.select(["year", "station", "value"]), ["year", "value"], 'left') \
    .withColumnRenamed("value", "minValue") \
    .orderBy(["minValue", "year"], ascending=[0,1])

max_temps.rdd.saveAsTextFile("BDA/output/LAB2_1_MAX")
min_temps.rdd.saveAsTextFile("BDA/output/LAB2_1_MIN")