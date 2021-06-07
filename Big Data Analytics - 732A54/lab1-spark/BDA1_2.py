######## Exercise 2 ########
from pyspark import SparkContext

sc = SparkContext(appName = "BDA1_2")

temperature_file = sc.textFile("BDA/input/temperature-readings.csv")

# Map the data, split by lines
lines = temperature_file.map(lambda line: line.split(";"))

# (Year, month) key, (station, temp) value
yearmonth_temp = lines.map(lambda x: ((x[1][0:4], x[1][5:7]), (x[0], float(x[3]))))

# above 10 degrees filter
yearmonth_temp = yearmonth_temp.filter(lambda x: int(x[0][0]) >= 1950 and int(x[0][0]) <= 2014 and x[1][1] > 10)

# count stations
count_above10 = yearmonth_temp.map(lambda x: (x[0], 1))
count_above10 = count_above10.reduceByKey(lambda a, b: a+b)

# Save data
count_above10.saveAsTextFile("BDA/output/LAB1_2")

### Uniques
count_unique = yearmonth_temp.map(lambda x: (x[0], (x[1][0], 1))).distinct()

count_unique = count_unique.map(lambda x: (x[0], 1))
count_unique = count_unique.reduceByKey(lambda a, b: a+b)

# Save data
count_unique.saveAsTextFile("BDA/output/LAB1_2_UNIQUE")