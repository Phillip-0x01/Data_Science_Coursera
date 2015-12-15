#GETTING AND CLEANING DATA


#GREAT CODE TO DETERMINE IF PACKAGE IS INSTALLED AND IF NOT INSTALL IT!
list.of.packages <- c("dplyr", "downloader")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)


#CODE TO DOWNLOAD AND OPEN ZIP FILES FROM THE INTERNET
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download(url, dest="dataset.zip", mode="wb", quiet = TRUE) 
unzip ("dataset.zip", exdir = "./")


#file.exists(“directoryName”) will check to see if the directory exists
#dir.create(“directoryName”) will create a directory if it doesn’t exist
#Here is an example checking for a “data” directory and creating it if it doesn’t exist

if (!file.exists(“data”)) {
    dir.create(“data”)
}

#check for packages, if missing install
list.of.packages <- c(“dplyr”)
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,”Package”])]
if(length(new.packages)) install.packages(new.packages)

#install package
install.packages(“ggplot2”)
#load package library
library(ggplot2)


#--download from the web--
fileUrl <- “https://data.baltimorecity.gov/api/views/dz54-2aru/rows.csv?accessType=DOWNLOAD”
download.file(fileUrl, destfile = “./data/cameras.csv”, method = “curl”)
list.files(“./data”)
#then add the date, just in case the data changes in the future
dateDownloaded <- date()
dateDownloaded

#--reading a local file---
cameraData <- read.table(“./data/cameras.csv”, sep = “,”, header = TRUE,)
#use can also use read.csv()  has the sep and header above set as defaults
#other important parameters: quote, na.strings, nrows, skip

#---DATA.TABLE---
#loda the vectors into variables and then you can create or add them to a data frame
companiesData <- data.frame(fyear, company, revenue, profit)




#_____READING SQL INTO R__________________________________________________________________

#-SQL tables will all read into R as separate tables
#-first install MySQL package, but make sure you install the correct one from the web
#-on a Mac, simply use -- install.packages(RMySQL)

#---this installs package
install.packages(RMySQL)

#---connect to ucsc db and run a query to get the names of all database
ucsc <- dbConnect(MySQL(), user=”genome”, 
					host=”genome-mysql.cse.ucsc.edu”)
result <- dbGetQuery(ucscDb, “show databases;”); dbDisconnect(ucscDb);
#---make sure to disconnect from the database when you are done

#---connect to SPECIFIC ucsc db and run a query to get the total number of all tables
hg19 <- dbConnect(MySQL(),user=”genome”, db=”hg19”,
                    host=”genome-mysql.cse.ucsc.edu”)
allTables <- dbListTables(hg19)
length(allTables)

#---returns the names of the first 5 tables
allTables[1:5]

#---first argument is database, second is table
dbListFields(hg19,”affyU133Plus2”)

#---another query, pass MySQL commands in quotes (this counts number of records in table)
dbGetQuery(hg19, “select count(*) from affyU133Plus2”)

#---this gets the “affyU133Plus2” table out 
affyData <- dbReadTable(hg19, “affyU133Plus2”)
head(affyData)

#---select just a portion of the table from db
query <- dbSendQuery(hg19, "select * from affyU133Plus2 where misMatches between 1 and 3")
#query stores the above in the database, so use next line to extract the data
affyMis <- fetch(query); quantile(affyMis$misMatches)

#--sending the query function leaves it at the db, the fetch function brings back the records

#---after you fetch the query back you MUST make sure to clear the query!
dbClearResult(query);

#---don’t forget to close the connection!  One of the most common mistakes
dbDisconnect(hg19)

#--RMySQL vignette http://cran.r-project.org/web/packages/RMySQL/RMySQL.pdf
#--A nice blog post summarizing some other commands http://www.r-bloggers.com/mysql-and-r/



#_____READING DATA FROM HTF5______________________________________________________________

#---sourcing the package will install it, you'll also need to install additional stuff with second line
source("http://bioconductor.org/biocLite.R")
biocLite("rhdf5")

#---call the library as you normally would, then create the HTF5 file
library(rhdf5)
created = h5createFile("example.h5")
created

#---you can create groups within the file
created = h5createGroup("example.h5","foo")
created = h5createGroup("example.h5","baa")
created = h5createGroup("example.h5","foo/foobaa")
h5ls("example.h5")

#---write to the groups that was created above
A = matrix(1:10,nr=5,nc=2)
h5write(A, "example.h5","foo/A")
B = array(seq(0.1,2.0,by=0.1),dim=c(5,2,2))
attr(B, "scale") <- "liter"
h5write(B, "example.h5","foo/foobaa/B")
h5ls("example.h5")

#---write to the top level group
df = data.frame(1L:5L,seq(0,1,length.out=5),
  c("ab","cde","fghi","a","s"), stringsAsFactors=FALSE)
h5write(df, "example.h5","df")
h5ls("example.h5")

#---read data out of the file
readA = h5read("example.h5","foo/A")
readB = h5read("example.h5","foo/foobaa/B")
readdf= h5read("example.h5","df")
readA

#---reading and writing chucks
h5write(c(12,13,14),"example.h5","foo/A",index=list(1:3,1))
h5read("example.h5","foo/A")

#-hdf5 can be used to optimize reading/writing from disc in R
#-The rhdf5 tutorial: http://www.bioconductor.org/packages/release/bioc/vignettes/rhdf5/inst/doc/rhdf5.pdf
#-The HDF group has informaton on HDF5 in general http://www.hdfgroup.org/HDF5/


#_____READING DATA FROM THE WEB___________________________________________________________

#---use this code to get data from the web, returns one long line of text though
con = url("http://scholar.google.com/citations?user=HI-I6C0AAAAJ&hl=en")
htmlCode = readLines(con)
close(con)
htmlCode

#-can use the XLM package as explained before or.....

#---use the httr package
library(httr); html2 = GET(url)
content2 = content(html2,as="text")
parsedHtml = htmlParse(content2,asText=TRUE)
xpathSApply(parsedHtml, "//title", xmlValue)

#----access website with password
pg2 = GET("http://httpbin.org/basic-auth/user/passwd",
    authenticate("user","passwd"))
pg2 #prints out what you got above

#---make sure to use handles, so if you authenticate one you can use it over and over
google = handle("http://google.com")
pg1 = GET(handle=google,path="/")
pg2 = GET(handle=google,path="search")


#_____APIs________________________________________________________________________________

#-use the httr package to interface with the API
#-need to create an API account to get access, you'll need 

#---use this to sign into the account and get data from the GET function on the last line
myapp = oauth_app("twitter",
                   key="yourConsumerKeyHere",secret="yourConsumerSecretHere")
sig = sign_oauth1.0(myapp,
                     token = "yourTokenHere",
                      token_secret = "yourTokenSecretHere")
homeTL = GET("https://api.twitter.com/1.1/statuses/home_timeline.json", sig)

#---use the content function will recognize that it is json data and it will return a structured R object
json1 = content(homeTL)
#---use the json package to restructure it
json2 = jsonlite::fromJSON(toJSON(json1))
#---then use the json function from the lite package to create a data.frame
json2[1,1:4]

#-more twitter information: https://dev.twitter.com/docs/api/1.1/overview
#-httr works weel with Facebook, Google, Twitter, Github, etc.



#____READING DATA FROM OTHER SOURCES______________________________________________________

#-Roger has a nice video on how there are R packages for most things that you will want to access.
#-In general the best way to find out if the R package exists is to Google "data storage mechanism R package" 
#-RODBC provides interfaces to multiple databases including PostgreQL, MySQL, Microsoft Access and SQLite. 
#-Tutorial - http://cran.r-project.org/web/packages/RODBC/vignettes/RODBC.pdf
#-help file - http://cran.r-project.org/web/packages/RODBC/RODBC.pdf


#________________________QUIZ 2___________________________________________________________
#___GITHUB
library("httr")
oauth_endpoints("github")
myapp <- oauth_app("github", "3d842be919dcb9b04159", "f483c8f4c808b8f0749361ea181fec5063bf72c8")
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)
BROWSE("https://api.github.com/users/jtleek/repos", authenticate("Access Token","x-oauth-basic","basic"))

#-using sqldf - 
sqldf("select distinct AGEP from acs")

#-HTML connection
#How many characters are in the 10th, 20th, 30th and 100th lines of HTML from this page:
#http://biostat.jhsph.edu/~jleek/contact.html
#(Hint: the nchar() function in R may be helpful)
hurl <- "http://biostat.jhsph.edu/~jleek/contact.html "
con <- url(hurl)
htmlcode <- readLines(con)
close(con)
sapply(htmlcode[c(10,20,30,100)], nchar)
<meta name="Distribution" content="Global" />               <script type="text/javascript">                                         })();                 \t\t\t\t<ul class="sidemenu"> 
                                           45                                            31                                             7                                            25 


#Read this data set into R and report the sum of the numbers in the fourth of the nine columns.
#https://d396qusza40orc.cloudfront.net/getdata%2Fwksst8110.for 
data <- read.csv("./getdata_wksst8110.for")
filename <- "./getdata_wksst8110.for"
df <- read.fwf(file=filename, widths=c(-1,9,-5,4,4,-5,4,4,-5,4,4,-5,4,4), skip=4)
sum(df[, 4])
[1] 32426.7

#______SUBSETTING AND SORTING_____________________________________________________________
#X is data frame, var1-var4 are vectors 

#-subset by column number or name, row & column, logical statements, 
X[,1]
x[,"var 1"]
X[1:2,"var 1"]
X[(X$var1 <=3 & X$var3 > 11),]
X[(X$var1 <=3 | X$var3 > 11),]  # | means or
X[which(X$var > 8),] #which command drops the NA rows (indices) the return

#-sort by column, decreasing, put NAs at end
sort(X$var1)
sort(X$var1, decreasing=TRUE)
sort(X$var1, na.last=TRUE)

#-ordering 
X[order(X$var1,X$var2),]

#-ordering in dplyr
library(dyplr)
arrange(X,var1)
arrange(X,desc(var1))

#-add rows and columns
X$var4 <- rnom(5) #create a new column label and assign data to it
Y <- cbind(X, rnorm(5)) #puts 'rnorm(5)' after the X data frame, can put "rnom(5)' in front
#by using cbind(rnorm(5),X) - with the variable infront of the data frame
#RBIND - same as cbind above


#______SUMMARIZING DATA___________________________________________________________________
#again, this how to get web data
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://data.baltimorecity.gov/api/views/k5ry-ef3g/rows.csv?accessType=DOWNLOAD"
download.file(fileUrl,destfile="./data/restaurants.csv",method="curl")
restData <- read.csv("./data/restaurants.csv")

#specify number of rows in head or tail command
head(restData, n=3)
tail(restData, n=3)

#summary command will get an overall view
summar(restData)
	#named variables gets counts, data gets min, median, mean, max, 1st/3rd quartiles

#srt gives you class, dimension, and all of the classes of the columns
str(restData)

#returns different percent tiles
quantile(restData$councilDistrict, na.rm=TRUE)

#make tables 
table(restData$zipCode,useNA="ifany") 
	#if there are any missing values 'useNA' will tell you how many are missing

#check for missing values
sum(is.na(restData$councilDistrict))
	#if sum is equal to zero, then no missing values
any(is.na(restData$councilDistrict))
	#would return TRUE if there were any NAs in the df
all(restData$zipCode > 0 )
	#all runs all values against a logical statement and returns TRUE or FALSE
	
#sums across columns or rows
colSums(is.na(restData))
	#returns sum for each column
all(colSum(is.na(restData))
	#checks all together and returns T or F
	
#find values with specific characteristics 
table(restData$zipCode %in% c("21212"))
	#returns 2 columns, one with sum of FALSE, another with sum of TRUE

#can also use it to search for multiple values (either or)
table(restData$zipCode %in% c("21212","21213"))
	
#you can actually use the function above to create a subset of that data
restData_2[restData$zipCode %in% c("21212","21213"),]
	
#create cross tabs
	#this is sample R data to setup the example
data(UCBAsmissions)
DF = as.data.frame(UCBAdmissions)
summary(df)
	#prints our counts for 'admit' 'gender' 'dept' and 'freq'
xt <- xtabs(Freq ~ Gender + Admit, data=DF) #need to tell it the data frame

#-size of a data set
object.size(x)
print(object.size(x), units="Mb")

#______CREATING NEW VARIALBES_____________________________________________________________

#create a sequence of values 	
s1 <- seq(1,10,by=2) ; s1	
s2 <- seq(1,10,length=3); s2
x <- c(1,3,8,25,100); seq(along = x)

#subset variables so you don't need to keep using the long one below
restData$nearMe = restData$neighborhood %in% c("Roland Park", "Homeland")
table(restData$nearMe)

#create binary variables
restData$zipWrong = ifelse(restData$zipCode < 0, TRUE, FALSE)
table(restData$zipWrong,restData$zipCode < 0)

#cut command can break it up into quantiles in example below
	#cutting produces factor variables 
restData$zipGroups = cut(restData$zipCode,breaks=quantile(restData$zipCode))
table(restData$zipGroups)

table(restData$zipGroups,restData$zipCode)
	#returns table that shows each zipcode variable and counts from each quartile 

#easier way to cut data
library(Hmisc)
restData$zipGroups = cut2(restData$zipCode,g=4) 
	#use cut2 and tell it break it into 4 groups (g=4)
table(restData$zipGroups)
	
#create factor variable 
restData$zcf <- factor(restData$zipCode)
restData$zcf[1:10]
	#looks the same as before but will tell you how many levels you have


#levels of factor variables 
	#creating dummy values beloW
yesno <- sample(c("yes","no"),size=10,replace=TRUE)
yesnofac = factor(yesno,levels=c("yes","no"))
relevel(yesnofac,ref="yes")
	
#can use the 'as.numeric()' function to turn it back into numeric values for analysis
as.numeric(yesno)

#use mutate to create a new version of a variable and add it to a dataset
library(Hmisc)
restData$zipGroups = cut2(restData$zipCode,g=4)
table(restData$zipGroups)
	
#--Common Transformations-----	
    abs(x) #absolute value
    sqrt(x) #square root
    ceiling(x) #ceiling(3.475) is 4
    floor(x) #floor(3.475) is 3
    round(x,digits=n) #roun(3.475,digits=2) is 3.48
    signif(x,digits=n) #signif(3.475,digits=2) is 3.5
    cos(x), sin(x) etc.
    log(x) #natural logarithm
    log2(x), log10(x) #other common logs
    exp(x) #exponentiating x

	
#______RESHAPING DATA_____________________________________________________________________

#melt creates a tall skinny dataset with the id's on each row and the measurements on each row
mtcars$carname <- rownames(mtcars)
carMelt <- melt(mtcars,id=c("carname","gear","cyl"),measure.vars=c("mpg","hp"))
head(carMelt,n=3)
	#
	
#after melting you can 'cast' it into different frames
cylData <- dcast(carMelt, cyl ~ variable)
cylData
	#this summaries the data with counts for number of cylinders by mpg and hp

#same as above but returns means, instead of counts above
cylData <- dcast(carMelt, cyl ~ variable,mean)
cylData	
	
#Averaging values - summing a table
#	 	count spray
#	1    10     A
#	2     7     A
#	3    20     A
#	4    14     A
#	5    14     A
#	6    12     A

tapply(InsectSprays$count,InsectSprays$spray,sum)
	#tapply function - apply along an index a perticular function
	#t applying (apply to count, along the index spray, the function sum)
	#with in value of counts is going to count the spray
#	  A   B   C   D   E   F 
#	174 184  25  59  42 200 

#Another way - split
spIns =  split(InsectSprays$count,InsectSprays$spray)
spIns
	#returns list of numbers

#another way is L Apply	
sprCount = lapply(spIns,sum)
sprCount
	#means to apply across the list the sum (can chose any function)
	
#to go back to a vector 
unlist(sprCount)
#or 
sapply(spIns,sum)

#Dplyr package of has nice function to do in one step
ddply(InsectSprays,.(spray),summarize,sum=sum(count))

#creating a new variable
spraySums <- ddply(InsectSprays,.(spray),summarize,sum=ave(count,FUN=sum))
dim(spraySums)
	#returns a new column where for each time A appears in the spray in inserts the total 
	#sum of all A's into that one row to use for further analysis 
	
#______DPLYR PACKAGE______________________________________________________________________
#-VERBS
#select: return a subset of the columns of a data frame
#filter: extract a subset of rows from a data frame based on
#logical conditions
#arrange: reorder rows of a data frame
#rename:renamevariablesinadataframe
#mutate: add new variables/columns or transform existing variables
#summarise/summarize: generate summary statistics of dierent variables in the data frame, 
	#possibly within strata
#There is also a handy print method that prevents you from printing a lot of data to the console
	
#-PROPERTIES
#The first argument is a data frame.
#The subsequent arguments describe what to do with it, and you can refer to columns in 
	#the data frame directly without using the $ operator (just use the names).
#The result is a new data frame
#Data frames must be properly formatted and annotated for this to all be usefuL



#select a few columns of data to look at 
head(select(chicago, city:dptp))	
#tells it what rows NOT to select
head(select(chicago, -(city:dptp))

#filter function to return just specific rows
chic.f <- filter(chicago, pm25tmean2 . 30)
head(chic.f, 10)
	#returns the top 10 rows of the df

#arrange sorts the dataset by a variable, difficult to do in R with out dplyr

#renaming is easy using the function below in dplyr
chicago <- rename(chicago, dewpoint = dptp, pm25 = pm25tmean2)
		
#Group_By
#generating summary statistics by stratum
Chicago <- mutate(chicago, tempcat = factor(1 * (tmpd > 80), labels = c("cold", "hot")))
hotcold <-group_by(chicago, tempcat) 
summarize(hotcold, pm25 = mean(pm25,na.rm =TRUE), o3 = max (o3tmean2), no2 = median (no2tmean2))

## Source: local data frame [3 x 4]
##
##   tempcat     pm25        o3      no2
## 1    cold 15.97807 66.587500 24.54924
## 2     hot 26.48118 62.969656 24.93870
## 3      NA 47.73750  9.416667 37.4444

#group the data by a new year variable and then sort by it
chicago <- mutate(chicago, year = as.POSIXlt(date)$year + 1900)
years <- group_by(chicago, year)
summarize (years, pm25 = mean(pm25, na.rm = TRUE), o3 = max(o3tmean2, na.rm = TRUE), 
	no2 = median(no2tmean2, na.rm = TRUE))
## Source: local data frame [19 x 4]
##
##    year     pm25       o3      no2
## 1  1987      NaN 62.96966 23.49369
## 2  1988      NaN 61.67708 24.52296
## 3  1989      NaN 59.72727 26.14062
## 4  1990      NaN 52.22917 22.59583
## 5  1991      NaN 63.10417 21.38194
## 6  1992      NaN 50.82870 24.78921
## 7  1993      NaN 44.30093 25.76993	
	
# %>% way to chain operations together 	

chicago %>% mutate(month =as.POSIXlt(date)$mon + 1) %>% group_by (month) %>% wsummarize
	(pm25 = mean(pm25, na.rm = TRUE), o3 = max(o3tmean2, na.rm = TRUE), no2 = 
	median(no2tmean2, na.rm = TRUE))
	
	
	
#Merging Data - merge()
    #Merges data frames
    #Important parameters: x,y,by,by.x,by.y,all

mergedData = merge(reviews,solutions,by.x="solution_id",by.y="id",all=TRUE)
head(mergedData)
	#merges dataframes 'reviews' and 'solutions' on reviews$solution_if and solutions$id
	#all = TRUE means that if there is an NA value in a row, it still includes the row, 
	#default is to drop it in the merge

#if you don't specify the variable to match on it tries to match on all variables which
#creates a problem


#--Using join in the plyr package
#Faster, but less full featured - defaults to left join, see help file for more
df1 = data.frame(id=sample(1:10),x=rnorm(10))
df2 = data.frame(id=sample(1:10),y=rnorm(10))
arrange(join(df1,df2),id)

#if you have multiple dataframes it's much easier to do it in plyer
df1 = data.frame(id=sample(1:10),x=rnorm(10))
df2 = data.frame(id=sample(1:10),y=rnorm(10))
df3 = data.frame(id=sample(1:10),z=rnorm(10))
dfList = list(df1,df2,df3)
join_all(dfList)




#_________________EDITING_TEXT_VARIABLES________________________________________________

#to make things lower case 
tolower()

#split data
strsplit(names(cameraData),":\\.") #have to use esc character since period 
	#is a reserved character

#one way to remove periods from variable names
firstElement <- function(x){x[1]}
sapply(splitNames, firstElement)
	#create the function 'firstElement', then apply it across the matrix 'splitNames'

#sub command substitutes
sub("_", "", names(reviews),)
	#so....in the names of the df 'reviews', where there is an ' _ ' remove it 
	#sub will ONLY replace the FIRST underscore in the name
#gsub will replace ALL of the underscores...
gsub("_", '', names(reviews),)

#FINDING VALUES - grep() and grep1()
grep("Alameda", cameraData$intersection)
	#will return the row numbers where Alameda appears
	#using 'value=TRUE' it will return the full value, instead of the row number
table(grepl("Alameda", cameraData$intersection))
	#returns a total number of FALSE / TRUE based on the vector

#MORE USEFUL STRING FUNCTIONS
#using the 'stringer' library
library(stringer)
#nchar returns number of characters in a string
nchar("Jeffrey Leek")  #returns 12
substr("Jeffrey Leek",1,7) #returns 1st through 7th letters, or Jeffrey
paste("Jeffrey","Leek") #returns "Jeffrey Leek", paste the two values together
paste0("Jeffrey","Leek") #pastes together with no space
str_trim("Jeff        ") #trims off an excess space from a string, or "Jeff"

#IMPORTANT POINTS ABOUT TEXT IN DATA SETS
#Names ov variables should be:
	#All lower case when possible
	#Descriptive (Diagnosis versus Dx)
	#Not duplicated
	#Not have underscores or dots or white spaces 
#Variables with character values
	#Should usually be made into factor variables (depends on application)
	#Should be descriptive (use TRUE/FALSE instead of 0/1 and Male/Female instead of 
		#0/1 or M/F

#__________________REGULAR_EXPRESSIONS_________________________________________________

#metacharacters can be used to find words in the start, end of line

^i think #where ^ means start of a line and will return the following examples
	#i think we all rule for participating
	#i think i have been outed
	#i think this will be quite fun actually
	
mornings$ #where $ represents the end of the line, ex..
	#well they had something this morning
	#then had to catch a tram home in the morning
	#dog obedience school in the morning 
	
#Character Classes with []	
[Bb] [Uu] [Ss] [Hh]
#This will match Bush regardless if the letters are cap or lower case

^[Ii] am #will return strings that start with either 'I am' or 'i am'
^[0-9] [a-zA-Z] #starts with a number and is followed by a letter next in line

#when used at the beginning of a character class the ^ is also a metacharacter and 
	#indicates matching characters NOT in the indicated class
[^?.]$  #will return any sentence that does NOT end in ? or .

#the ' . ' (dot) is a WILDACARD 
9.11 # would return 9/11, 9-11, 9.1, etc

#pipe key is an 'or' character
flood|earthquake|hurrican|coalfire #returns any of those 

^[Gg]ood | [Bb]ad 
	#returns 'good to hear some....', 'Good afternoon', 'My name is Miss Bad News'
	#the last one returns 'bad' in the middle because only 'good' has the ^ in front of it

^([Gg]ood | [Bb]ad) #by constraining, both must be first words

#if you place a ? after parathese, it means optional
[Gg]eorge( [Ww]|.)? [Bb]ush  
	#the W. is optional

#---  * means repeated any number of times  
(.*) #returns ............, ..., . 

#   '+ ' means at least one of them (i.e. one number 0-9) & (.*) means repeat
[0-9]+ (.*) [0-9]+  # would return 720, 45, 8493885, etc.

#{ and } are referred to as interval quantifiers; they let us specify 
#the minimum and maximum number of matches of an expression

#CURLY BRACKETS

[Bb]ush( +[^ ]+ +){1,5} debate
	#start with Bush, then space(+), the a word[^ ]+, then a space(+), and repeat 
	#that 1-5 times ( {}  ), and finally have the word debate at the end.  
	#returns: Bush (had historically won all major) debates he's done.e


#if you use these inside the curly brackets...
    #m,n means at least m but not more than n matches
    #m means exactly m matches
    #m, means at least m matches (m comma)


#In most implementations of regular expressions, the parentheses not only 
#limit the scope of alternatives divided by a “|”, but also can be used 
#to “remember” text matched by the subexpression enclosed
#We refer to the matched text with \1, \2, etc

+([a-zA-Z]+) +\1 +
#returns replication of phrase 

^s(.*)s
	#will go for the longest possible string (it's greedy).  That includes a sentence
	#that starts with S and ends with S.
	#The greediness of * can be turned off with the ?, as in

#--KEY TAKE AWAYS---

#Regular expressions are composed of literals and metacharacters that represent 
#sets or classes of characters/words

#Text processing via regular expressions is a very powerful way to extract
#data from “unfriendly” sources (not all data comes as a CSV file)

#Used with the functions grep,grepl,sub,gsub and others that involve 
#searching for text strings






#___________________DATE_AND_TIME______________________________________________________

#regular data() returns current date and time, but notice the class
d1 = date()
d1
[1] "Sun Jan 12 17:48:33 2014"
class(d1)
[1] "character"

#here the Sys.Date() is from the actual system, so more reliable, and it's 
#classified as a date, not a character as above
d2 = Sys.Date()
d2
[1] "2014-01-12"
class(d2)
[1] "Date"

#-Formatting Dates

#%d = day as number (0-31), %a = abbreviated weekday,%A = unabbreviated weekday, 
#%m = month (00-12), %b = abbreviated month, %B = unabbrevidated month, 
#%y = 2 digit year, %Y = four digit year

format(d2,"%a %b %d")
[1] "Sun Jan 12"


#Creating Dates

x = c("1jan1960", "2jan1960", "31mar1960", "30jul1960"); z = as.Date(x, "%d%b%Y")
	#z takes vector x and turns it into a date
z
[1] "1960-01-01" "1960-01-02" "1960-03-31" "1960-07-30"

#difference between two dates
z[1] - z[2]
Time difference of -1 days

#return just the number of days, not the whole statement above
as.numeric(z[1]-z[2])
[1] -1





#Converting to Julian - number of days that have occured since the orgin date 

weekdays(d2)
[1] "Sunday"

months(d2)
[1] "January"

julian(d2)
[1] 16082

attr(,"origin")
[1] "1970-01-01"


#- Lubridate Package
#using d, m, y you tell it how to look at the date and convert it

library(lubridate)
ymd("20140108")
[1] "2014-01-08 UTC"

mdy("08/04/2013")
[1] "2013-08-04 UTC"

dmy("03-04-2013")
[1] "2013-04-03 UTC"

#http://www.r-statistics.com/2012/03/do-more-with-dates-and-times-in-r-with-lubridate-1-1-0/


#--Dealing With Times

ymd_hms("2011-08-03 10:15:03")
[1] "2011-08-03 10:15:03 UTC"

ymd_hms("2011-08-03 10:15:03",tz="Pacific/Auckland")
[1] "2011-08-03 10:15:03 NZST"

?Sys.timezone  #<-- all about setting timezones, like 'tz' above

#http://www.r-statistics.com/2012/03/do-more-with-dat es-and-times-in-r-with-lubridate-1-1-0/


#Some functions have slightly different syntax
#lubridata as well.....
x = dmy(c("1jan2013", "2jan2013", "31mar2013", "30jul2013"))
wday(x[1])
[1] 3

wday(x[1],label=TRUE)
[1] Tues
Levels: Sun < Mon < Tues < Wed < Thurs < Fri < Sat



#________SWIRL:__TIDY_DATA_USING_"tidyr"_______________________________________________

#-should be required reading for anyone who works with data: http://vita.had.co.nz/papers/tidy-data.pdf

#gather function
gather(data, key, value, ..., na.rm = FALSE, convert = FALSE)
	#useful to rearrange data, see example below


> students
  grade male female
1     A    1      5
2     B    5      0
3     C    5      2
4     D    5      5
5     E    7      4


> gather(students, sex, count, -grade)
   grade    sex count
1      A   male     1
2      B   male     5
3      C   male     5
4      D   male     5
5      E   male     7
6      A female     5
7      B female     0
8      C female     2
9      D female     5
10     E female     4

#It's important to understand what each argument to gather() means. The data argument, students, gives the name of
#the original dataset. The key and value arguments -- sex and count, respectively -- give the column names for our
#tidy dataset. The final argument, -grade, says that we want to gather all columns EXCEPT the grade column (since
#grade is already a proper column variable.)

#example dataset gather & separate functions
> students2
  grade male_1 female_1 male_2 female_2
1     A      3        4      3        4
2     B      6        4      3        5
3     C      7        4      3        8
4     D      4        0      8        1
5     E      1        1      2        7

#first, join all four gender columns together
>res <- gather(students2, sex_class, count, -grade)
>res
   grade sex_class count
1      A    male_1     3
2      B    male_1     6
3      C    male_1     7
4      D    male_1     4
5      E    male_1     1
6      A  female_1     4
7      B  female_1     4
8      C  female_1     4
9      D  female_1     0
10     E  female_1     1
11     A    male_2     3
12     B    male_2     3
13     C    male_2     3
14     D    male_2     8
15     E    male_2     2
16     A  female_2     4
17     B  female_2     5
18     C  female_2     8
19     D  female_2     1
20     E  female_2     7

#then, split the sex_class column into two columns delimited by _
> separate(res, sex_class, c("sex", "class"))
   grade    sex class count
1      A   male     1     3
2      B   male     1     6
3      C   male     1     7
4      D   male     1     4
5      E   male     1     1
6      A female     1     4
7      B female     1     4
8      C female     1     4
9      D female     1     0
10     E female     1     1
11     A   male     2     3
12     B   male     2     3
13     C   male     2     3
14     D   male     2     8
15     E   male     2     2
16     A female     2     4
17     B female     2     5
18     C female     2     8
19     D female     2     1
20     E female     2     7
#tidying of data complete......

#same as above but using the $%>% like in dplyr
students2 %>%
  gather(sex_class, count, -grade) %>%
  separate(sex_class, c("sex", "class")) %>%
  print


#NEXT EXAMPLE
#The first variable, name, is already a column and should remain as it is. The headers 
#of the last five columns, class1# through class5, are all different values of what 
#should be a class variable. The values in the test column, midterm and final, 
#should each be its own variable containing the respective grades for each student.

students3
    name    test class1 class2 class3 class4 class5
1  Sally midterm      A   <NA>      B   <NA>   <NA>
2  Sally   final      C   <NA>      C   <NA>   <NA>
3   Jeff midterm   <NA>      D   <NA>      A   <NA>
4   Jeff   final   <NA>      E   <NA>      C   <NA>
5  Roger midterm   <NA>      C   <NA>   <NA>      B
6  Roger   final   <NA>      A   <NA>   <NA>      A
7  Karen midterm   <NA>   <NA>      C      A   <NA>
8  Karen   final   <NA>   <NA>      C      A   <NA>
9  Brian midterm      B   <NA>   <NA>   <NA>      A
10 Brian   final      B   <NA>   <NA>   <NA>      C



students3 %>%
  gather(class, grade, class1:class5 , na.rm = TRUE) %>%
  print

  name    test  class grade
1  Sally midterm class1     A
2  Sally   final class1     C
3  Brian midterm class1     B
4  Brian   final class1     B
5   Jeff midterm class2     D
6   Jeff   final class2     E
7  Roger midterm class2     C
8  Roger   final class2     A
9  Sally midterm class3     B
10 Sally   final class3     C
11 Karen midterm class3     C
12 Karen   final class3     C
13  Jeff midterm class4     A
14  Jeff   final class4     C
15 Karen midterm class4     A
16 Karen   final class4     A
17 Roger midterm class5     B
18 Roger   final class5     A
19 Brian midterm class5     A
20 Brian   final class5     C


students3 %>%
  gather(class, grade, class1:class5, na.rm = TRUE) %>%
  spread(test, gradee) %>% #<----NEW PART
  print
    name  class final midterm
1  Brian class1     B       B
2  Brian class5     C       A
3   Jeff class2     E       D
4   Jeff class4     C       A
5  Karen class3     C       C
6  Karen class4     A       A
7  Roger class2     A       C
8  Roger class5     A       B
9  Sally class1     C       A
10 Sally class3     C       B


students3 %>%
  gather(class, grade, class1:class5, na.rm = TRUE) %>%
  spread(test, grade) %>%
  mutate(class = extract_numeric(class)) %>%
  print
  
name class final midterm
1  Brian     1     B       B
2  Brian     5     C       A
3   Jeff     2     E       D
4   Jeff     4     C       A
5  Karen     3     C       C
6  Karen     4     A       A
7  Roger     2     A       C
8  Roger     5     A       B
9  Sally     1     C       A
10 Sally     3     C       B
#completed



#NEW EXAMPLE
> students4
    id  name sex class midterm final
1  168 Brian   F     1       B     B
2  168 Brian   F     5       A     C
3  588 Sally   M     1       A     C
4  588 Sally   M     3       B     C
5  710  Jeff   M     2       D     E
6  710  Jeff   M     4       A     C
7  731 Roger   F     2       C     A
8  731 Roger   F     5       B     A
9  908 Karen   M     3       C     C
10 908 Karen   M     4       A     A

student_info <- students4 %>%
  select(id, name, sex) %>%
  unique %>%
  print
  
gradebook <- students4 %>%
  select(id, class, midterm, final) %>%
  print


#NEW EXAMPLE - #5
> passed
   name class final
1 Brian     1     B
2 Roger     2     A
3 Roger     5     A
4 Karen     4     A

> failed
   name class final
1 Brian     5     C
2 Sally     1     C
3 Sally     3     C
4  Jeff     2     E
5  Jeff     4     C
6 Karen     3     C

#create a new column labeled 'status' and add "passed" or "failed"
passed <- mutate(passed, status = "passed")
failed <- mutate(failed, status = "failed")

#combine the datasets using dplyr's bind_rows() function
bind_rows(passed,failed)

 name class final status
1  Brian     1     B passed
2  Roger     2     A passed
3  Roger     5     A passed
4  Karen     4     A passed
5  Brian     5     C failed
6  Sally     1     C failed
7  Sally     3     C failed
8   Jeff     2     E failed
9   Jeff     4     C failed
10 Karen     3     C failed
#tidy dataset complete

#REAL WORLD DATASET AND PROBELM
> sat
Source: local data frame [6 x 10]

  score_range read_male read_fem read_total math_male math_fem math_total write_male write_fem write_total
1     700-800     40151    38898      79049     74461    46040     120501      31574     39101       70675
2     600-690    121950   126084     248034    162564   133954     296518     100963    125368      226331
3     500-590    227141   259553     486694    233141   257678     490819     202326    247239      449565
4     400-490    242554   296793     539347    204670   288696     493366     262623    302933      565556
5     300-390    113568   133473     247041     82468   131025     213493     146106    144381      290487
6     200-290     30728    29154      59882     18788    26562      45350      32500     24933       57433

#tidy the dataset up by 
sat %>%
  select(-contains("total")) %>%
  gather(part_sex, count, -score_range) %>%
  separate(part_sex, c("part", "sex")) %>%
  group_by(part, sex) %>%
  mutate(total = sum(count),
  		prop = count/ total
  ) %>% print


Source: local data frame [36 x 6]
Groups: part, sex

   score_range part  sex  count  total       prop
1      700-800 read male  40151 776092 0.05173485
2      600-690 read male 121950 776092 0.15713343
3      500-590 read male 227141 776092 0.29267278
4      400-490 read male 242554 776092 0.31253253
5      300-390 read male 113568 776092 0.14633317
6      200-290 read male  30728 776092 0.03959324
7      700-800 read  fem  38898 883955 0.04400450
8      600-690 read  fem 126084 883955 0.14263622
9      500-590 read  fem 259553 883955 0.29362694
10     400-490 read  fem 296793 883955 0.33575578
..         ...  ...  ...    ...    ...        ...

















