
data <- Orange
head(data)
mod <- lm(age ~ circumference, data = data)
summary(mod)
yhat <- predict(mod,data)
scatter.smooth(yhat ~ data$age)

###logisticregression

data <- iris
head(data)
data$y <- ifelse(data$Species == "versicolor" ,1 ,0)
data$Species <- NULL
mod <- glm(factor(y) ~ Sepal.Length + Sepal.Width + Petal.Length ,data=data ,family = "binominal")  
summray (mod)
pred <- predict(mod,data,type = "response")
hist(pred)
yhat <- ifelse(pred>=0.5,1,0)
table (yhat= yhat,y=data$y)
#accuracy <-
#accuracy  
vif (mod)