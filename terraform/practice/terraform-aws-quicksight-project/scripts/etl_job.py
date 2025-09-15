import sys
from awsglue.utils import getResolvedOptions
from pyspark.sql import SparkSession
from pyspark.sql.functions import current_date

args = getResolvedOptions(sys.argv, ['RAW_S3_PATH','OUTPUT_S3_PATH','GLUE_DATABASE'])
RAW_S3_PATH = args['RAW_S3_PATH']
OUTPUT_S3_PATH = args['OUTPUT_S3_PATH']

spark = SparkSession.builder.appName("csv-to-parquet").getOrCreate()
df = (spark.read.format('csv').option('header','true').option('inferSchema','true').load(RAW_S3_PATH))

df_clean = df.dropDuplicates().dropna(how='all', subset=df.columns)
df_final = df_clean.withColumn('ingestion_date', current_date())
(df_final.repartition(1).write.mode('overwrite').format('parquet').partitionBy('ingestion_date').save(OUTPUT_S3_PATH))

print("ETL completed: CSV -> Parquet at", OUTPUT_S3_PATH)
