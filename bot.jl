#Adding all the packages we need for this bot
import Pkg
Pkg.add(["OAuth", "HTTP", "JSON"])
using OAuth, HTTP, JSON

#Creating a function to filter out the tweets we want
function filter_tweets(tweets::Array)
    
    #List of tweets to be returned
    filtered_tweets = String[]
    
    #List of keywords we want the tweet to have
    keywords = ["brexit", "european union", "referendum", "conservative", "labour", "boris johnson", "united kingdom", "scotland", "ukip", "london", "manchester", "birmingham", "edinburgh", "british", "britain"]
    
    #Loop checking whether each tweet has contains any of the keywords, and if so, adds the tweet's id to the list of tweets to be returned
    for i in keywords
        for k = 1:length(tweets)
            if occursin(i, lowercase(tweets[k]["text"]))
                push!(filtered_tweets, tweets[k]["id_str"])
            end
        end
    end
    
    #Returns the list of the id of the tweets containing the keywords
    filtered_tweets
end

#Main function containing the body of the bot
function main()
    
    #Returns the JSON from the OAuth Request to get the most recent <number of tweets specified in the variable below> tweets
    tweets = JSON.parse(String(oauth_get("https://api.twitter.com/1.1/statuses/home_timeline.json", Dict("count" => "$no_of_tweets")).body))
    
    #Passes the tweets to be filtered and returns the tweets we want
    filtered_tweets = filter_tweets(tweets)
    
    #If there are no new tweets, we will give the user a message to let them know
    if length(filtered_tweets) == 0
        println("sorry, no new british news :(")
        
    #If there are new tweets, we want to retweet each and one of them
    else
        for id in filtered_tweets
            try
                oauth_post("https://api.twitter.com/1.1/statuses/retweet/$id.json", Dict("id" => "$id")) #runs the retweet request
            
            #Catches the error given when it tries to retweet the same tweet for the 2nd time
            catch
                continue #Skips the rest of the current loop iteration to move onto the next retweet
            end
        end
        println("added ", length(filtered_tweets), " tweets") #tells the user how many tweets were added
    end
end

#Variables containing the keys and tokens required to power the account the bot is running on
consumer_key = ARGS[1]
secret_consumer_key = ARGS[2]
access_token = ARGS[3]
secret_access_token = ARGS[4]

#Rewriting GET and POST functions to make life easier: we don't need to call the keys and tokens every time!
oauth_get(endpoint::String, options::Dict) = oauth_request_resource(endpoint, "GET", options, consumer_key, secret_consumer_key, access_token, secret_access_token)
oauth_post(endpoint::String, options::Dict) = oauth_request_resource(endpoint, "POST", options, consumer_key, secret_consumer_key, access_token, secret_access_token)

#The number of the most recent tweets the bot looks through on its home timeline every 8 minutes
no_of_tweets = 15

#Runs the main function
main()
