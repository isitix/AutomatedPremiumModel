library(httr)

today <- as.Date(Sys.time())

endpoint = "https://www.agileventures.org/api/subscriptions.json"
token <- Sys.getenv('WSO_TOKEN')
auth_value <- paste("Token token=\"", token,"\"",sep="")
resp <- GET(endpoint,add_headers(authorization = auth_value))
premium_users = jsonlite::fromJSON(content(resp, "text"))

slack_token <- Sys.getenv('PRODUCTION_SLACK_AUTH_TOKEN')

library(slackr)

users <- slackr_users(slack_token)

all <- merge(premium_users, users, by="email", all.x = TRUE)
no_matching_email_in_slack <- all[is.na(all$id),]
active_premium_users_whose_email_in_wso_does_not_match_in_slack <- subset(no_matching_email_in_slack, (ended_on > today | is.na(ended_on)) & plan_name != "Associate")
email_aliases <- read.csv("data/email_aliases.csv", stringsAsFactors=FALSE)

users_who_have_been_matched_with_email_aliases <- merge(active_premium_users_whose_email_in_wso_does_not_match_in_slack, email_aliases, by="email")

premium_users$email[match(users_who_have_been_matched_with_email_aliases$email, premium_users$email)] <- users_who_have_been_matched_with_email_aliases$alias_email


premium_users_in_slack <- merge(premium_users,users, by="email")
premium_users_in_slack$ended_on <- as.Date(premium_users_in_slack$ended_on)

active_premium_users_in_slack <- subset(premium_users_in_slack, (ended_on > today | is.na(ended_on)) & plan_name != "Associate")
active_premium_users_slack_names <- unique(active_premium_users_in_slack$name)
active_premium_users_slack_names <- c(active_premium_users_slack_names, "tansaku")
active_premium_users_slack_names <- c(active_premium_users_slack_names, "slackbot")
active_premium_users_slack_names <- c(active_premium_users_slack_names, "stella")
active_premium_users_slack_names <- c(active_premium_users_slack_names, "willwhite")
active_premium_users_slack_names <- c(active_premium_users_slack_names, "joaopereira")
active_premium_users_slack_names <- c(active_premium_users_slack_names, "cfme00")





slack_names <- data.frame(Slack=active_premium_users_slack_names)
write.csv(slack_names, file="data/av_members.csv")