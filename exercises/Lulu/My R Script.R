mynumber<-2+2

my_object <- "name"

my_vector <- c(1, 2, 3)

my_string_vector <- c("this", "is", "a", "vector")

mean (my_vector)

mean (my_string_vector)

#this is a comment 

my_vector[2]

load(congress)
setwd()

x <- 5*6
x

seq(1, 10)
x <- "hello"

x <- seq(1,10,length.out =5)
(x <- seq(1,10,length.out =5))

my_vector [3]

random_vector <- c("R", "is", "great")
random_vector [3]

some_vector <- c(25555,342343,123123123,4234234,53243234,54324234,5421111,12312312,111231,
                 1231231,12312312,12312312,123123,898972,789872,2343,23423423,2343221,23423,
                 14444,44324222,2342341,124231111,22233345,1111233333,1231231,1231231)

typeof(some_vector)
class(some_vector)
max(some_vector)

{r message=FALSE, echo=TRUE} load(url('https://dssoc.github.io/datasets/congress.RData')) 

load(url('https://dssoc.github.io/datasets/congress.RData')) 
typeof(congress)

congress$birthyear

birthyear
mean(congress$birthyear)
age <- c(2024 - congress$birthyear)
mean(age)
congress$age[1] - congress$age[3]
max(age)

filter(congress, full_name == "Sherrod Brown") 



install.packages("tidyverse")

.libPaths()

library(tidyverse)

load("/Users/LuluS/Downloads/Apple_Mobility_Data.Rdata")

apple_data

brazil_data <- filter(apple_data, region == "Brazil")

regions <- select(apple_data, region)

transport_types <- count(apple_data, transportation_type)

alpha_order <- arrange(apple_data, region)

long_apple_apple <- gather(apple_data, key=day, value=mobility_data, `2020-01-13`:`2020-08-20`)

heights <- read_csv("data/heigths.csv")

as_tibble(iris)

tibble(
  x = 1:5,
  y = 1,
  z = x ^ 2 + y
)

tribble(
  ~x, ~y, ~z,
  "a", 2.6, 3.6,
  "b", 1, 8.5
)

library(tidyverse)

mpg

?mgp
?mpg

ggplot(data = mpg) +
  geom_point(mapping = aes(x =displ, y =hwy))

ggplot(data = mpg)

ggplot (data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy))

ggplot(data = mpg) +
  geom_point(mapping = aes(x = hwy, y = cyl))

ggplot(data = mpg) +
  geom_point(mapping = aes(x = class, y = drv))

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, colour = class))

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue")

?mpg

?geom_point 

typeof(mpg)

mpg_list <- list(mpg)

class(cyl)

ggplot( data = mpg) +
  geom_point(mapping = aes(x = hwy, y = displ, colour = displ<5))

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_wrap(~ class, nrow = 2)

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)


ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_wrap(drv ~ cyl)

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = drv, y = cyl))

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ drv)

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2)

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(colour = class)) +
  geom_smooth()

ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
  geom_point() + 
  geom_smooth()

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()

ggplot() + 
  geom_point(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_smooth(data = mpg, mapping = aes(x = displ, y = hwy))

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(x = displ, y = hwy, colour = drv), stroke = 2) +
  geom_smooth(mapping = aes(x = displ, y = hwy, group = drv), se = FALSE, colour = "blue")

?diamonds

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = stat(prop), group = 1))

ggplot(data = diamonds) +
  stat_summary(
    mapping = aes(x = cut, y = depth),
    fun.min = min,
    fun.max = max,
    fun = median
  )

?stat_summary           

ggplot(data = diamonds) +
  geom_pointrange(mapping = aes(x = cut, y = depth))

?geom_col

ggplot(data = diamonds) + 
  geom_col(mapping = aes(x = cut, y = stat(frequency)))          

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = after_stat(prop)))


ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, colour = cut))           

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = clarity))

ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_boxplot()

install.packages("nycflights13")
library(nycflights13)

library(tidyverse)

flights
nycflights13::flights

?'::'

filter(flights, month ==1 , day ==1)  

filter(flights, x==(11 | 12))

?c
?'%in%'

filter(flights, arr_delay <= 120)  

filter(flights, dest == "IAH" | dest == "HOU" )

filter(flights, dest %in% c("HOU", "IAH"))

library(nycflights13)

airlines
filter(flights, carrier %in% c("AA", "DL", "UA"))

filter(flights, dep_time >= 0 | dep_time <= 600)

?between

filter(flight, between(dep_time, 0, 600 ))
filter(flights, between(dep_time, 0 , 600))

filter(flights, is.na(dep_time))

is.na(flights)

NA ^ 2

arrange(flights, desc(is.na(dep_time)), dep_time)

select(flights, dep_time, dep_delay, arr_time, arr_delay, arr_delay)

vars <- c("year", "month", "day", "dep_delay", "arr_delay")

select(flights, any_of(vars))

select(flights, contains("TIME"))

view(flights)

?rank

time2min <- function(x) { 
       (x %/% 100 * 60 + x %% 100) %% 1440
}

time2mins <- function(x) {
  (x %/% 100 * 60 + x %% 100) %% 1440
}

flight_times <- mutate(flights,
        dep_time_mins = time2min(dep_time),
        sched_time_mins = time2min(sched_dep_time)
)

flights_times <- mutate(flights,
                        dep_time_mins = time2mins(dep_time),
                        sched_dep_time_mins = time2mins(sched_dep_time)
)

select(
  flights_times, dep_time, dep_time_mins, sched_dep_time,
  sched_dep_time_mins
)

flights_airtime <- 
  mutate(flights,
         dep_time = (dep_time %/% 100 *60 + dep_time %% 100) %% 1440,
         arr_time = (arr_time %/% 100 *60 + arr_time %% 100) %% 1440,
         air_time_diff = air_time - arr_time + dep_time
         )

?min_rank

min_rank(flights, arr_delay)

?slice

arrange(flights, desc(dep_delay))

flights_delayed2 <- arrange(flights, desc(dep_delay))
slice(flights_delayed2, 1:10)

1:3 + 1:10

library(tidyverse)
library(httr)

1+1

