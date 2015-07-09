# TODO List

# Error Handline

Currently, if we try to find a resource that does not exist on the server, we get a JsonApiClient::Errors::NotFound error.
This would be a useful thing to catch in the front end applications controllers etc.. but we do not want anything to do
with JsonApiClient to be visible outside of our API gem.
So, I guess the best thing to do is to catch errors in our gem and re raise them as our own errors ?