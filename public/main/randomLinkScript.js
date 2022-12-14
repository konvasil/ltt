let randomURL = function(){

var urls = new Array();

urls[0] = "https://www.theguardian.com/environment/2022/nov/07/toad-licking-us-national-park-hallucinogen";
urls[1] = "https://news.yahoo.com/news/please-don-t-lick-psychedelic-133000909.html?guccounter=1&guce_referrer=aHR0cHM6Ly93d3cuZ29vZ2xlLmNvbS8&guce_referrer_sig=AQAAAG833WbjvEbBLw9OR7ps4jZ050emtGzgEusURoqGylbh-aHr0M3v74COHKVRUTi9eKpjwureAcYgaTFYH_54z3qFcq_ZCjAIxZyQaSM8bxHqbJUHzTuLBNuhJoh814_tJhD84RLheoepADKhOY7_HdAQUuCCy4BXKoYye0VKZwGZ";
urls[2] = "https://www.npr.org/2022/11/06/1134615997/the-national-park-service-wants-humans-to-stop-licking-this-toad";
urls[4] = "https://www.washingtonpost.com/health/2022/11/08/national-park-toad-sonoran-desert-hallucinogenic/";
urls[5] = "https://www.nytimes.com/2022/11/07/us/licking-toads-toxic.html";

var random = Math.floor(Math.random()*urls.length);

window.open(urls[random])
}
