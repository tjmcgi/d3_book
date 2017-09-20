import urllib2
import pandas as pd 
from bs4 import BeautifulSoup
import csv
import mysql.connector
from sqlalchemy import create_engine

page = "http://www.ercot.com/content/cdr/html/real_time_spp"
page = urllib2.urlopen(page)
soup = BeautifulSoup(page, 'html.parser')

table = soup.find('table', attrs={"class": "tableStyle"})
headers = [header.text for header in table.find_all('th') ]

rows = []
for row in table.find_all('tr'):
  rows.append([val.text.encode('utf8') for val in row.find_all('td')])

with open('ercot_rt.csv', 'wb') as f:
  writer = csv.writer(f)
  writer.writerow(headers)
  writer.writerows(row for row in rows if row)

names = ['date', 'interval_ending', 'HB_BUSAVG', 'HB_HOUSTON', 'HB_HUBAVG', 'HB_NORTH', 'HB_SOUTH', 'HB_WEST', 'LZ_AEN', 'LZ_CPS', 'LZ_HOUSTON', 'LZ_LCRA', 'LZ_NORTH', 'LZ_RAYBN', 'LZ_SOUTH', 'LZ_WEST' ]
data=pd.read_csv('ercot_rt.csv', sep=',', parse_dates=['Oper Day'], header=0, names=names)


engine = create_engine('mysql+mysqlconnector://tom@localhost/ercot', echo=False)
data.to_sql(name='staging_ercot_rt', con=engine, if_exists='replace', index=False)
  