{
"responseHeader":{
"status":0,
"QTime":10,
"params":{
"q":"gtin:04015600385187",
"pt":"54.991614,-1.5294362",
"d":"100",
"indent":"true",
"fl":"store_latitude_longitude,store_address,gtin,sales_date,avlblty_ind,store_publc_phone_num,retailer_name,geodist()",
"start":"0",
"fq":"{!geofilt}%26sfield",
"sort":"geodist() asc",
"rows":"20",
"spatial":"true",
"sfield":"store_latitude_longitude",
"wt":"json"}},
"response":{"numFound":86,"start":0,"docs":[
{
"store_address":["HADRIAN ROAD, WALLSEND, NE28 6HH"],
"gtin":"04015600385187",
"sales_date":["2016-08-04"],
"store_publc_phone_num":["NA"],
"store_latitude_longitude":"55.0033, -1.51643",
"avlblty_ind":["P"],
"retailer_name":"Asda",
"geodist()":1.5416546921660783},
{
"store_address":["SHIELDS ROAD, NEWCASTLE UPON TYNE, NE6 1EJ"],
"gtin":"04015600385187",
"sales_date":["2016-07-11"],
"store_publc_phone_num":["0191 26552"],
"store_latitude_longitude":"54.9832181, -1.5643395",
"avlblty_ind":["P"],
"retailer_name":"Morrisons",
"geodist()":2.414575941999174},
{
"store_address":["UNIT 5, NEWCASTLE-UPON-TYNE, NE6 2YJ"],
"gtin":"04015600385187",
"sales_date":["2016-08-04"],
"store_publc_phone_num":["NA"],
"store_latitude_longitude":"54.9787, -1.56326",
"avlblty_ind":["P"],
"retailer_name":"Asda",
"geodist()":2.59213511883195},
{
"store_address":["STATION ROAD, HEBBURN, NE31 1PN"],
"gtin":"04015600385187",
"sales_date":["2016-08-04"],
"store_publc_phone_num":["NA"],
"store_latitude_longitude":"54.9697, -1.50868",
"avlblty_ind":["P"],
"retailer_name":"Asda",
"geodist()":2.7734100605640166},
{
"store_address":["NORHAM ROAD, NORTHSHIELDS, NE29 7UJ"],
"gtin":"04015600385187",
"sales_date":["2016-07-13"],
"store_publc_phone_num":["NA"],
"store_latitude_longitude":"55.0082673, -1.4793063",
"avlblty_ind":["A"],
"retailer_name":"Tesco",
"geodist()":3.6947712649282014}]
}}