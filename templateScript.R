require(rvest)
require(RCurl)

args <- commandArgs(TRUE)
number <- as.character(args[1])
#car_num <- "JM7GH32F891120698"
car_num <- number

url_global <- "https://es.adpolice.gov.ae/trafficservices/PublicServices/AccidentsInquiry.aspx?Culture=en&mode=update" 
pg <- read_html(url_global)
nodesVIEWSTATE <- html_nodes(pg, xpath=".//input[@id='__VIEWSTATE']")
VIEWSTATE <- nodesVIEWSTATE %>% html_attr("value")
nodesVIEWSTATEGENERATOR <- html_nodes(pg, xpath=".//input[@id='__VIEWSTATEGENERATOR']")
VIEWSTATEGENERATOR <- nodesVIEWSTATEGENERATOR %>% html_attr("value")
nodesEVENTVALIDATION <- html_nodes(pg, xpath=".//input[@id='__EVENTVALIDATION']")
EVENTVALIDATION <- nodesEVENTVALIDATION %>% html_attr("value")

form_data=c(
        "ctl00$ScriptManager1","ctl00$ContentPlaceHolder1$upMain|ctl00$ContentPlaceHolder1$btnSubmit",
        "__LASTFOCUS:","",
        "ctl00$ContentPlaceHolder1$txtChassisNo",car_num,
        "__EVENTTARGET","ctl00$ContentPlaceHolder1$btnSubmit",
        "__EVENTARGUMENT","",
        "__VIEWSTATE",VIEWSTATE,
        "__VIEWSTATEGENERATOR",VIEWSTATEGENERATOR,
        "__EVENTVALIDATION",EVENTVALIDATION,
        "__ASYNCPOST","true") 
param <- c()
listP <- list()
for (i in seq(1, 18, 2)) {
        param <- c(param, paste(URLencode(form_data[i], reserved = TRUE), URLencode(form_data[i+1], reserved = TRUE), sep = "="))
        listP[URLencode(form_data[i], reserved = TRUE)] =  URLencode(form_data[i+1], reserved = TRUE)
}
param <- paste(param, collapse = "&")
res <- getURL(url_global, customrequest = "POST", postfields = param, httpheader = c("User-Agent" = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.120 Safari/537.36"))
pg <- read_html(res)
nodes <- html_nodes(pg, xpath=".//a[starts-with(@id, 'ctl00')]")
links <- nodes %>% html_attr("href")
links <- paste0("https://es.adpolice.gov.ae/trafficservices/PublicServices/", links)

for (k in 1:length(links)) {
        link <- links[k]
        pg <- read_html(link)
        nodes <- html_nodes(pg, xpath=".//table[@id='ctl00_ContentPlaceHolder1_frvAccidientDetails']")
        caption <- html_nodes(pg, xpath=".//span[@class='CaptionLabel']") %>% html_text()
        value <- html_nodes(pg, xpath=".//span[@class='ValueLabel']") %>% html_text()
        df <- data.frame(caption = caption, value = value)
        write.csv2(df, paste0("c:/PUB/ForR/", car_num, "_history_", k, ".csv"))
}