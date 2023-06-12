
#다트 주요주주 매입 보고서-------------------------------------------------

library(RSelenium)
library(dplyr)
library(stringr)
library(rvest)
library(httr)
library(knitr)
library(kableExtra)
library(tibble)

## Selenium 시작
rD <- rsDriver(browser="firefox", port=4729L, chromever=NULL)#파이어폭스
Sys.sleep(5)
remDr <- rD$client

# Navigating pages
URL <- "https://dart.fss.or.kr/dsab007/main.do?option=corp"
remDr$navigate(URL)
Sys.sleep(15)
#날짜입력
date <- format(Sys.Date(), "%Y%m%d")
pattern <- "#startDate"
element <- remDr$findElement(using = "css", pattern)
element$clearElement()
element$sendKeysToElement(list(date))
Sys.sleep(2)

#지분공시클릭
pattern <- "#li_04 > label:nth-child(1)"
element <- remDr$findElement(using = "css", pattern)
element$clickElement()
Sys.sleep(2)



#임원.주요주주특정증권등소유상황보고서 
pattern <- "#publicTypeDetail_D002"
element <- remDr$findElement(using = "css", pattern)
element$clickElement()
Sys.sleep(2)


# 100개목록 정렬 수동클릭
element$sendKeysToElement(list(key = "page_down"))
library(KeyboardSimulator)
mouse.get_cursor() 

mouse.move(466, 276) ## 검색창 위치로 마우스 커서 이동
Sys.sleep(1)
mouse.click()
Sys.sleep(1)
mouse.move(466 , 378) ## 검색창 위치로 마우스 커서 이동
Sys.sleep(1)
mouse.click()
Sys.sleep(1)
#검색버튼클릭
pattern <- "#searchForm > div.subSearchWrap > div.btnArea > a.btnSearch"
element <- remDr$findElement(using = "css", pattern)
element$clickElement()
Sys.sleep(1)

# Get HTML source
txt <- remDr$getPageSource()[[1]]
res <- read_html(txt)
Sys.sleep(1)

#기업명
pattern <- "#tbody a:nth-child(2)"
corp <- res %>% 
  html_nodes(pattern) %>% 
  html_text() %>% 
  str_replace_all('\n|\t','')

#보고서명
pattern <- ".tL+ .tL a"
name <- res %>% 
  html_nodes(pattern) %>% 
  html_text() %>% 
  str_replace_all('\n|\t','')

#링크수집
pattern <- ".tL+ .tL a"
link <- res %>% 
  html_nodes(pattern) %>% 
  html_attr('href') %>% 
  str_c('https://dart.fss.or.kr',.)

tab <- cbind(date,corp,name, link) %>% as_tibble()
tab$date <- as.Date(tab$date, format = "%Y%m%d")

df <- tab %>%
  mutate(name.link = cell_spec(name, "html", link = link, color="#062872")) %>%
  select(date,corp, name.link)

names(df) <- c("Date","Corp", "보고서")

assign(paste0('df_',date),df)

# Close the browser
remDr$close()

# stop the selenium server
rD$server$stop()

df %>%  kable(format="html", escape=FALSE, row.names = FALSE) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"))

#한경 기업레포트수집-------------------------------------------------------------------------------------


## Selenium 시작
rD <- rsDriver(browser="firefox", port=4729L, chromever=NULL)#파이어폭스

remDr <- rD$client
URL <- "http://hkconsensus.hankyung.com/apps.analysis/analysis.list?&skinType=business"
remDr$navigate(URL)

txt <- remDr$getPageSource()[[1]]
res <- read_html(txt)

# Navigating pages
URL <- "https://dart.fss.or.kr/dsab007/main.do?option=corp"
remDr$navigate(URL)



#테이블 추출
tab2 <- res %>% html_table() %>% .[[1]]


#링크추출
pattern <- ".text_l a"
link <- res %>% 
  html_nodes(pattern) %>% 
  html_attr("href") %>% 
  str_c('http://hkconsensus.hankyung.com',.)

#제목만 추출
pattern <- ".text_l a"
title <- res %>% 
  html_nodes(pattern) %>% 
  html_text() %>% 
  str_trim()

tab2 <- cbind(link, tab2, title) %>% as_tibble()

df2 <- tab2 %>%
  mutate(name.link = cell_spec(title, "html", link = link, color="#062872")) %>%
  select(작성일, name.link, 투자의견,제공출처)

names(df2) <- c('Date','제목','의견','출처')

df2 %>%  kable(format="html", escape=FALSE, row.names = FALSE) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"))

# Close the browser
remDr$close()

# stop the selenium server
rD$server$stop()



